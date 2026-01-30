{ pkgs, ... }:

{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      " === General Settings ===
      set nocompatible
      set history=1000
      set encoding=utf-8
      set visualbell
      set backspace=indent,eol,start
      set mouse=a

      " === UI & Appearance ===
      syntax on
      set guifont=Monospace:h10
      filetype plugin indent on
      set number
      set relativenumber
      set laststatus=2
      set showcmd
      set ruler
      set showmode
      set confirm
      set t_Co=256

      " === Tab & Indent ===
      set expandtab
      set softtabstop=2
      set shiftwidth=2
      set autoindent
      let g:python_recommended_style = 0

      " === Search ===
      set ignorecase
      set smartcase
      set incsearch

      " === Mappings ===
      let mapleader = ","
      map Y y$
      imap fd <Esc>
      " Quick save/make
      nnoremap <leader>m :silent make\|redraw!\|cc<CR>

      " === Backups & Undo ===
      " Store all persistent files in ~/.local/state/vim to avoid git clutter
      set backup
      set undofile
      set noswapfile " Swaps are often more annoying than useful now, but if you want them:
      " set swapfile 

      set backupdir=~/.local/state/vim/backup//
      set undodir=~/.local/state/vim/undo//
      set directory=~/.local/state/vim/swap//

      " === Wildmenu ===
      set wildmenu
      set wildmode=longest,list,full
      set wildignore+=*/tmp/*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
      set completeopt=menuone,menu,longest

      " === Autocmds ===
      autocmd BufNewFile,BufRead *.tex set syntax=context
    '';
  };

  # Ensure directories exist (managed by Home Manager)
  # This is cross-platform and cleaner than manual mkdir in VimScript
  home.file = {
    ".local/state/vim/backup/.keep".text = "";
    ".local/state/vim/undo/.keep".text = "";
    ".local/state/vim/swap/.keep".text = "";
  };
}
