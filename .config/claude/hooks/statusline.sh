#!/bin/bash
# Claude Code status line. Reads session JSON on stdin.
in=$(cat)

IFS=$'\t' read -r model effort dir ctx cost added removed h5 h5_reset d7 d7_reset wt <<<"$(jq -r '[
  .model.display_name // "?",
  .effort.level // "-",
  .workspace.current_dir // .cwd,
  (.context_window.used_percentage // 0),
  (.cost.total_cost_usd // 0),
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // ""),
  (.worktree.name // .workspace.git_worktree // "")
] | @tsv' <<<"$in")"

dim=$'\033[2m' red=$'\033[31m' yel=$'\033[33m' grn=$'\033[32m' cyan=$'\033[36m' rst=$'\033[0m'
sep=" ${dim}|${rst} "

# green <50, yellow <80, red >=80
pct_color() { local p=${1%.*}; ((p >= 80)) && echo "$red" || { ((p >= 50)) && echo "$yel" || echo "$grn"; }; }

root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo "$dir")
out="${cyan}${model}${rst} · ${effort}${sep}${root##*/}"

if branch=$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null); then
  dirty=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l)
  out+="${sep}⎇ ${branch}"
  [ -n "$wt" ] && out+=" (wt:${wt})"
  ((dirty > 0)) && out+=" ${yel}●${dirty}${rst}"
fi

out+="${sep}ctx $(pct_color "$ctx")${ctx}%${rst}"
out+="${sep}\$$(printf '%.2f' "$cost")"
out+="${sep}${grn}+${added}${rst} ${red}-${removed}${rst}"

if [ -n "$h5" ]; then
  out+="${sep}5h $(pct_color "$h5")${h5%.*}%${rst} ${dim}↻$(date -d "@$h5_reset" +%H:%M)${rst}"
fi
if [ -n "$d7" ]; then
  out+=" · 7d $(pct_color "$d7")${d7%.*}%${rst} ${dim}↻$(date -d "@$d7_reset" '+%a %H:%M')${rst}"
fi

printf '%s' "$out"
