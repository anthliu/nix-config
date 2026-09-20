{
  # Europa has no disk swap partition, so retain a small fallback behind zram.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];
}
