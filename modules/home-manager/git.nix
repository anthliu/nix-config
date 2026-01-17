{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Anthony Liu";
    userEmail = "anthzliu@gmail.com.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      # safe.directory = "/home/anthliu/nix-config"; # useful if git complains about ownership
    };
  };
}
