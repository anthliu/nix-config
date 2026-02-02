{ ... }:

{
  # Enable zram swap (compressed RAM)
  # This is much faster than disk swap and effectively increases your usable RAM.
  zramSwap.enable = true;

  # Add a 16GB swap file for extreme cases (OOM prevention)
  # Since we are on Btrfs, NixOS will handle the 'nocow' attribute automatically.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024; # 16GB
    }
  ];

  # Performance tuning for swap
  boot.kernel.sysctl = {
    # Increase swappiness to prefer zram over disk swap (initially)
    # Higher values make the kernel more aggressive at swapping.
    "vm.swappiness" = 100;
  };
}
