#!/usr/bin/env zsh

# If at home replace tailscale ip with this one: earthian@192.168.1.81:~/homelab
# - before '--archive' flag i had '--recursive --times'
# - if adding '--info=progress2' add ONLY this info flag as mixed with any other
#   ones it turns to be a mess
# - if just want to see more info add --verbove (increases verbocity by one) and
#   it is essentially the '--info=' flag with sane params for all the info you
#   need. Run `rsync --info=help' to see all flags and levels`
alias rsync_archive='my-rsync "earthian@100.95.49.75"'
alias rsync_archive_local='my-rsync "earthian@192.168.1.81"'
alias rsync_archive_dry='rsync --archive --itemize-changes --dry-run --exclude=.stversions --delete ~/mem-arch/ earthian@100.95.49.75:~/archive'

my-rsync() {
  # fuzzy params explanation:
  # https://serverfault.com/questions/489289/handling-renamed-files-or-directories-in-rsync
  rsync --archive --info=progress2 --exclude=.stversions \
    --fuzzy --delay-updates --delete-delay \
    --delete ~/mem-arch/ "$1:~/archive"
}
