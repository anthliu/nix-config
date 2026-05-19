{ pkgs, ... }:

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
    claude-code
    gemini-cli
    opencode
    lmstudio
    nvtopPackages.full

    # LaTeX (CLI tools: full install to include enumitem, etc.)
    texliveFull
    poppler-utils # utils for agents to read pdf
  ];
}
