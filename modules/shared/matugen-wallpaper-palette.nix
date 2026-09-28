{
  config,
  lib,
  pkgs,
  ...
}:

let
  wallpaper = config.stylix.image;
  # Stylix reads this during evaluation, as it does for its own image palette
  # generator. Nix caches the result until the wallpaper or tools change.
  palette =
    pkgs.runCommand "matugen-wallpaper-stylix.json"
      {
        inherit wallpaper;
        nativeBuildInputs = [
          pkgs.matugen
          pkgs.python3
        ];
      }
      ''
        matugen image "$wallpaper" \
          -m dark -t scheme-tonal-spot --source-color-index 0 \
          --json hex --dry-run --old-json-output > material.json

        python3 ${../../scripts/matugen-to-stylix.py} material.json > "$out"
      '';
in
{
  stylix.base16Scheme = lib.mkForce (lib.importJSON palette);
  stylix.polarity = lib.mkForce "dark";
}
