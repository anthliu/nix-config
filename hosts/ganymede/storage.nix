{
  fileSystems."/mnt/memspace" = {
    device = "/dev/disk/by-label/memspace";
    fsType = "btrfs";
    options = [
      "nofail"
      "x-gvfs-show"
    ];
  };
}
