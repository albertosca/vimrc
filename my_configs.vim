" Basic encoding is basic
set encoding=utf8

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

" =============================================================================
" Ruby & Rails Configuration
" =============================================================================
" Navigation handled by vim-rails (use :A, :Rmodel, :Rcontroller)
let g:ruby_host_prog = 'ruby' " Ensure ruby is in path

" Vim test for Ruby
let test#ruby#rspec#executable = 'bundle exec rspec'

" =============================================================================
" Node.js, React & Web Configuration
" =============================================================================
" coc-tsserver handles JS/TS/JSX/TSX
" coc-emmet for fast HTML/JSX expansions
autocmd FileType html,css,javascriptreact,typescriptreact emmet+

" Ensure JSX is recognized in .js files
autocmd BufNewFile,BufRead *.jsx set filetype=javascriptreact
autocmd BufNewFile,BufRead *.tsx set filetype=typescriptreact

" =============================================================================
" Database Configuration (SQL)
" =============================================================================
" Use vim-dadbod to run queries (SQL results in a split)
" Usage: :DB g:my_db_url SELECT * FROM users LIMIT 10
" URLs: postgres://user:pass@localhost:5432/db_name
"       mysql://user:pass@localhost:3306/db_name

" =============================================================================
" Elixir Configuration
" =============================================================================
" Use coc-elixir for LSP (already in coc_global_extensions)
" Syntax highlighting is handled by vim-elixir

" Configuring vim mix format
let g:mix_format_on_save = 1
nmap <Leader>mf :MixFormat<CR>
nmap <Leader>md :MixFormatDiff<CR>

" Vim test for Elixir
let test#elixir#exunit#executable = 'mix test'
let test#strategy = "vimux"

" Vimux: Utility mappings
nmap <Leader>vp :VimuxPromptCommand<CR>
nmap <Leader>vl :VimuxRunLastCommand<CR>
nmap <Leader>vq :VimuxCloseRunner<CR>
nmap <Leader>vx :VimuxInterruptRunner<CR>

" Elixir: Run Credo for strict linting
nmap <Leader>lc :call VimuxRunCommand("mix credo --strict")<CR>

" Elixir: Open IEx REPL in a split
nmap <Leader>ie :call VimuxRunCommand("iex -S mix")<CR>

" Elixir: Projectionist configurations (switching between lib and test)
let g:projectionist_heuristics = {
      \ "mix.exs": {
      \   "lib/*.ex": {"alternate": "test/{}_test.exs", "type": "source"},
      \   "test/*_test.exs": {"alternate": "lib/{}.ex", "type": "test"}
      \ }}

" Elixir: Surround mappings for 'do ... end'
" Usage: 'ysiw d' to wrap a word in do/end
let g:surround_100 = "do\r\nend"

" Auto-format Elixir files using CoC or mix format
autocmd BufWritePre *.ex,*.exs,*.heex silent! call CocAction('format')

" =============================================================================
" Pretty fonts and icons
" =============================================================================
set guifont=Font\ Awesome\ 14
let g:airline_powerline_fonts=1

" Enable folding via CoC (much faster than indent)
set foldmethod=manual
set foldlevel=99
augroup coc_folding
  autocmd!
  autocmd FileType typescript,json,javascript,python,go,elixir setl formatexpr=CocAction('formatSelected')
augroup end

" Disable legacy syntastic/ALE to let CoC handle everything via LSP
let g:syntastic_javascript_checkers = []
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

" Better performance for CoC
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
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

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif


" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>

" Jump to definition with Ctrl+] (LSP aware)
nmap <silent> <C-]> <Plug>(coc-definition)

" Jump back with Ctrl+t (Reverse jump)
nmap <silent> <C-t> <C-o>

" macOS specific shortcuts (Cmd+] and Cmd+[)
if has("mac") || has("macunix")
  nmap <silent> <D-]> <Plug>(coc-definition)
  nmap <silent> <D-[> <C-o>
endif
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

let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-css', 'coc-browser', 'coc-docker', 'coc-elixir', 'coc-eslint', 'coc-html', 'coc-java', 'coc-markdownlint', 'coc-prettier', 'coc-sh', 'coc-texlab', 'coc-yaml', 'coc-yank', 'coc-xml', 'coc-rome', 'coc-powershell', 'coc-solargraph', 'coc-emmet', 'coc-sql']

" Auto-pairs: Disable auto-pairing if the next character is a word character
" This prevents '(' becoming '()' when typed right before a word
let g:AutoPairsNextClosedPair = ''
let g:AutoPairsShortcutToggle = '<C-p>' " Allow toggling with Ctrl+p

let b:coc_suggest_disable = 1
