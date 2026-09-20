{ config, ... }:

{
  # Ganymede-specific power policy for its RTX 3090. Keeping this outside the
  # generic NVIDIA module prevents it from being inherited by another GPU.
  systemd.services.nvidia-power-tuning = {
    description = "NVIDIA RTX 3090 power configuration";
    wantedBy = [ "multi-user.target" ];
    after = [ "nvidia-persistenced.service" ];
    script = ''
      nvidia_smi="${config.hardware.nvidia.package.bin}/bin/nvidia-smi"
      "$nvidia_smi" -pm 1
      "$nvidia_smi" -pl 330
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
