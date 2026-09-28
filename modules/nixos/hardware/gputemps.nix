{
  pkgs,
  ...
}:

let
  gputemps = pkgs.callPackage ../../../packages/gputemps { };
in
{
  # The utility reads GPU registers through /dev/mem. Run it only in a
  # constrained root service and publish an unprivileged JSON snapshot instead
  # of exposing the binary itself through a setuid wrapper.
  boot.kernelParams = [ "iomem=relaxed" ];

  environment.systemPackages = [
    pkgs.pciutils
    gputemps
  ];

  systemd.services.gputemps = {
    description = "Publish NVIDIA GPU temperature data";
    wantedBy = [ "multi-user.target" ];
    after = [ "nvidia-persistenced.service" ];
    serviceConfig = {
      RuntimeDirectory = "gputemps";
      RuntimeDirectoryMode = "0755";
      Restart = "always";
      RestartSec = "5s";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RestrictSUIDSGID = true;
    };
    script = ''
      while true; do
        next="$RUNTIME_DIRECTORY/temps.json.next"
        if ${gputemps}/bin/gputemps --json --once > "$next"; then
          ${pkgs.coreutils}/bin/chmod 0644 "$next"
          ${pkgs.coreutils}/bin/mv -f "$next" "$RUNTIME_DIRECTORY/temps.json"
        fi
        ${pkgs.coreutils}/bin/sleep 3
      done
    '';
  };
}
