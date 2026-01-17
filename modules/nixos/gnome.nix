{ pkgs, ... }:

{
  # --- X11 & GNOME ---
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- Audio (Pipewire is the modern standard) ---
  # If you had PulseAudio enabled before, Pipewire is generally better now
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- GUI Apps ---
  programs.firefox.enable = true;
  
  # Gnome needs dconf for saving settings
  programs.dconf.enable = true; 
}
