{ inputs, ... }:

{
  imports = [ inputs.dms.nixosModules.default ];

  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };
}
