""""""""""""""""""""""""""""""
" => Ruby / Rails section
""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.rb,*.rake,Gemfile,Rakefile,Guardfile,Capfile set filetype=ruby
au BufNewFile,BufRead *.erb set filetype=eruby

au FileType ruby setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
au FileType eruby setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab


""""""""""""""""""""""""""""""
" => Elixir / Phoenix section
""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.heex set filetype=heex
au BufNewFile,BufRead *.leex set filetype=eelixir
au BufNewFile,BufRead *.ex,*.exs set filetype=elixir

au FileType elixir,heex,eelixir setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab


""""""""""""""""""""""""""""""
" => Python section
""""""""""""""""""""""""""""""
let python_highlight_all = 1
au FileType python syn keyword pythonDecorator True None False self

au BufNewFile,BufRead *.jinja set syntax=htmljinja

au FileType python set cindent
au FileType python set cinkeys-=0#
au FileType python set indentkeys-=0#


""""""""""""""""""""""""""""""
" => JavaScript section
"""""""""""""""""""""""""""""""
au FileType javascript call JavaScriptFold()
au FileType javascript setl fen
au FileType javascript setl nocindent

function! JavaScriptFold()
    setl foldmethod=syntax
    setl foldlevelstart=1
    syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

    function! FoldText()
        return substitute(getline(v:foldstart), '{.*', '{...}', '')
    endfunction
    setl foldtext=FoldText()
endfunction


""""""""""""""""""""""""""""""
" => Shell section
""""""""""""""""""""""""""""""
if exists('$TMUX')
    if has('nvim')
        set termguicolors
    else
        set term=screen-256color
    endif
endif


""""""""""""""""""""""""""""""
" => Twig section
""""""""""""""""""""""""""""""
autocmd BufRead *.twig set syntax=html filetype=html

au FileType gitcommit call setpos('.', [0, 1, 1, 0])
