{ pkgs, lib, options, ... }:

{
  config = lib.mkMerge [
    {
      programs.firefox = {
        enable = true;
        profiles.default = {
          id = 0;
          isDefault = true;
        };
      };
    }
    (lib.mkIf (options ? stylix) {
      stylix.targets.firefox.profileNames = [ "default" ];
    })
  ];
}