{ ... }:

{
  # GPU control daemon (nixpkgs module provides the package and lactd unit)
  services.lact.enable = true;
}
