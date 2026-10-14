# niri port of mango/zen-placer.sh. Puts each new Zen window on a workspace
# chosen by the monitor it opened on. A window rule can't do this: rules have no
# "focused monitor" condition, and open-on-workspace "net" would drag a Zen
# window opened on the side screen over to the main one.
#
#   on $1 (PC: DP-1, the Equibop screen) -> stays on the current workspace if it
#     was empty, otherwise the next empty workspace after it on DP-1 (wrapping).
#   anywhere else (or no $1)             -> "net", as the old rule did.
#
# Moves pass --focus true, so the view follows the window like mango's
# `tag,N client,ID`.

side_mon=${1:-}

place() {
  id=$1
  ws_id=$2
  workspaces=$(niri msg --json workspaces)
  mon=$(jq -r --argjson w "$ws_id" '.[] | select(.id == $w) | .output' <<<"$workspaces")

  if [ "$mon" != "$side_mon" ]; then
    niri msg action move-window-to-workspace --window-id "$id" --focus true net >/dev/null
    return
  fi

  # Window count per workspace on this monitor, in index order (idx is 1-based
  # and per-output). The new window is already counted on its own workspace.
  windows=$(niri msg --json windows)
  mapfile -t ids < <(jq -r --arg m "$mon" '[.[] | select(.output == $m)] | sort_by(.idx) | .[].id' <<<"$workspaces")
  n=${#ids[@]}
  counts=()
  cur=0
  for ((i = 0; i < n; i++)); do
    counts[i]=$(jq --argjson w "${ids[i]}" '[.[] | select(.workspace_id == $w)] | length' <<<"$windows")
    [ "${ids[i]}" = "$ws_id" ] && cur=$((i + 1))
  done
  [ "$cur" -eq 0 ] && return

  [ "${counts[cur - 1]}" -le 1 ] && return

  for ((step = 1; step < n; step++)); do
    t=$(((cur - 1 + step) % n + 1))
    if [ "${counts[t - 1]}" -eq 0 ]; then
      # A bare index resolves against the window's own monitor.
      niri msg action move-window-to-workspace --window-id "$id" --focus true "$t" >/dev/null
      return
    fi
  done
}

# The stream opens with WindowsChanged, listing whatever was already open before
# this started; only record those. After that, WindowOpenedOrChanged fires for
# new windows and every change to existing ones, hence the seen list.
seen=" "
niri msg --json event-stream | while IFS= read -r line; do
  case $line in
    *'"WindowsChanged"'*)
      for id in $(jq -r '.WindowsChanged.windows[] | select(.app_id == "zen-beta") | .id' <<<"$line"); do
        seen="$seen$id "
      done
      ;;
    *'"WindowOpenedOrChanged"'*)
      read -r id app ws < <(jq -r '.WindowOpenedOrChanged.window | "\(.id) \(.app_id) \(.workspace_id)"' <<<"$line")
      [ "$app" = "zen-beta" ] || continue
      case $seen in *" $id "*) continue ;; esac
      seen="$seen$id "
      [ "$ws" = "null" ] || place "$id" "$ws" || true
      ;;
  esac
done
