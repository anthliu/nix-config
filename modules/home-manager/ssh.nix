{ pkgs, ... }:

{
  programs.ssh = {
    enable = true;

    # If you find SSH stops working for other servers, comment this line out.
    enableDefaultConfig = false; 

    matchBlocks = {
      # Settings here apply to every SSH connection
      "*" = {
        # Using 'extraOptions' ensures it writes the raw config line safely.
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/home/anthliu/.ssh/id_ed25519"; 
      };
    };
  };
}
