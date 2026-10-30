# mango's `zoom`: promote the focused window to master. Umbriel has no action for
# that, but a stack window's left neighbour is the master, so swapping left does it.
# Scrolling gets niri's Mod+C, center-column, which is what the bind began as.

layout=$(umbriel workspaces --json | jq -r '.[] | select(.focused) | .layout')

case $layout in
  master) exec umbriel msg window-swap-left ;;
  scrolling) exec umbriel msg column-center ;;
esac
