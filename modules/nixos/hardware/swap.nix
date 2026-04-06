{ ... }:

{
  # Enable zram swap (compressed RAM)
  # This is much faster than disk swap and effectively increases your usable RAM.
  zramSwap.enable = true;

  # Small swapfile as a last-resort OOM safety net.
  # zram handles everyday memory pressure; this only kicks in when zram is exhausted.
  # Since we are on Btrfs, NixOS will handle the 'nocow' attribute automatically.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024; # 8GB
    }
  ];

  # Performance tuning for swap
  boot.kernel.sysctl = {
    # Low swappiness: strongly prefer RAM/zram, only fall back to disk swap as a last resort.
    "vm.swappiness" = 10;
  };
}
