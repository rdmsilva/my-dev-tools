" ==========================================
" Vim Configuration
" ==========================================

" ------------------------------------------
" General Settings
" ------------------------------------------
set number              " Line numbers
set relativenumber      " Relative line numbers
set tabstop=4           " Tab width
set shiftwidth=4        " Indent width
set expandtab           " Tabs to spaces
set autoindent          " Auto indent
set smartindent         " Smart indent
set wrap                " Wrap lines
set linebreak           " Break at word boundary
set scrolloff=8         " Keep 8 lines visible
set sidescrolloff=15
set mouse=a             " Mouse support
set clipboard=unnamedplus " System clipboard
set hidden              " Hide buffers
set ignorecase          " Case insensitive search
set smartcase           " Unless uppercase used
set incsearch           " Incremental search
set hlsearch            " Highlight search
set showmatch           " Show matching brackets
set matchtime=2
set wildmenu            " Command line completion
set wildmode=list:longest
set ruler               " Show cursor position
set showcmd             " Show command
set backspace=indent,eol,start
set splitbelow
set splitright
set encoding=utf-8
set fileencoding=utf-8
set t_Co=256            " 256 colors
set cursorline          " Highlight current line
set termguicolors       " True colors

" ------------------------------------------
" Plugin Manager (vim-plug)
" ------------------------------------------
call plug#begin('~/.vim/plugged')

" File explorer
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

" IntelliSense / LSP
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Surround
Plug 'tpope/vim-surround'

" Colorscheme
Plug 'morhetz/gruvbox'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Comment
Plug 'tpope/vim-commentary'

" Auto pairs
Plug 'jiangmiao/auto-pairs'

call plug#end()

" ------------------------------------------
" Colorscheme
" ------------------------------------------
colorscheme gruvbox
set background=dark

" ------------------------------------------
" Plugin Settings
" ------------------------------------------

" NERDTree
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeGitStatusShowIgnored = 1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" FZF
let g:fzf_layout = { 'down': '~40%' }

" CoC
let g:coc_global_extensions = [
    \ 'coc-json',
    \ 'coc-tsserver',
    \ 'coc-python',
    \ 'coc-eslint',
    \ 'coc-prettier',
    \ 'coc-git',
    \ ]

" Airline
let g:airline_theme='gruvbox'
let g:airline_powerline_fonts = 1

" ------------------------------------------
" Key Mappings
" ------------------------------------------

" Leader
let mapleader = " "

" NERDTree toggle
map <leader>n :NERDTreeToggle<CR>

" FZF files
nnoremap <leader>p :Files<CR>
nnoremap <leader>b :Buffers<CR>

" FZF grep
nnoremap <leader>g :Rg<CR>

" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize windows
nnoremap <leader>w+ <C-w>+
nnoremap <leader>w- <C-w>-
nnoremap <leader>w> <C-w>>
nnoremap <leader>w< <C-w><

" Save with leader + s
nnoremap <leader>s :w<CR>

" Quit with leader + q
nnoremap <leader>q :q<CR>

" Clear search highlight
nnoremap <leader><space> :nohlsearch<CR>

" ------------------------------------------
" Auto commands
" ------------------------------------------

" Highlight yank
augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup END

" Remove trailing whitespace on save
augroup TrimWhitespace
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
augroup END
