#!/usr/bin/bash
# botscan: one-shot Arch compromise/botnet scan.
#   Clean: no output, exit 0. Findings: exit 1. Only errors: exit 2. Ctrl-C: exit 130.
#   Scanners missing at start are installed for the run and removed on exit, together with
#   everything they created (DBs, logs, system users, downloaded package files).
#   Optional allowlist: botscan.allow next to this script, one regex per line, matched against output lines.

[[ $EUID == 0 ]] || exec sudo -- "$(realpath -- "$0")" "$@"
set -uo pipefail
shopt -s nullglob
export PATH=/usr/bin LC_ALL=C

ALLOW=$(dirname -- "$(realpath -- "$0")")/botscan.allow
RULES_URL=https://github.com/elastic/protections-artifacts/archive/refs/heads/main.tar.gz
SUSPICIOUS='(curl|wget)[^|]*\|[[:space:]]*(ba|z)?sh|base64 -d[^|]*\|[[:space:]]*(ba|z)?sh|/dev/tcp/|nc(at)? .*-e |bash -i >&'

# command -> package that provides it
declare -A PKG=([paccheck]=pacutils [rkhunter]=rkhunter [strings]=binutils [yarac]=yara
  [unhide]=unhide [clamscan]=clamav [curl]=curl)
# state a package creates at install/run time that pacman won't remove
declare -A STATE=([clamav]="/etc/clamav /var/lib/clamav /var/log/clamav /run/clamav"
  [rkhunter]="/var/lib/rkhunter /var/log/rkhunter.log")
declare -A USERS=([clamav]=clamav) # created by systemd-sysusers on install

W=$(mktemp -d /tmp/botscan.XXXXXXXX)
mkdir "$W/running"
touch "$W/errors"
CACHE=$(pacman-conf CacheDir | head -n1)
keep=0 new_state=() new_users=()

# ---------- cleanup: undo everything this run added ----------

