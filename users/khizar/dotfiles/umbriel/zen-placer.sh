# Puts each new Zen window on a workspace chosen by the monitor it opened on. A
# window rule can't do this: `default_workspace` applies on every monitor alike, and
# rules have no "focused monitor" condition. So the rules leave Zen's workspace
# alone, the window maps on the current one, and this moves it straight after.
#
#   on $1 (PC: DP-1, the Equibop screen) -> stays on the current workspace if that
#     was empty, otherwise the next empty workspace after it (wrapping).
#   anywhere else (or no $1)             -> workspace 2, as the old rule did. With
#     $2 that means workspace 2 of output $2 (laptop: eDP-1's "net", which is where
#     niri-zen-placer sends it); without, of the monitor it opened on.
#
# window-move-to-workspace acts on the focused window and switches the view to
# follow it, so the window is focused first.

side_mon=${1:-}
home_mon=${2:-}

move() {
  umbriel msg window-focus "$1" >/dev/null
  umbriel msg window-move-to-workspace "$2" --output "$3" >/dev/null
}

place() {
  id=$1
  window=$(umbriel windows --json | jq -c --arg id "$id" '.[] | select(.id == $id)')
  [ -n "$window" ] || return 0
  mon=$(jq -r '.output' <<<"$window")

  if [ "$mon" != "$side_mon" ]; then
    move "$id" 2 "${home_mon:-$mon}"
    return
  fi

  workspace=$(jq -r '.workspace' <<<"$window")
  workspaces=$(umbriel workspaces --json | jq -c --arg mon "$mon" '[.[] | select(.output == $mon)] | sort_by(.index)')
  cur=$(jq -r --arg id "$workspace" '.[] | select((.id | tostring) == $id) | .index' <<<"$workspaces")

  # window_count per workspace, index 1..9; the new window is already counted on $cur.
  mapfile -t counts < <(jq -r '.[].window_count' <<<"$workspaces")
  n=${#counts[@]}

  [ "${counts[cur - 1]}" -le 1 ] && return

  for ((step = 1; step < n; step++)); do
    t=$(((cur - 1 + step) % n + 1))
    if [ "${counts[t - 1]}" -eq 0 ]; then
      move "$id" "$t" "$mon"
      return
    fi
  done
}

# The stream re-sends every window on each change. The first dump is whatever was
# already open before this started, so only record those.
seen=" "
first=1
umbriel subscribe windows |
  jq --unbuffered -r '[.data[]? | select(.app_id == "zen-beta") | .id] | join(" ")' |
  while IFS= read -r ids; do
    for id in $ids; do
      case $seen in *" $id "*) continue ;; esac
      seen="$seen$id "
      [ "$first" = 1 ] || place "$id" || true
    done
    first=0
  done
