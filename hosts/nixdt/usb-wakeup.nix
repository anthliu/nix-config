{ pkgs, ... }:

{
  # Disable wakeup for all USB devices to prevent random wakeups
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"
  '';
}
