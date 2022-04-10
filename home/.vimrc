"""" Search

" Enable real time search
set incsearch

" Case insensitive
set ignorecase

" Hight light search result
set hlsearch

"""" Vim Self

" Use vim feature
set nocompatible

" Vim command auto complete with TAB
set wildmenu

" Show line number
set number

" High light current line
set cursorline

" Put vertical line at 80 and 120
set colorcolumn=80,120

" Set cursorcolumn
set ruler

" Keep 2 lines on top/bottom before scroll page
set scrolloff=2

" High light matched braces
set showmatch

" Use mouse all the time
set mouse=a

set path+=**

"""" Skin

colorscheme desert


"""" Code Related

" Enable syntax
syntax enable

" Enable syntax overwrite
syntax on

" Indent for filetype
filetype indent on

" Tag path
set tags=./tags;,tags

" Terminal
set termwinsize=5*0


"""" Themes

" colorscheme koehler

"""" Terminal

" Force color type to be 256
set t_Co=256


"""" Plug Start

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.

" AirLine
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Tmux Line
Plug 'edkolev/tmuxline.vim'

" Tagbar
Plug 'majutsushi/tagbar'

" NerdTree
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'

" ALE
" Plug 'dense-analysis/ale'

" Version Control
Plug 'airblade/vim-gitgutter'

" For AirLine Status Bar show the branch information
Plug 'tpope/vim-fugitive'

" Gtags-Cscope
Plug 'miyatsu/vim-gtags-cscope'

" Vista
Plug 'liuchengxu/vista.vim'

"Auto Pairs
Plug 'jiangmiao/auto-pairs'

" YouCompleteMe
Plug 'ycm-core/YouCompleteMe', { 'do': 'python3 install.py --clangd-completer' }

" List ends here. Plugins become visible to Vim after this call.
call plug#end()


"""""""" Plug config gose here

"""" Air Line

"" Status line

"" Tabline

" Enable enhanced tabline. (c)
let g:airline#extensions#tabline#enabled = 1

" Tab number show as tab numbers
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number

" Show buffer index
let g:airline#extensions#tabline#buffer_idx_mode = 1

"""" Air Line Themes
let g:airline_theme = 'ouo'

"""" Tagbar

" Set width with 30, default 40
let g:tagbar_width = 30

" Automatic open tagbar for every buffer
autocmd BufEnter * nested :call tagbar#autoopen(0)

"""" Gtags-Cscope

" To use the default key/mouse mapping:
let g:GtagsCscope_Auto_Map = 1
" To ignore letter case when searching:
let g:GtagsCscope_Ignore_Case = 1
" To use absolute path name:
let g:GtagsCscope_Absolute_Path = 1
" To deterring interruption:
let g:GtagsCscope_Keep_Alive = 1
" If you hope auto loading:
let g:GtagsCscope_Auto_Load = 1
" To use 'vim -t ', ':tag' and '<C-]>'
set cscopetag

"""" NERDTree

" Set Window Size, default 31
let g:NERDTreeWinSize = 25

" Open file in tab when <CR>, open dir remain unchanged
let g:NERDTreeCustomOpenArgs = {'file':{'where': 't'}, 'dir':{}}

"""" NERDTree Tab

" Open NERDTree Tab Automaticly
let g:nerdtree_tabs_open_on_console_startup = 1

"""" YouCompleteMe

" Disable ask me load ycm_config.py every time
let g:ycm_confirm_extra_conf = 0

