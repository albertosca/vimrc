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

" Move vim tabs with ctrl+shift+arrow right or left (normal mode only)
nnoremap <C-S-h> :tabmove -1<cr>
nnoremap <C-S-l> :tabmove +1<cr>

"Git gutter
let g:gitgutter_enabled=1

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

" Navigate to previous tab
nnoremap gr  :tabprev<CR>

" scrolling
set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

" Search highlight off by default, F3 to toggle
set nohlsearch
nnoremap <F3> :set hlsearch!<CR>

" Copy current filename (,cs) and full path (,cl) to clipboard
nnoremap <silent> <leader>cs :let @+=expand("%:t")<CR>:echo 'Copied: ' . expand('%:t')<CR>
nnoremap <silent> <leader>cl :let @+=expand("%:p")<CR>:echo 'Copied: ' . expand('%:p')<CR>

" =============================================================================
" Ruby & Rails Configuration
" =============================================================================
let g:ruby_host_prog = 'ruby'

" Vim test for Ruby
let test#ruby#rspec#executable = 'bundle exec rspec'

" =============================================================================
" Node.js, React & Web Configuration
" =============================================================================
" coc-tsserver handles JS/TS/JSX/TSX
" coc-emmet for fast HTML/JSX expansions

" Ensure JSX/TSX filetypes are recognized
augroup JsxTsxFiletypes
  autocmd!
  autocmd BufNewFile,BufRead *.jsx set filetype=javascriptreact
  autocmd BufNewFile,BufRead *.tsx set filetype=typescriptreact
augroup end

" =============================================================================
" Database Configuration (vim-dadbod)
" =============================================================================
" Toggle DB UI explorer
nnoremap <silent> <leader>db :DBUIToggle<CR>
nnoremap <silent> <leader>dba :DBUIAddConnection<CR>
nnoremap <silent> <leader>dbf :DBUIFindBuffer<CR>
nnoremap <silent> <leader>dbr :DBUIRenameBuffer<CR>

" Save queries automatically
let g:db_ui_save_location = '~/.vim_runtime/db_queries'
let g:db_ui_use_nerd_fonts = 1
let g:db_ui_show_database_icon = 1

" dadbod-completion: enable in SQL and dadbod buffers
augroup DadbodCompletion
  autocmd!
  autocmd FileType sql,mysql,plsql call coc#config('suggest.autoTrigger', 'always')
augroup end

" =============================================================================
" Elixir Configuration
" =============================================================================
" Use coc-elixir for LSP (already in coc_global_extensions)
" Syntax highlighting is handled by vim-elixir

" Configuring vim mix format
let g:mix_format_on_save = 1
nnoremap <Leader>mf :MixFormat<CR>
nnoremap <Leader>md :MixFormatDiff<CR>

" Vim test for Elixir
let test#elixir#exunit#executable = 'mix test'
let test#strategy = "vimux"

" Vimux: Utility mappings
nnoremap <Leader>vp :VimuxPromptCommand<CR>
nnoremap <Leader>vl :VimuxRunLastCommand<CR>
nnoremap <Leader>vq :VimuxCloseRunner<CR>
nnoremap <Leader>vx :VimuxInterruptRunner<CR>

" Elixir: Run Credo for strict linting
nnoremap <Leader>lc :call VimuxRunCommand("mix credo --strict")<CR>

" Elixir: Open IEx REPL in a split
nnoremap <Leader>ie :call VimuxRunCommand("iex -S mix")<CR>

" Elixir: Projectionist configurations (switching between lib and test)
let g:projectionist_heuristics = {
      \ "mix.exs": {
      \   "lib/*.ex": {"alternate": "test/{}_test.exs", "type": "source"},
      \   "test/*_test.exs": {"alternate": "lib/{}.ex", "type": "test"},
      \   "lib/*_web/controllers/*_controller.ex": {"alternate": "test/{}_web/controllers/{}_controller_test.exs", "type": "controller"},
      \   "lib/*_web/live/*_live.ex": {"alternate": "test/{}_web/live/{}_live_test.exs", "type": "live"}
      \ },
      \ "Gemfile": {
      \   "app/models/*.rb": {"alternate": "spec/models/{}_spec.rb", "type": "model"},
      \   "app/controllers/*.rb": {"alternate": "spec/controllers/{}_spec.rb", "type": "controller"},
      \   "app/helpers/*.rb": {"alternate": "spec/helpers/{}_spec.rb", "type": "helper"}
      \ }}

