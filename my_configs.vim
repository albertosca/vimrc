"Clear trailing whitespaces
autocmd BufWritePre *.* :%s/\s\+$//e

"Highlight cursor line
set cursorline

" column with 90
highlight ColorColumn ctermbg=235 guibg=#2c2d27
let &colorcolumn="90,".join(range(90,999),",")

"autocmd BufWritePre *.* :%s/\t/  /g

"Sets numbers to be always shown
set nu

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2
set expandtab
set softtabstop=2
set smartindent

"Multiple cursors net key
let g:multi_cursor_next_key="<C-n>"

"Git gutter
let g:gitgutter_enabled=1

" shortcuts for changing windows
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

" scrolling
set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

" Search highligh toggle
set hlsearch!
nnoremap <F3> :set hlsearch!<CR>

" Pretty fonts and icons
set encoding=utf8
set guifont=Font\ Awesome\ 14
let g:airline_powerline_fonts=1

" Enable folding
set foldenable
set foldmethod=indent
set foldlevel=1
au BufRead * normal zR

" After 80 columns, vim reformats the line for you
set tw=80

" No default paste mode ruining my visual blocks
:set nopaste

" Codeclimate
nmap <Leader>af :CodeClimateAnalyzeCurrentFile<CR>

" Nerdtree opening on left
let g:NERDTreeWinPos = "left"

" JSX syntax in .js files
let g:jsx_ext_required = 0

" Configuring syntastic to use ESLint
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'