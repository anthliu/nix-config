{ ... }:

{
  # Enable zram swap (compressed RAM)
  # This is much faster than disk swap and effectively increases your usable RAM.
  zramSwap.enable = true;

  # Performance tuning for swap
  boot.kernel.sysctl = {
    # Low swappiness: strongly prefer RAM/zram, only fall back to disk swap as a last resort.
    "vm.swappiness" = 10;
  };
}
