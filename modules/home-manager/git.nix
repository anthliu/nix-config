{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    
    settings = {
      init.defaultBranch = "main";
      user.name = "Anthony Liu";
      user.email = "anthzliu@gmail.com.com";
      # safe.directory = "/home/anthliu/nix-config"; # useful if git complains about ownership
    };
  };
}