" Elixir: Surround mappings for 'do ... end'
" Usage: 'ysiw d' to wrap a word in do/end
" =============================================================================
" vim-surround: pares customizados (visual: S<char> | normal: ysiw<char>)
" Chars reservados pelo plugin: b()  B{}  r[]  a<>  f/F função  t/T tag  s p :
" =============================================================================

" d → do/end  (Elixir e Ruby — bloco com newlines)
let g:surround_100 = "do\n\r\nend"

" e → fn → end  (Elixir — função anônima inline)
let g:surround_101 = "fn -> \r end"

" E → fn → end  (Elixir — função anônima multilinha)
let g:surround_69  = "fn ->\n\r\nend"

" n → defmodule/do/end  (Elixir — novo módulo)
let g:surround_110 = "defmodule \r do\nend"

" g → begin/end  (Ruby — bloco de rescue/error handling)
let g:surround_103 = "begin\n\r\nend"

" = → <%= %>  (Rails ERB — tag de output)
let g:surround_61  = "<%= \r %>"

" % → <% %>  (Rails ERB — tag silenciosa)
let g:surround_37  = "<% \r %>"

" Auto-format Elixir files on save via mix format
augroup ElixirFormat
  autocmd!
  autocmd BufWritePre *.ex,*.exs,*.heex silent! call CocAction('format')
augroup end

" =============================================================================
" Test Runner (vim-test)
" =============================================================================
nmap <silent> <leader>tn :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ts :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>
nmap <silent> <leader>tv :TestVisit<CR>

" Enable folding via CoC (much faster than indent)
set foldmethod=manual
set foldlevel=99
augroup coc_folding
  autocmd!
  autocmd FileType typescript,json,javascript,python,go,elixir setl formatexpr=CocAction('formatSelected')
augroup end

" =============================================================================
" CoC (Conquer of Completion) Configuration
" =============================================================================
" Better performance for CoC
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Tab/Enter for completion selection
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Ctrl+Space to trigger completion manually
inoremap <silent><expr> <c-space> coc#refresh()

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
augroup CocHighlight
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

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

" CoC float scroll — apenas insert/visual (<C-f>/<C-b> no normal mode vai pro fzf)
if has('patch-8.2.0750')
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Add (Neo)Vim's native statusline support.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>

" CoC references (,gr — gr sozinho mantém tabprev)
nmap <leader>gr <Plug>(coc-references)

" Jump to definition with Ctrl+] (LSP aware)
nmap <silent> <C-]> <Plug>(coc-definition)

" Jump back with Ctrl+t (Reverse jump)
nmap <silent> <C-t> <C-o>

" LSP navigation: gd=definition  gy=type  gi=implementation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)

" Code actions: ,a (cursor) e visual ,a (selection)
nmap <leader>a  <Plug>(coc-codeaction-cursor)
xmap <leader>a  <Plug>(coc-codeaction-selected)

" Navegar entre diagnósticos: [g (anterior) e ]g (próximo)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

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

" coc-snippets: expand and jump
imap <C-j> <Plug>(coc-snippets-expand-jump)

" Endwise: disable default mapping (coc handles insert-mode <CR>)
let g:endwise_no_mappings = 1

