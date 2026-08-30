{ ... }:
{
  # Every optional feature is imported here and gated behind a `khizar.*`
  # option, so hosts only ever flip booleans — they never pick imports.
  imports = [
    ./compositors
    ./blueferry
    ./gaming.nix
    ./laptop.nix
    ./sunshine.nix
    ./winapps.nix
    ./openlogi.nix
    ./noctalia-greeter.nix
  ];
}