cleanup() {
  local rc=$? added
  trap '' INT TERM # a second Ctrl-C must not interrupt the uninstall
  [[ -t 2 ]] && printf '\r\033[K' >&2

  mapfile -t added < <(pacman -Qq | sort | comm -13 "$W/pkgs.before" -)
  if ((${#added[@]})) && ! pacman -Rn --noconfirm "${added[@]}" >"$W/uninstall.log" 2>&1; then
    echo "botscan: could not remove ${added[*]}, see $W/uninstall.log" >&2
    keep=1
  fi
  rm -rf -- "${new_state[@]}"
  for u in "${new_users[@]}"; do userdel "$u"; done
  ls -A "$CACHE" | sort | comm -13 "$W/cache.before" - | sed "s|^|${CACHE%/}/|" | xargs -r -d '\n' rm -f --

  ((keep)) || rm -rf -- "$W"
  exit "$rc"
}

# ---------- install missing scanners ----------

pacman -Qq | sort >"$W/pkgs.before"
ls -A "$CACHE" | sort >"$W/cache.before"
trap cleanup EXIT
trap 'trap "" INT TERM; kill 0; exit 130' INT TERM # stop all checks, then cleanup runs

missing=()
for cmd in "${!PKG[@]}"; do
  command -v "$cmd" >/dev/null || missing+=("${PKG[$cmd]}")
done
for p in "${missing[@]}"; do
  for path in ${STATE[$p]:-}; do
    [[ -e $path ]] || new_state+=("$path")
  done
  u=${USERS[$p]:-}
  [[ -n $u ]] && ! getent passwd "$u" >/dev/null && new_users+=("$u")
done
if ((${#missing[@]})); then
  [[ -t 2 ]] && printf 'installing %s' "${missing[*]}" >&2
  if ! pacman -S --needed --noconfirm "${missing[@]}" >"$W/install.log" 2>&1; then
    [[ -t 2 ]] && printf '\r\033[K' >&2
    tail -n 5 "$W/install.log" >&2
    echo "botscan: install failed, run pacman -Syu first" >&2
    exit 2
  fi
fi

# ---------- job runner ----------

start() { # name function: stdout = findings, stderr = log
  touch "$W/running/$1"
  ("$2" >"$W/$1.find" 2>"$W/$1.log" || :) && rm "$W/running/$1" &
}

wait_all() { # progress line on a terminal only
  local r
  while r=("$W"/running/*) && ((${#r[@]})); do
    [[ -t 2 ]] && printf '\r\033[K[%ds] %s' "$SECONDS" "${r[*]##*/}" >&2
    sleep 1
  done
  wait
}

wait_for_list() {
  while [[ -e $W/running/list ]]; do sleep 2; done
}

# ---------- checks ----------

chk_proc() { # running program deleted (not a pkg upgrade leftover), memory-only or started from tmp
  local p exe
  for p in /proc/[0-9]*; do
    exe=$(readlink "$p/exe" 2>/dev/null) || continue
    if [[ $exe =~ ^(memfd:|/tmp/|/var/tmp/|/dev/shm/) || ($exe == *' (deleted)' && $exe != /usr/*) ]]; then
      echo "pid ${p#/proc/}: $exe"
    fi
  done
}

chk_hidden() { # processes/ports hidden from ps/ss. alt: unhide brute (slow)
  unhide quick reverse | grep '^Found'
  unhide-tcp -s | grep '^Found'
}

chk_pkg() { # package files vs pacman's sha256. alt: pacman -Qkk (single thread)
  pacman -Qq | xargs -P "$(nproc)" -n 64 paccheck --sha256sum --quiet | grep mismatch
}

chk_list() { # files for yara/clamav: executables no repo package owns (AUR ones included) + all of tmp
  local roots
  mapfile -t roots < <(findmnt -rno TARGET -t ext4,btrfs,xfs,f2fs,zfs | grep -v snapshots)
  comm -23 <(pacman -Qlq | sort -u) <(pacman -Qlqm | sort -u) >"$W/repo-owned"
  # pruned: container layers (alt: trivy), Steam games (huge; remove prune to scan them)
  find "${roots[@]}" /tmp /var/tmp /dev/shm -xdev \
    \( -path "$W" -o -path /var/lib/containers -o -path '*/.local/share/containers' -o -path '*/steamapps' \) -prune \
    -o -type f -size -256M \( -perm /111 -o -path '/tmp/*' -o -path '/var/tmp/*' -o -path '/dev/shm/*' \) -print 2>/dev/null \
    | sort -u | comm -23 - "$W/repo-owned" >"$W/scan.lst"
}

chk_yara() { # Elastic Linux rules, downloaded each run. alt: Neo23x0 signature-base via Loki-RS
  local f ok=()
  mkdir "$W/rules"
  curl -fsSL --proto =https "$RULES_URL" | tar -xz --no-same-owner -C "$W/rules" --wildcards '*/yara/rules/Linux_*.yar'
  for f in "$W"/rules/*/yara/rules/*.yar; do # keep only rule files this yara version compiles
    yarac -w "$f" /dev/null 2>/dev/null && ok+=("$(basename "$f" .yar):$f")
  done
  if ! ((${#ok[@]})) || ! yarac -w "${ok[@]}" "$W/rules.yarc"; then
    echo "!! yara: no rules (download failed?)" >>"$W/errors"
    return
  fi
  wait_for_list
  nice yara -C -w -p 16 --scan-list "$W/rules.yarc" "$W/scan.lst" >"$W/yara.hits" \
    || echo "!! yara: scan failed, see log" >>"$W/errors"
  sed 's/^\([^ ]*\) \(.*\)/\2: \1/' "$W/yara.hits" # "rule path" -> "path: rule"
}

chk_clamav() { # sigs mostly Windows, some Unix (Mirai, miners). alt: clamdscan --multiscan
  # update sigs; on failure the existing DB is used
  timeout 40m freshclam --quiet &>/dev/null
  wait_for_list
  nice clamscan -i --no-summary --file-list="$W/scan.lst" | sed 's/ FOUND$//'
  grep -q 'ERROR' "$W/clamav.log" && echo "!! clamav: scan failed, see log" >>"$W/errors"
}

chk_rkhunter() { # warnings only. alt: chkrootkit (AUR)
  rkhunter --check --sk --rwo --nocolors --logfile "$W/rkhunter.rklog" \
    --enable known_rkts,additional_rkts,possible_rkt_files,trojans,os_specific,shared_libs,startup_malware,ports
}

chk_persist() { # preload library, extra root account, download-and-run / reverse shell in startup files
  [[ -s /etc/ld.so.preload ]] && echo "/etc/ld.so.preload: $(tr '\n' ' ' </etc/ld.so.preload)"
  awk -F: '$3 == 0 && $1 != "root" { print "uid 0 account: " $1 }' /etc/passwd
  grep -RsEHn -D skip "$SUSPICIOUS" \
    /etc/systemd /etc/cron* /var/spool/cron /etc/profile* /etc/bash.bashrc /etc/zsh /etc/xdg/autostart \
    /{root,home/*}/.{bashrc,bash_profile,profile,zshrc,zprofile,zshenv,config/systemd,config/autostart} \
    | grep -v ':[0-9]*:[[:space:]]*#' # skip commented lines
}

# ---------- run ----------

start proc chk_proc
wait_all
start hidden chk_hidden # alone: other jobs' short-lived processes look like hidden PIDs
wait_all
for c in pkg list yara clamav rkhunter persist; do start "$c" "chk_$c"; done
wait_all
[[ -t 2 ]] && printf '\r\033[K' >&2

# ---------- report ----------

[[ -f $ALLOW ]] || ALLOW=/dev/null
for f in "$W"/*.find; do
  sed "s|^|$(basename "$f" .find): |" "$f"
done | grep -vEf "$ALLOW" | cat - "$W/errors" \
  | tr -d '\000-\010\013-\037\177' >"$W/report" # strip terminal escapes from untrusted text

[[ -s $W/report ]] || exit 0
cat "$W/report"
echo "logs: $W"
keep=1
grep -qv '^!! ' "$W/report" && exit 1
exit 2