let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-git',
      \ 'coc-css',
      \ 'coc-browser',
      \ 'coc-docker',
      \ 'coc-elixir',
      \ 'coc-eslint',
      \ 'coc-html',
      \ 'coc-markdownlint',
      \ 'coc-prettier',
      \ 'coc-sh',
      \ 'coc-yaml',
      \ 'coc-yank',
      \ 'coc-xml',
      \ 'coc-emmet',
      \ 'coc-sql',
      \ 'coc-tsserver',
      \ 'coc-pyright',
      \ 'coc-snippets',
      \ 'coc-tailwindcss',
      \ 'coc-go'
      \ ]

" =============================================================================
" Smart Open Pairs — não fecha quando há \w À DIREITA do cursor
" auto-pairs continua gerenciando: backspace, jump-over, espaço, Alt+e
" Estratégia: sobrescrever só os chars de abertura com <buffer>, disparando
" via InsertEnter DEPOIS do auto-pairs (que registrou o autocmd antes)
" =============================================================================
let g:AutoPairsShortcutToggle = '<C-p>'

function! s:SmartPair(open, close) abort
  let next = getline('.')[col('.')-1]
  return next =~# '\w' ? a:open : a:open . a:close . "\<Left>"
endfunction

function! s:SmartQuote(char) abort
  let next = getline('.')[col('.')-1]
  if next =~# '\w'       | return a:char
  elseif next ==# a:char | return "\<Right>"
  else                   | return a:char . a:char . "\<Left>"
  endif
endfunction

