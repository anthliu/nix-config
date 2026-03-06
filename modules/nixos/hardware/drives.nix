{
  fileSystems."/mnt/memspace" = {
    device = "/dev/disk/by-label/memspace";
    fsType = "btrfs";
    options = [
      "nofail"        # Don't block boot if the drive is missing
      "x-gvfs-show"   # Show in Thunar / file manager side panel
    ];
  };
}
