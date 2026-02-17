{ lib, stdenv, pciutils, cudaPackages, addDriverRunpath }:

stdenv.mkDerivation {
  pname = "gputemps";
  version = "unstable-2025-01-01";

  src = ./.;

  nativeBuildInputs = [ addDriverRunpath ];

  buildInputs = [
    pciutils
    cudaPackages.cuda_nvml_dev
  ];

  buildPhase = ''
    gcc gputemps.c -o gputemps -O3 -lnvidia-ml -lpci \
      -L${cudaPackages.cuda_nvml_dev.stubs}/lib/stubs \
      -Wl,-rpath,${pciutils}/lib
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp gputemps $out/bin/
  '';

  # Patch the binary to find libnvidia-ml.so at runtime from the driver runpath
  postFixup = ''
    addDriverRunpath $out/bin/gputemps
  '';

  meta = with lib; {
    description = "Core, Junction, and VRAM temperature reader for GDDR6/GDDR6X GPUs";
    homepage = "https://github.com/ThomasBaruzier/gddr6-core-junction-vram-temps";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "gputemps";
  };
}