function! s:ApplySmartOpenPairs() abort
  inoremap <buffer> <expr> (  <SID>SmartPair('(', ')')
  inoremap <buffer> <expr> [  <SID>SmartPair('[', ']')
  inoremap <buffer> <expr> {  <SID>SmartPair('{', '}')
  inoremap <buffer> <expr> "  <SID>SmartQuote('"')
  inoremap <buffer> <expr> '  <SID>SmartQuote("'")
  inoremap <buffer> <expr> `  <SID>SmartQuote('`')
endfunction

augroup SmartOpenPairs
  autocmd!
  autocmd VimEnter,BufEnter,InsertEnter * call s:ApplySmartOpenPairs()
augroup end

" =============================================================================
" fzf — Busca rápida de arquivos, buffers, texto (substitui CtrlP)
" =============================================================================
" Janela popup centralizada
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }
let g:fzf_preview_window = ['right:50%', 'ctrl-/']
let g:fzf_history_dir = '~/.local/share/fzf-history'

" ripgrep como backend de listagem de arquivos
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*" --glob "!_build/*" --glob "!deps/*" --glob "!.elixir_ls/*"'
endif

nnoremap <C-f>       :Files<CR>
nnoremap <C-b>       :Buffers<CR>
nnoremap <leader>gf  :GFiles<CR>
nnoremap <leader>rg  :Rg<space>
nnoremap <leader>bl  :BLines<CR>
nnoremap <leader>ht  :History<CR>

" =============================================================================
" vim-projectionist — Alternância código<=>teste (:A) em Elixir e outros
" =============================================================================
" (g:projectionist_heuristics já definido na seção Elixir acima)

" =============================================================================
" vim-unimpaired — Navegação rápida de quickfix, location list, buffers
" =============================================================================
" [q / ]q  → quickfix anterior/próximo
" [l / ]l  → location list anterior/próximo
" [b / ]b  → buffer anterior/próximo
" [n / ]n  → conflito de merge anterior/próximo
" (sem configuração necessária — o plugin define tudo)

" =============================================================================
" Undotree — Histórico visual de undo
" =============================================================================
nnoremap <leader>u :UndotreeToggle<CR>
let g:undotree_WindowLayout = 2
let g:undotree_SetFocusWhenToggle = 1

" =============================================================================
" vim-obsession — Gerenciamento de sessões
" =============================================================================
" ,os → inicia/para tracking da sessão (salva Session.vim no CWD)
nnoremap <leader>os :Obsession<CR>

" Restaura sessão automaticamente se Session.vim existir no diretório atual
augroup obsession_restore
  autocmd!
  autocmd VimEnter * nested
        \ if !argc() && empty(v:this_session) && filereadable('Session.vim') |
        \   source Session.vim |
        \ endif
augroup end

" =============================================================================
" vim-rooter — CD automático para a raiz do projeto
" =============================================================================
let g:rooter_patterns = ['.git', 'mix.exs', 'Gemfile', 'package.json',
      \ 'pyproject.toml', 'setup.py', '.python-version', 'Cargo.toml']
let g:rooter_silent_chdir = 1
let g:rooter_resolve_links = 1

" =============================================================================
" GV.vim — Browser de git log
" =============================================================================
nnoremap <leader>gv :GV<CR>
nnoremap <leader>gV :GV!<CR>

" =============================================================================
" Git Messenger — popup com commit/autor da linha atual (,gm)
" =============================================================================
function! s:GitMessenger() abort
  let l:line = line('.')
  let l:file = expand('%')
  if empty(l:file) || !filereadable(l:file)
    return
  endif
  let l:blame = system(printf(
        \ 'git blame -L %d,%d --porcelain %s 2>/dev/null',
        \ l:line, l:line, shellescape(l:file)))
  if v:shell_error
    echo 'Não é um repositório git'
    return
  endif
  let l:hash = matchstr(l:blame, '^[0-9a-f]\+')
  if l:hash =~# '^0\+$'
    echo 'Linha ainda não commitada'
    return
  endif
  let l:msg = system(printf(
        \ 'git log -1 --format="%%h %%s%%n%%nAuthor: %%an <%%ae>%%nDate:   %%ad%%n%%n%%b" %s 2>/dev/null',
        \ l:hash))
  if has('popupwin')
    call popup_atcursor(split(l:msg, "\n"),
          \ {'border': [1,1,1,1], 'padding': [0,1,0,1], 'moved': 'any'})
  else
    echo l:msg
  endif
endfunction
nmap <silent> <leader>gm :call <SID>GitMessenger()<CR>

" =============================================================================
" Undodir cleanup — remove arquivos de undo com mais de 90 dias
" =============================================================================
augroup UndoCleanup
  autocmd!
  autocmd VimEnter * silent! call timer_start(3000, {-> system(
        \ 'find ' . expand('~/.vim_runtime/temp_dirs/undodir') .
        \ ' -type f -mtime +90 -delete 2>/dev/null &')})
augroup end

" =============================================================================
" Auto-save e trailing whitespace extra
" =============================================================================
" Salva todos os buffers ao perder o foco (saiu da janela/app)
augroup AutoSave
  autocmd!
  autocmd FocusLost * silent! wa
augroup end

" Extend trailing whitespace removal para Elixir, Ruby, TS, CSS
augroup ExtraCleanExtraSpaces
  autocmd!
  autocmd BufWritePre *.ex,*.exs,*.heex,*.rb,*.rake,*.erb,*.ts,*.tsx,*.css,*.scss
        \ call CleanExtraSpaces()
augroup end

" =============================================================================
" Auto-reload — detecta mudanças feitas por agentes de IA (Claude Code, etc.)
" Requer tmux: set -g focus-events on  (no ~/.tmux.conf)
" =============================================================================
augroup AgentAutoReload
  autocmd!
  autocmd FocusGained,BufEnter * silent! checktime
  autocmd CursorHold * silent! checktime
augroup end

" Terminal sync — evita flickering com TUI apps (Claude Code) no :terminal
if exists('+termsync')
  set termsync
endif

" =============================================================================
" vim-claude-code — Claude Code CLI integrado no Vim
" Toggle: Ctrl+\  |  Prefix: ,c  |  Layout: split direito 40%
" =============================================================================
let g:claude_code_position = 'right'
let g:claude_code_split_ratio = 0.4

" =============================================================================
" copilot-chat.vim — Chat com Copilot dentro do Vim
" Nota: ,c* é reservado para vim-claude-code (explain, fix, refactor, etc.)
" =============================================================================
" ,pc → abre o chat Copilot   visual ,cq → pergunta sobre seleção
nnoremap <leader>pc :CopilotChatOpen<CR>
xnoremap <leader>cq :CopilotChat<space>
