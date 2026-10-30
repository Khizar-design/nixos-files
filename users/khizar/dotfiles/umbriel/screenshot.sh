# niri's screenshot, screenshot-screen and screenshot-window for the laptop binds.
# Each saves to niri's screenshot-path and copies the image to the clipboard.

path=~/Pictures/Screenshots/$(date +%Y-%m-%dT%H:%M:%S).png
mkdir -p "$(dirname "$path")"

case ${1:-} in
  region)
    # Cancelling slurp exits here, before anything is written.
    geometry=$(slurp)
    grim -g "$geometry" - | tee "$path" | wl-copy
    ;;
  screen)
    output=$(umbriel outputs --json | jq -r '.[] | select(.focused) | .name')
    grim -o "$output" - | tee "$path" | wl-copy
    ;;
  window)
    geometry=$(umbriel focused-window --json | jq -r '"\(.x),\(.y) \(.w)x\(.h)"')
    grim -g "$geometry" - | tee "$path" | wl-copy
    ;;
  *)
    echo "usage: umbriel-screenshot region|screen|window" >&2
    exit 1
    ;;
esac
