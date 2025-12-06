set paste
set mouse-=a
set t_md=
set hlsearch
set incsearch
set lazyredraw
set tabstop=4
set shiftwidth=4
set expandtab

syntax enable
filetype plugin on
syntax match Todo /\v<(TODO|FIXME|NOTE|BUG)>/

highlight MatchParen ctermfg=black ctermbg=yellow
highlight Comment cterm=italic ctermfg=gray
highlight Error cterm=bold,underline ctermfg=red
highlight CurSearch ctermfg=black ctermbg=cyan
highlight Todo ctermbg=blue ctermfg=red

