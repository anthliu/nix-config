{ pkgs, inputs, ... }:

{
  imports = [
  ];

  home.packages = with pkgs; [
    gcc
    uv
    qmk
    dos2unix
    (python313.withPackages (ps: [ ps.tkinter ]))

    # AI Tools
    llama-cpp
    inputs.claude-code.packages.${pkgs.system}.default
    gemini-cli
    opencode
    lmstudio
    nvtopPackages.full

    # LaTeX (CLI tools: full install to include enumitem, etc.)
    texliveFull
    poppler-utils # utils for agents to read pdf
  ];
}
