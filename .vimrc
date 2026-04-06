" ---------------- Core ----------------
set nocompatible
set encoding=utf-8
set fileencoding=utf-8
set history=1000
set hidden
set ttyfast
set lazyredraw

" ---------------- UI ----------------
set number
set ruler
set showcmd
set cursorline
set nowrap
set laststatus=2
set wildmenu
set wildmode=longest:full,full
set mouse=

" ---------------- Indentation ----------------
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

" ---------------- Search ----------------
set ignorecase
set smartcase
set incsearch
set hlsearch

" ---------------- Whitespace ----------------
set list
set listchars=tab:▸\ ,trail:·,nbsp:␣

" ---------------- Syntax ----------------
syntax on
filetype plugin indent on

" ==========================================================
" Python
" ==========================================================
augroup python_cfg
    autocmd!
    autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab textwidth=88 colorcolumn=89
    autocmd FileType python nnoremap <buffer> <F5> :w<CR>:!uv run  %<CR>
    autocmd FileType python nnoremap <buffer> <F6> :w<CR>:!python3 -m py_compile %<CR>
augroup END

" ==========================================================
" Bash / Shell
" ==========================================================
augroup sh_cfg
    autocmd!
    autocmd FileType sh,bash setlocal tabstop=4 shiftwidth=4 expandtab
    autocmd BufWritePost *.sh silent !chmod +x %
    autocmd FileType sh,bash nnoremap <buffer> <F5> :w<CR>:!./%<CR>
    autocmd FileType sh,bash nnoremap <buffer> <F6> :w<CR>:!bash -n %<CR>
augroup END

" ==========================================================
" systemd units
" ==========================================================
augroup systemd_cfg
    autocmd!
    autocmd BufRead,BufNewFile *.service,*.timer,*.socket,*.mount,*.target setfiletype systemd
    autocmd FileType systemd setlocal tabstop=2 shiftwidth=2 expandtab commentstring=#\ %s
    autocmd FileType systemd nnoremap <buffer> <F5> :w<CR>:!systemctl daemon-reload<CR>
    autocmd FileType systemd nnoremap <buffer> <F6> :w<CR>:!systemd-analyze verify %<CR>
augroup END

" ==========================================================
" TOML
" ==========================================================
augroup toml_cfg
    autocmd!
    autocmd BufRead,BufNewFile *.toml setfiletype toml
    autocmd FileType toml setlocal tabstop=2 shiftwidth=2 expandtab
augroup END

