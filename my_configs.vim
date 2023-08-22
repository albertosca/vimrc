" Basic encoding is basic
set encoding=UTF-8

" Clear trailing whitespaces
autocmd BufWritePre *.* :%s/\s\+$//e

" Highlight cursor line
set cursorline

" column with 90
highlight ColorColumn ctermbg=235 guibg=#2c2d27
let &colorcolumn="100,".join(range(100,999),",")

" Default colorscheme
colorscheme gruvbox
set background=dark    " Setting dark mode
"
" yank to clipboard
set clipboard=unnamed " copy to the system clipboard

" markdown previewr

nnoremap <leader>mdp :CocCommand markdown-preview-enhanced.openPreview<CR>
nnoremap <leader>mdt :CocCommand markdown-preview-enhanced.insertTable<CR>
nnoremap <leader>mdl :CocList --input=markdown-preview-enhanced. commands<CR>

"Sets numbers to be always shown
set nu

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2
set expandtab
set softtabstop=2
set smartindent

" " Move lines up and down using alt+j and alt+k, by @LeandroLM
" execute "set <M-j>=\ej"
" execute "set <M-k>=\ek"
" nnoremap <M-j> :m .+1<CR>==
" nnoremap <M-k> :m .-2<CR>==
" inoremap <M-j> <Esc>:m .+1<CR>==gi
" inoremap <M-k> <Esc>:m .-2<CR>==gi
" vnoremap <M-j> :m '>+1<CR>gv=gv
" vnoremap <M-k> :m '<-2<CR>gv=gv

" Move vim tabs with ctrl+shift+arrow right or left
nnoremap <C-S-h> :tabmove -1<cr>
nnoremap <C-S-l> :tabmove +1<cr>
inoremap <C-S-h> :tabmove -1<cr>
inoremap <C-S-l> :tabmove +1<cr>
vnoremap <C-S-h> :tabmove -1<cr>
vnoremap <C-S-l> :tabmove +1<cr>
nnoremap <C-t> <Esc> :tabe<CR>
inoremap <C-t> <Esc> :tabe<CR>
vnoremap <C-t> <Esc> :tabnew<CR>

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

" Navigate to previous tab
nnoremap gr  :tabprev<CR>

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

" After 90 columns, vim reformats the line for you
" set tw=90

" No default paste mode ruining my visual blocks
set nopaste
command! Vb normal! <C-v>

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

" Copy filename, without and with path
nmap ,cs :let @+=expand("%")<CR>
nmap ,cl :let @+=expand("%:p")<CR>

" Unify clipboards, so visual selection copies in and out of vim
set clipboard=unnamed

" File extensions where tags are auto closed
let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.php,*.jsx,*.js,*.erb"

" Ale linter personal configs
augroup FiletypeGroup
    autocmd!
    au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
augroup END

let g:ale_linter_aliases = {'jsx': 'css'}
let g:ale_linters = {
\   'javascript': ['eslint', 'prettier', 'jshint'],
\   'jsx': ['eslint', 'stylelint', 'tslint', 'tsserver'],
\   'typescript': ['tslint', 'tsserver', 'eslint'],
\   'css': ['csslint', 'prettier'],
\   'scss': ['scss-lint'],
\   'python': ['flake8'],
\   'go': ['go', 'golint', 'errcheck'],
\   'elixir': ['credo'],
\   'graphql': ['eslint'],
\   'ruby': ['rubocop']
\}

nmap <silent> <leader>a <Plug>(ale_next_wrap)

" -- Enabling highlighting
let g:ale_set_highlights = 1

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\}

" -- Rub linting all the timeish
" let g:ale_lint_on_text_changed = 'always'
" let g:ale_lint_on_enter = 1
" let g:ale_lint_delay = get(g:, 'ale_lint_delay', 200)
let g:ale_fix_on_save = 1

" Configuring vim mix format
let g:mix_format_on_save = 1
nmap <Leader>mf :MixFormat<CR>
nmap <Leader>md :MixFormatDiff<CR>

" Vim test
let test#strategy = "vimux"
nmap <Leader>tn :TestNearest<CR>
nmap <Leader>tf :TestFile<CR>
nmap <Leader>ts :TestSuite<CR>
nmap <Leader>tl :TestLast<CR>
nmap <Leader>tv :TestVisit<CR>

" Remove warning due to old vim version
let g:go_version_warning = 0

" Do not want autocomplete
let g:ale_completion_enabled = 0
call ale#completion#Disable()
inoremap <silent><C-a> <C-\><C-O>:call ale#completion#GetCompletions()<CR>

" " Prettier config
" let g:prettier#config#arrow_parens = 'always'
" let g:prettier#quickfix_enabled = 0
" let g:prettier#autoformat = 0
" let g:prettier#config#print_width = 90
" let g:prettier#config#bracket_spacing = 'true'
" autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue,*.yaml,*.html PrettierAsync

" colo ThemerVim
let g:lightline = { 'colorscheme': 'ThemerVimLightline' }





" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~'\s'
endfunction

" " Use tab for trigger completion with characters ahead and navigate.
" " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" " other plugin before putting this into your config.
"
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<TAB>" : coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gR <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Comment highlighting with coc-markdown-previewer
autocmd FileType json syntax match Comment +\/\/.\+$+

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
" Endwise
" disable mapping to not break coc.nvim (I don't even use them anyways)
let g:endwise_no_mappings = 1

let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-css', 'coc-browser', 'coc-docker', 'coc-elixir', 'coc-eslint', 'coc-html', 'coc-java', 'coc-markdownlint', 'coc-prettier', 'coc-sh', 'coc-texlab', 'coc-yaml', 'coc-yank', 'coc-xml', 'coc-rome', 'coc-powershell']

let b:coc_suggest_disable = 1
