# Puts each new Zen window on a tag chosen by the monitor it opened on. A
# windowrule can't do this: `tags:` applies on every monitor alike, and rules
# have no "focused monitor" condition. So rules.conf leaves Zen's tag alone,
# the window maps on the current tag, and this moves it straight after.
#
#   on $1 (PC: DP-1, the Equibop screen) -> stays on the current tag if that
#     tag was empty, otherwise the next empty tag after it (wrapping).
#   anywhere else (or no $1)             -> tag 2, as the old rule did.
#
# `tag,N client,ID` moves the window and switches the view to follow it.

side_mon=${1:-}

place() {
  id=$1
  client=$(mmsg get client "$id")
  mon=$(jq -r '.monitor' <<<"$client")
  cur=$(jq -r '.tags[0]' <<<"$client")

  if [ "$mon" != "$side_mon" ]; then
    mmsg dispatch "tag,2" "client,$id" >/dev/null
    return
  fi

  # client_count per tag, index 1..9; the new window is already counted on $cur.
  mapfile -t counts < <(mmsg get tags "$mon" | jq -r '.tags | sort_by(.index) | .[].client_count')
  n=${#counts[@]}

  [ "${counts[cur - 1]}" -le 1 ] && return

  for ((step = 1; step < n; step++)); do
    t=$(((cur - 1 + step) % n + 1))
    if [ "${counts[t - 1]}" -eq 0 ]; then
      mmsg dispatch "tag,$t" "client,$id" >/dev/null
      return
    fi
  done
}

# The stream re-sends the full client list on every change. The first dump is
# whatever was already open before this started, so only record those.
seen=" "
first=1
mmsg watch all-clients | while IFS= read -r line; do
  for id in $(jq -r '.clients[]? | select(.appid == "zen-beta") | .id' <<<"$line"); do
    case $seen in *" $id "*) continue ;; esac
    seen="$seen$id "
    [ "$first" = 1 ] || place "$id" || true
  done
  first=0
done
