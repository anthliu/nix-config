{ stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "gputemps-dms-plugin";
  version = "1.0.0";

  src = ./.;

  installPhase = ''
    mkdir -p $out/share/dms-plugins/gpuTemps
    cp plugin.json $out/share/dms-plugins/gpuTemps/
    cp GpuTempsWidget.qml $out/share/dms-plugins/gpuTemps/
  '';

  meta = {
    description = "DMS-Shell plugin for GPU temperature monitoring via gputemps";
  };
}
