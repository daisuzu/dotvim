"---------------------------------------------------------------------------
" .vimrc
"---------------------------------------------------------------------------
" Initialize:"{{{
"
set nocompatible

augroup MyVimrcCmd
    autocmd!
augroup END

let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')

if s:MSWindows
    let $DOTVIM = expand($VIM . '/vimfiles')
else
    let $DOTVIM = expand('~/.vim')
endif

let $MYLOCALVIMRC = $DOTVIM.'/.local.vimrc'

nnoremap <silent> <Space>ev  :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> <Space>eg  :<C-u>edit $MYGVIMRC<CR>
nnoremap <silent> <Space>el  :<C-u>edit $MYLOCALVIMRC<CR>

nnoremap <silent> <Space>tv  :<C-u>tabedit $MYVIMRC<CR>
nnoremap <silent> <Space>tg  :<C-u>tabedit $MYGVIMRC<CR>
nnoremap <silent> <Space>tl  :<C-u>tabedit $MYLOCALVIMRC<CR>

nnoremap <silent> <Space>rv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif <CR>
nnoremap <silent> <Space>rg :<C-u>source $MYGVIMRC<CR>
nnoremap <silent> <Space>rl :<C-u>if 1 && filereadable($MYLOCALVIMRC) \| source $MYLOCALVIMRC \| endif <CR>

if has('win32') || has('win64')
    " set shellslash
    set visualbell t_vb=
endif
nnoremap <Space>o/ :<C-u>setlocal shellslash!\|setlocal shellslash?<CR>

set noautochdir
nnoremap <Space>oc :<C-u>setlocal autochdir!\|setlocal autochdir?<CR>

"---------------------------------------------------------------------------
" Encoding:"{{{
"
if !has('gui_running') && s:MSWindows
    set termencoding=cp932
    set encoding=cp932
elseif s:MSWindows
    set termencoding=cp932
    set encoding=utf-8
else
    set encoding=utf-8
endif

"set default fileencodings
if &encoding == 'utf-8'
    set fileencodings=ucs-bom,utf-8,default,latin1
elseif &encoding == 'cp932'
    set fileencodings=ucs-bom
endif

" set fileencodings for character code automatic recognition
if &encoding !=# 'utf-8'
    set encoding=japan
    set fileencoding=japan
endif
if has('iconv')
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'eucjp-ms'
        let s:enc_jis = 'iso-2022-jp-3'
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'euc-jisx0213'
        let s:enc_jis = 'iso-2022-jp-3'
    endif
    " build fileencodings
    if &encoding ==# 'utf-8'
        let s:fileencodings_default = &fileencodings
        let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
        let &fileencodings = &fileencodings .','. s:fileencodings_default
        unlet s:fileencodings_default
    else
        let &fileencodings = &fileencodings .','. s:enc_jis
        set fileencodings+=utf-8,ucs-2le,ucs-2
        if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
            set fileencodings+=cp932
            set fileencodings-=euc-jp
            set fileencodings-=euc-jisx0213
            set fileencodings-=eucjp-ms
            let &encoding = s:enc_euc
            let &fileencoding = s:enc_euc
        else
            let &fileencodings = &fileencodings .','. s:enc_euc
        endif
    endif
    "give priority to utf-8
    if &encoding == 'utf-8'
        set fileencodings-=utf-8
        let &fileencodings = substitute(&fileencodings, s:enc_jis, s:enc_jis.',utf-8','')
    endif
    
    unlet s:enc_euc
    unlet s:enc_jis
endif

set fileformats=dos,unix,mac

" to use the encoding to fileencoding when not included the Japanese
if has('autocmd')
    function! AU_ReCheck_FENC()
        if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
            let &fileencoding=&encoding
            if s:MSWindows
                let &fileencoding='cp932'
            endif
        endif
    endfunction
    autocmd MyVimrcCmd BufReadPost * call AU_ReCheck_FENC()
endif

" When internal encoding is not cp932 in Windows,
" and environment variable contains multi-byte character
command! -nargs=+ Let call Let__EnvVar__(<q-args>)
function! Let__EnvVar__(cmd)
    let cmd = 'let ' . a:cmd
    if has('win32') + has('win64') && has('iconv') && &enc != 'cp932'
        let cmd = iconv(cmd, &enc, 'cp932')
    endif
    exec cmd
endfunction
"}}}
"
"---------------------------------------------------------------------------
" Kaoriya:"{{{
"
if exists('g:no_vimrc_example') && g:no_vimrc_example == 1
    silent! source $VIMRUNTIME/vimrc_example.vim
endif
"}}}

"---------------------------------------------------------------------------
" MSWIN:"{{{
"
if 1 && filereadable($VIMRUNTIME . '/mswin.vim')
    source $VIMRUNTIME/mswin.vim
endif

" Redefinition <C-A>:increment and <C-X>:decrement
noremap <C-i> <C-A>
noremap <M-i> <C-X>
"}}}
"}}}

"---------------------------------------------------------------------------
" Load Plugins:"{{{
"
filetype plugin indent off

"---------------------------------------------------------------------------
" neobundle.vim:"{{{
"
if has('vim_starting')
    set runtimepath+=$DOTVIM/Bundle/neobundle.vim/
endif

try
    call neobundle#rc($DOTVIM . '/Bundle/')

    " plugin management
    NeoBundle 'git://github.com/Shougo/neobundle.vim.git'
    NeoBundle 'git://github.com/tpope/vim-pathogen.git'
    NeoBundle 'git://github.com/jceb/vim-ipi.git'

    " doc
    NeoBundle 'git://github.com/vim-jp/vimdoc-ja.git'
    NeoExternalBundle 'git://github.com/thinca/vim-ref.git'

    " completion
    NeoBundle 'git://github.com/Shougo/neocomplcache.git'
    NeoBundle 'git://github.com/Shougo/neocomplcache-snippets-complete.git'
    NeoBundle 'git://github.com/Rip-Rip/clang_complete.git'
    NeoBundle 'git://github.com/osyo-manga/neocomplcache-clang_complete.git'
    NeoBundle 'git://github.com/ujihisa/neco-ghc.git'
    NeoBundle 'git://github.com/teramako/jscomplete-vim.git'

    " ctags
    NeoExternalBundle 'git://github.com/vim-scripts/taglist.vim.git'
    NeoExternalBundle 'git://github.com/abudden/TagHighlight.git'

    " vcs
    NeoBundle 'git://github.com/tpope/vim-fugitive.git'
    NeoBundle 'git://github.com/gregsexton/gitv.git'
    NeoBundle 'git://github.com/int3/vim-extradite.git'

    " unite
    NeoBundle 'git://github.com/Shougo/unite.vim.git'
    NeoBundle 'git://github.com/Shougo/unite-build.git'
    NeoBundle 'git://github.com/ujihisa/unite-colorscheme.git'
    NeoExternalBundle 'git://github.com/ujihisa/quicklearn.git'
    NeoBundle 'git://github.com/sgur/unite-qf.git'
    NeoBundle 'git://github.com/h1mesuke/unite-outline.git'
    NeoBundle 'git://github.com/h1mesuke/vim-alignta.git'
    NeoBundle 'git://github.com/tsukkee/unite-help.git'
    NeoBundle 'git://github.com/tsukkee/unite-tag.git'
    NeoBundle 'git://github.com/tacroe/unite-mark.git'
    NeoBundle 'git://github.com/sgur/unite-everything.git'
    NeoBundle 'git://github.com/zhaocai/unite-scriptnames.git'
    NeoBundle 'git://github.com/pasela/unite-webcolorname.git'
    NeoBundle 'git://github.com/daisuzu/unite-grep_launcher.git'
    NeoBundle 'git://github.com/daisuzu/unite-gtags.git'

    " textobj
    NeoBundle 'git://github.com/kana/vim-textobj-user.git'
    NeoBundle 'git://github.com/kana/vim-textobj-indent.git'
    NeoBundle 'git://github.com/kana/vim-textobj-syntax.git'
    NeoBundle 'git://github.com/kana/vim-textobj-line.git'
    NeoBundle 'git://github.com/kana/vim-textobj-fold.git'
    NeoBundle 'git://github.com/kana/vim-textobj-entire.git'
    NeoBundle 'git://github.com/thinca/vim-textobj-between.git'
    NeoBundle 'git://github.com/thinca/vim-textobj-comment.git'
    NeoBundle 'git://github.com/h1mesuke/textobj-wiw.git'
    NeoBundle 'git://github.com/vimtaku/vim-textobj-sigil.git'

    " operator
    NeoBundle 'git://github.com/kana/vim-operator-user.git'
    NeoBundle 'git://github.com/kana/vim-operator-replace.git'
    NeoBundle 'git://github.com/tyru/operator-camelize.vim.git'
    NeoBundle 'git://github.com/tyru/operator-reverse.vim.git'
    NeoBundle 'git://github.com/emonkak/vim-operator-sort.git'

    " quickfix
    NeoBundle 'git://github.com/thinca/vim-qfreplace.git'
    NeoBundle 'git://github.com/dannyob/quickfixstatus.git'
    NeoBundle 'git://github.com/jceb/vim-hier.git'
    NeoBundle 'git://github.com/fuenor/qfixhowm.git'

    " appearance
    NeoBundle 'git://github.com/thinca/vim-fontzoom.git'
    NeoBundle 'git://github.com/nathanaelkane/vim-indent-guides.git'
    NeoBundle 'git://github.com/vim-scripts/MultipleSearch.git'

    " cursor movement
    NeoBundle 'git://github.com/Lokaltog/vim-easymotion.git'
    NeoBundle 'git://github.com/vim-scripts/matchparenpp.git'
    NeoBundle 'git://github.com/vim-scripts/matchit.zip.git'

    " editing
    NeoBundle 'git://github.com/tpope/vim-surround.git'
    NeoBundle 'git://github.com/t9md/vim-textmanip.git'
    NeoBundle 'git://github.com/tomtom/tcomment_vim.git'
    NeoBundle 'git://github.com/vim-scripts/DrawIt.git'
    NeoBundle 'git://github.com/vim-scripts/RST-Tables.git'
    NeoBundle 'git://github.com/vim-scripts/sequence.git'

    " search
    NeoBundle 'git://github.com/thinca/vim-visualstar.git'
    NeoBundle 'git://github.com/vim-scripts/occur.vim.git'

    " utility
    NeoBundle 'git://github.com/mattn/ideone-vim.git'
    NeoBundle 'git://github.com/vim-scripts/project.tar.gz.git'
    NeoBundle 'git://github.com/Shougo/vimproc.git'
    NeoBundle 'git://github.com/Shougo/vinarise.git'
    NeoBundle 'git://github.com/s-yukikaze/vinarise-plugin-peanalysis.git'
    NeoExternalBundle 'git://github.com/Shougo/vimfiler.git'
    NeoBundle 'git://github.com/Shougo/vimshell.git'
    NeoBundle 'git://github.com/thinca/vim-logcat.git'
    NeoExternalBundle 'git://github.com/thinca/vim-quickrun.git'
    NeoBundle 'git://github.com/thinca/vim-prettyprint.git'
    NeoBundle 'git://github.com/thinca/vim-editvar.git'
    NeoBundle 'git://github.com/tyru/open-browser.vim.git'
    NeoBundle 'git://github.com/sjl/splice.vim.git'
    NeoBundle 'git://github.com/sjl/gundo.vim.git'
    NeoBundle 'git://github.com/vim-scripts/copypath.vim.git'
    NeoBundle 'git://github.com/vim-scripts/DirDiff.vim.git'
    NeoBundle 'git://github.com/vim-scripts/ShowMultiBase.git'
    NeoBundle 'git://github.com/vim-scripts/ttoc.git'
    NeoBundle 'git://github.com/vim-scripts/wokmarks.vim.git'

    " command extension
    NeoBundle 'git://github.com/thinca/vim-ambicmd.git'
    NeoBundle 'git://github.com/tyru/vim-altercmd.git'
    NeoBundle 'git://github.com/tomtom/tcommand_vim.git'
    NeoExternalBundle 'git://github.com/mbadran/headlights.git'

    " C/C++
    NeoExternalBundle 'git://github.com/vim-scripts/a.vim.git'
    NeoExternalBundle 'git://github.com/vim-scripts/c.vim.git'
    NeoExternalBundle 'git://github.com/vim-scripts/CCTree.git'
    NeoExternalBundle 'git://github.com/vim-scripts/Source-Explorer-srcexpl.vim.git'
    NeoExternalBundle 'git://github.com/vim-scripts/trinity.vim.git'
    NeoExternalBundle 'git://github.com/vim-scripts/cscope-menu.git'
    NeoExternalBundle 'git://github.com/vim-scripts/gtags.vim.git'
    NeoExternalBundle 'git://github.com/vim-scripts/DoxygenToolkit.vim.git'

    " Python
    NeoExternalBundle 'git://github.com/alfredodeza/pytest.vim.git'
    NeoExternalBundle 'git://github.com/klen/python-mode.git'

    " Perl
    NeoExternalBundle 'git://github.com/vim-scripts/perl-support.vim.git'

    " JavaScript
    NeoExternalBundle 'git://github.com/pangloss/vim-javascript.git'

    " Haskell
    NeoExternalBundle 'git://github.com/kana/vim-filetype-haskell.git'
    NeoExternalBundle 'git://github.com/lukerandall/haskellmode-vim.git'
    NeoExternalBundle 'git://github.com/Twinside/vim-syntax-haskell-cabal.git'
    NeoExternalBundle 'git://github.com/eagletmt/ghcmod-vim.git'

    " Clojure
    NeoBundle 'git://github.com/jondistad/vimclojure.git'

    " CSV
    NeoBundle 'git://github.com/vim-scripts/csv.vim.git'

    " colorscheme
    NeoBundle 'git://github.com/vim-scripts/Color-Sampler-Pack.git'

    " runtime
    NeoBundle 'git://github.com/mattn/webapi-vim.git'
    NeoBundle 'git://github.com/vim-scripts/cecutil.git'
    NeoBundle 'git://github.com/vim-scripts/tlib.git'
catch /E117/
    
endtry
"}}}

"---------------------------------------------------------------------------
" vim-ipi:"{{{
"
let s:ipi_loaded = 0
try
    call ipi#inspect("Bundle")
    let s:ipi_loaded = 1
catch /E117/
    
endtry
"}}}
filetype plugin indent on

"---------------------------------------------------------------------------
" CCTree.vim:"{{{
"
if 1 && filereadable($DOTVIM . '/Bundle/CCTree/ftplugin/cctree.vim')
    source $DOTVIM/Bundle/CCTree/ftplugin/cctree.vim
endif
"}}}
"}}}

"---------------------------------------------------------------------------
" Edit:"{{{
"
set nobackup
set clipboard+=unnamed
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab
set backspace=indent,eol,start
set wildmenu
set autoindent
" Smart indenting
set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
inoremap # X<C-H><C-V>#
" settings for Japanese folding
set formatoptions&
set formatoptions+=mM
" settings for Japanese formatting
let format_allow_over_tw = 1
" tags{{{
set tags=./tags
set tags+=tags;
set tags+=./**/tags
"}}}
" grep{{{
set grepprg=grep\ -nH
"set grepprg=ack.pl\ -a
" autocmd MyVimrcCmd QuickfixCmdPost make,grep,grepadd,vimgrep,helpgrep copen
"}}}
"}}}

"---------------------------------------------------------------------------
" View:"{{{
"
set number
set showmatch
set laststatus=2
set cmdheight=2
set showcmd
set title
set showtabline=2
set display=uhex

set nowrap
nnoremap <Space>ow :<C-u>setlocal wrap!\|setlocal wrap?<CR>

set nolist
nnoremap <Space>ol :<C-u>setlocal list!\|setlocal list?<CR>
set listchars=tab:>-,extends:<,precedes:>,trail:-,eol:$,nbsp:%

" Tabline settings "{{{
function! s:tabpage_label(n) "{{{
    let title = gettabvar(a:n, 'title') 
    if title !=# '' 
        return title 
    endif

    let bufnrs = tabpagebuflist(a:n)

    let hi = a:n is tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'

    let no = len(bufnrs) 
    if no is 1 
        let no = ''
    endif

    let mod = len(filter(copy(bufnrs), 'getbufvar(v:val, "&modified")')) ? '+' : '' 
    let sp = (no . mod) ==# '' ? '' : ' ' 

    let curbufnr = bufnrs[tabpagewinnr(a:n) - 1] 
    let fname = pathshorten(bufname(curbufnr))

    let label = no . mod . sp . fname

    return '%' . a:n . 'T' . hi . label . '%T%#TabLineFill#'
endfunction "}}}
function! MakeTabLine() "{{{
    let titles =map(range(1, tabpagenr('$')), 's:tabpage_label(v:val)')
    let sep = ' | ' 
    let tabpages = join(titles, sep) . sep . '%#TabLineFill#%T' 
    let info = fnamemodify(getcwd(),"~:") . ' '
    return tabpages . '%=' . info 
endfunction "}}}
set guioptions&
set guioptions-=e
set tabline=%!MakeTabLine()
"}}}

" Visualization of the full-width space and the blank at the end of the line{{{
if has("syntax")
    syntax on

    " for POD bug
    syn sync fromstart

    function! ActivateInvisibleIndicator()
        syntax match InvisibleJISX0208Space "　" display containedin=ALL
        highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
        "syntax match InvisibleTrailedSpace "[ \t]\+$" display containedin=ALL
        "highlight InvisibleTrailedSpace term=underline ctermbg=Red guibg=NONE gui=undercurl guisp=darkorange
        "syntax match InvisibleTab "\t" display containedin=ALL
        "highlight InvisibleTab term=underline ctermbg=white gui=undercurl guisp=darkslategray
    endf
    augroup invisible
        autocmd! invisible
        autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
    augroup END
endif
"}}}
" Highlight end of line whitespace.
highlight WhitespaceEOL ctermbg=lightgray guibg=lightgray
match WhitespaceEOL /\s\+$/

" XPstatusline + fugitive#statusline {{{
let g:statusline_max_path = 20
function! StatusLineGetPath() "{{{
    let p = expand('%:.:h') 
    let p = substitute(p, expand('$HOME'), '~', '')
    if len(p) > g:statusline_max_path
        let p = simplify(p)
        let p = pathshorten(p)
    endif
    return p
endfunction "}}}

nmap <Plug>view:switch_status_path_length :let g:statusline_max_path = 200 - g:statusline_max_path<cr>
nmap ,t <Plug>view:switch_status_path_length

augroup Statusline
    autocmd! Statusline

    autocmd BufEnter * call <SID>SetFullStatusline()
    autocmd BufLeave,BufNew,BufRead,BufNewFile * call <SID>SetSimpleStatusline()
augroup END

function! StatusLineRealSyn()
    let synId = synID(line('.'),col('.'),1)
    let realSynId = synIDtrans(synId)
    if synId == realSynId
        return 'Normal'
    else
        return synIDattr( realSynId, 'name' )
    endif
endfunction

function! s:SetFullStatusline() "{{{
    setlocal statusline=
    setlocal statusline+=%#StatuslineBufNr#%-1.2n\                   " buffer number
    setlocal statusline+=%h%#StatuslineFlag#%m%r%w                 " flags
    setlocal statusline+=%#StatuslinePath#\ %-0.20{StatusLineGetPath()}%0* " path
    setlocal statusline+=%#StatuslineFileName#\/%t\                       " file name

    try
        call fugitive#statusline()
        setlocal statusline+=%{fugitive#statusline()}  " Git branch name
    catch /E117/

    endtry

    setlocal statusline+=%#StatuslineChar#\ \ 0x%-2B                 " current char
"    setlocal statusline+=%#StatuslineChar#\ \ 0x%-2B\ %0*                 " current char
    setlocal statusline+=%#StatuslineTermEnc#(%{&termencoding},\           " encoding
    setlocal statusline+=%#StatuslineFileEnc#%{&fileencoding},\         " file encoding
    setlocal statusline+=%#StatuslineFileType#%{&fileformat}\)\              " file format

    setlocal statusline+=%#StatuslineFileType#\ %{strlen(&ft)?&ft:'**'}\ . " filetype
    setlocal statusline+=%#StatuslineSyn#\ %{synIDattr(synID(line('.'),col('.'),1),'name')}\ %0*           "syntax name
    setlocal statusline+=%#StatuslineRealSyn#\ %{StatusLineRealSyn()}\ %0*           "real syntax name
    setlocal statusline+=%=

    setlocal statusline+=\ %-10.(%l/%L,%c-%v%)             "position
    setlocal statusline+=\ %P                             "position percentage
"    setlocal statusline+=\ %#StatuslineTime#%{strftime(\"%m-%d\ %H:%M\")} " current time

endfunction "}}}

function! s:SetSimpleStatusline() "{{{
    setlocal statusline=
    setlocal statusline+=%#StatuslineNC#%-0.20{StatusLineGetPath()}%0* " path
    setlocal statusline+=\/%t\                       " file name
endfunction "}}}
"}}}
"}}}

"---------------------------------------------------------------------------
" Search:"{{{
"
set nowrapscan

set ignorecase
nnoremap <Space>oi :<C-u>setlocal ignorecase!\|setlocal ignorecase?<CR>

set smartcase
nnoremap <Space>os :<C-u>setlocal smartcase!\|setlocal smartcase?<CR>

set hlsearch
nmap <ESC><ESC> :nohlsearch<CR><ESC>
"}}}

"---------------------------------------------------------------------------
"  Utilities:"{{{
"
try
    call altercmd#load()
catch /E117/

endtry

" TabpageCD"{{{
command! -bar -complete=dir -nargs=?
      \   CD
      \   TabpageCD <args>
command! -bar -complete=dir -nargs=?
      \   TabpageCD
      \   execute 'cd' fnameescape(expand(<q-args>))
      \   | let t:cwd = getcwd()

autocmd MyVimrcCmd TabEnter *
      \   if exists('t:cwd') && !isdirectory(t:cwd)
      \ |     unlet t:cwd
      \ | endif
      \ | if !exists('t:cwd')
      \ |   let t:cwd = getcwd()
      \ | endif
      \ | execute 'cd' fnameescape(expand(t:cwd))

" Exchange ':cd' to ':TabpageCD'.
try
    AlterCommand cd CD
catch /E492/

endtry
"}}}

" CD to the directory of open files{{{
command! -nargs=? -complete=dir -bang TCD  call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        TabpageCD %:p:h
    else
        execute 'TabpageCD' . a:directory
    endif

    if a:bang == ''
        pwd
    endif
endfunction}}}
nnoremap <silent> <Space>cd :<C-u>TCD<CR>

" WinMerge keybind in vimdiff "{{{
function! DiffGet() "{{{
    try
        execute 'diffget'
    catch/E101/
        execute 'diffget //2'
    endtry
endfunction "}}}
function! DiffPut() "{{{
    try
        execute 'diffput'
    catch/E101/
        execute 'diffget //3'
    endtry
endfunction "}}}
function! SetDiffMap() "{{{
        nnoremap <buffer> <F5> :<C-u>diffupdate<CR>
        nnoremap <buffer> <A-Up> [c
        nnoremap <buffer> <A-Down> ]c
        nnoremap <buffer> <A-Right> :<C-u>call DiffGet()<CR>
        nnoremap <buffer> <A-Left> :<C-u>call DiffPut()<CR>
endfunction "}}}
autocmd MyVimrcCmd FilterWritePost * call SetDiffMap()
"}}}
" Command-line window{{{
autocmd MyVimrcCmd CmdwinEnter * call s:init_cmdwin()
function! s:init_cmdwin()
    nnoremap <buffer> q :<C-u>quit<CR>
    nnoremap <buffer> <TAB> :<C-u>quit<CR>

    inoremap <buffer><expr><C-h> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
    inoremap <buffer><expr><BS> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"

    inoremap <buffer><expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

    startinsert!
endfunction
"}}}
" DiffClip() "{{{
command! -nargs=0 -range DiffClip <line1>, <line2>:call DiffClip('0')
function! DiffClip(reg) range
    exe "let @a=@" . a:reg
    exe a:firstline  . "," . a:lastline . "y b"
    tabnew "new
    " clear the buffer after close the window
    set buftype=nofile bufhidden=wipe
    put a
    diffthis
    lefta vnew "vnew
    set buftype=nofile bufhidden=wipe
    put b
    diffthis
endfunction
"}}}
" NextIndent() "{{{
" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"
" exclusive (bool):   true:  Motion is exclusive
"                     false: Motion is inclusive
" fwd (bool):         true:  Go to next line
"                     false: Go to previous line
" lowerlevel (bool):  true:  Go to line with lower indentation level
"                     false: Go to line with the same indentation level
" skipblanks (bool):  true:  Skip blank lines
"                     false: Don't skip blank lines
"
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
    let line = line('.')
    let column = col('.')
    let lastline = line('$')
    let indent = indent(line)
    let stepvalue = a:fwd ? 1 : -1
    "
    while (line > 0 && line <= lastline)
        let line = line + stepvalue
        if ( ! a:lowerlevel && indent(line) == indent ||
            \ a:lowerlevel && indent(line) < indent)
            if (! a:skipblanks || strlen(getline(line)) > 0)
                if (a:exclusive)
                    let line = line - stepvalue
                endif
                exe line
                exe "normal " column . "|"
                return
            endif
        endif
    endwhile
endfunc
"
" Moving back and forth between lines of same or lower indentation.
nnoremap <silent> [l :call NextIndent(0, 0, 0, 1)<cr>
nnoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<cr>
nnoremap <silent> [L :call NextIndent(0, 0, 1, 1)<cr>
nnoremap <silent> ]L :call NextIndent(0, 1, 1, 1)<cr>
vnoremap <silent> [l <esc>:call NextIndent(0, 0, 0, 1)<cr>m'gv''
vnoremap <silent> ]l <esc>:call NextIndent(0, 1, 0, 1)<cr>m'gv''
vnoremap <silent> [L <esc>:call NextIndent(0, 0, 1, 1)<cr>m'gv''
vnoremap <silent> ]L <esc>:call NextIndent(0, 1, 1, 1)<cr>m'gv''
onoremap <silent> [l :call NextIndent(0, 0, 0, 1)<cr>
onoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<cr>
onoremap <silent> [L :call NextIndent(1, 0, 1, 1)<cr>
onoremap <silent> ]L :call NextIndent(1, 1, 1, 1)<cr>
"}}}
" flymake for perl{{{
augroup FlyQuickfixMakeCmd
    autocmd!
augroup END

function! SetErrorMarkers()
    :cclose
    :HierUpdate
    :QuickfixStatusEnable
endfunction

function! FlyquickfixPrgSet(mode)
    if a:mode == 10
        """ setting for perl
        setlocal makeprg=vimparse.pl\ -c\ %
        setlocal errorformat=%f:%l:%m
"        setlocal shellpipe=2>&1\ >
        let g:flyquickfixmake_mode = 10
"        echo "flymake prg: perl"
    endif
endfunction

function! FlyquickfixToggleSet()
    if g:enabled_flyquickfixmake == 1
        autocmd! FlyQuickfixMakeCmd
        echo "not-used flymake"
        let g:enabled_flyquickfixmake = 0
    else
        echo "used flymake"
        let g:enabled_flyquickfixmake = 1
        autocmd FlyQuickfixMakeCmd BufWritePost *.pm,*.pl,*.t make
        autocmd FlyQuickfixMakeCmd QuickFixCmdPost make call SetErrorMarkers()
    endif
endfunction

if !exists("g:enabled_flyquickfixmake")
    let g:enabled_flyquickfixmake = 1
    call FlyquickfixPrgSet(10)

    autocmd FlyQuickfixMakeCmd BufWritePost *.pm,*.pl,*.t make
    autocmd FlyQuickfixMakeCmd QuickFixCmdPost make call SetErrorMarkers()
endif

if !exists("g:flyquickfixmake_mode")
    let g:flyquickfixmake_mode = 10
endif

noremap pl :call FlyquickfixToggleSet()<CR>
"}}}
" cscope_maps{{{
"
" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim... 
if has("cscope")
    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0

    " add any cscope database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
    " else add the database pointed to by environment variable 
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif

    " show msg when any other cscope db added
    set cscopeverbose

    " cscope key mappings
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>
endif
"}}}
"}}}

"---------------------------------------------------------------------------
" Plugins:"{{{
"
"---------------------------------------------------------------------------
" 2html.vim:"{{{
"
let g:html_number_lines = 0
let g:html_dynamic_folds = 1
"let g:html_hover_unfold = 1
"}}}
"---------------------------------------------------------------------------
" vim-ref:"{{{
"
let g:ref_cache_dir = $DOTVIM.'/.vim_ref_cache'

" Python
let g:ref_pydoc_cmd = "python -m pydoc"

" ALC
"let g:ref_alc_cmd = 'w3m -dump %s'
let g:ref_alc_use_cache = 0
let g:ref_alc_start_linenumber = 39 " Skip the extraneous lines
if s:MSWindows
    let g:ref_alc_encoding = 'cp932'
endif
if exists('*ref#register_detection')
    call ref#register_detection('_', 'alc')
endif
"}}}
"---------------------------------------------------------------------------
" neocomplcache:"{{{
"
function! Init_neocomplcache() "{{{
    NeoComplCacheEnable
    imap <C-k>     <Plug>(neocomplcache_snippets_expand)
    smap <C-k>     <Plug>(neocomplcache_snippets_expand)
    inoremap <expr><C-g>     neocomplcache#undo_completion()
    inoremap <expr><C-l>     neocomplcache#complete_common_string()
    imap <C-q>  <Plug>(neocomplcache_start_unite_quick_match)

    " SuperTab like snippets behavior.
    "imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplcache#close_popup()
    inoremap <expr><C-e>  neocomplcache#cancel_popup()

    " For cursor moving in insert mode(Not recommended)
    "inoremap <expr><Left> neocomplcache#close_popup() . "\<Left>"
    "inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
    "inoremap <expr><Up> neocomplcache#close_popup() . "\<Up>"
    "inoremap <expr><Down> neocomplcache#close_popup() . "\<Down>"
    " Or set this.
    "let g:neocomplcache_enable_cursor_hold_i = 1

    " AutoComplPop like behavior.
    "let g:neocomplcache_enable_auto_select = 1

    " Shell like behavior(not recommended).
    "set completeopt&
    "set completeopt+=longest
    "let g:neocomplcache_enable_auto_select = 1
    "let g:neocomplcache_disable_auto_complete = 1
    "inoremap <expr><TAB> pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
    "inoremap <expr><CR> neocomplcache#smart_close_popup() . "\<CR>"
endfunction"}}}
function! Term_neocomplcache() "{{{
    NeoComplCacheDisable
    iunmap <C-k>
    sunmap <C-k>
    iunmap <C-g>
    iunmap <C-l>
    iunmap <C-q>
    iunmap <CR>
    iunmap <TAB>
    iunmap <C-h>
    iunmap <BS>
    iunmap <C-y>
    iunmap <C-e>
endfunction"}}}
command! InitNeoComplCache call Init_neocomplcache()
command! TermNeoComplCache call Term_neocomplcache()

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 0
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Disable caching buffer name
let g:neocomplcache_disable_caching_file_path_pattern = '\.ref\|\.txt'
let g:neocomplcache_temporary_dir = $DOTVIM.'/.neocon'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
  \ 'default' : $DOTVIM.'/.neo_default',
  \ 'vimshell' : $DOTVIM.'/.vimshell_hist',
  \ 'scheme' : $DOTVIM.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" For snippet_complete marker.
if has('conceal')
    set conceallevel=2 concealcursor=i
endif

try
    if neocomplcache#is_enabled()
        " neocomplcache enable at startup
        InitNeoComplCache
    else
        " lazy loading for neocomplcache
        augroup MyInitNeocomplcache
            autocmd!
            autocmd InsertEnter * call Init_neocomplcache() | autocmd! MyInitNeocomplcache
        augroup END
    endif
catch /E117/

endtry

" Enable omni completion.
autocmd MyVimrcCmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd MyVimrcCmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd MyVimrcCmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd MyVimrcCmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd MyVimrcCmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
"autocmd MyVimrcCmd FileType ruby setlocal omnifunc=rubycomplete#Complete
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'

if !exists('g:neocomplcache_include_paths')
    let g:neocomplcache_include_paths = {}
endif

if s:MSWindows
    let g:neocomplcache_include_paths.c = "C:/MinGW/lib/gcc/mingw32/4.5.2/include"
    let g:neocomplcache_include_paths.cpp = "C:/MinGW/lib/gcc/mingw32/4.5.2/include/c++,C:/boost_1_47_0"
endif

" For clang_complete
let g:neocomplcache_force_overwrite_completefunc=1
"}}}
"---------------------------------------------------------------------------
" clang_complete:"{{{
"
let g:clang_complete_auto = 1
let g:clang_use_library = 0

" if s:MSWindows
"     let g:clang_exec = '"C:/GnuWin32/bin/clang.exe'
"     let g:clang_user_options = 
"                 \ '-I C:/boost_1_47_0 '.
"                 \ '-fms-extensions -fmsc-version=1500 -fgnu-runtime '.
"                 \ '-D__MSVCRT_VERSION__=0x800 -D_WIN32_WINNT=0x0500 '.
"                 \ '2> NUL || exit 0"'
" endif
"}}}
"---------------------------------------------------------------------------
" vim-fugitive:"{{{
"
nnoremap <Space>gd :<C-u>Gdiff<CR>
nnoremap <Space>gs :<C-u>Gstatus<CR>
nnoremap <Space>gl :<C-u>Extradite<CR>
nnoremap <Space>ga :<C-u>Gwrite<CR>
nnoremap <Space>gc :<C-u>Gcommit<CR>
nnoremap <Space>gC :<C-u>Git commit --amend<CR>
nnoremap <Space>gb :<C-u>Gblame<CR>
nnoremap <Space>gv :<C-u>Gitv<CR>
nnoremap <Space>gV :<C-u>Gitv!<CR>
"}}}
"---------------------------------------------------------------------------
" unite.vim:"{{{
"
" The prefix key.
nnoremap    [unite]   <Nop>
nmap    f [unite]

nnoremap <silent> [unite]a  :<C-u>Unite -prompt=#\  buffer bookmark file_mru file<CR>
nnoremap <silent> [unite]b  :<C-u>UniteWithBufferDir -buffer-name=files -prompt=%\  buffer bookmark file_mru file<CR>
nnoremap <silent> [unite]c  :<C-u>UniteWithCurrentDir -buffer-name=files buffer bookmark file_mru file<CR>
nnoremap <silent> [unite]e  :<C-u>Unite -buffer-name=files everything<CR>
nnoremap <silent> [unite]f  :<C-u>Unite source<CR>
nnoremap <expr>   [unite]g  ':<C-u>Unite grep:*::' . expand("<cword>")
nnoremap <silent> [unite]h  :<C-u>UniteWithCursorWord help<CR>
nnoremap <silent> [unite]m  :<C-u>Unite mark -no-quit<CR>
nnoremap <silent> [unite]o  :<C-u>Unite outline<CR>
nnoremap <silent> [unite]pi :<C-u>Unite neobundle/install<CR>
nnoremap <silent> [unite]pu :<C-u>Unite neobundle/install:!<CR>
nnoremap <silent> [unite]pl :<C-u>Unite neobundle<CR>
nnoremap <silent> [unite]r  :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]t  :<C-u>Unite buffer_tab tab buffer<CR>

let g:unite_kind_file_cd_command = 'TabpageCD'
let g:unite_kind_file_lcd_command = 'TabpageCD'

" Start insert.
let g:unite_enable_start_insert = 1

autocmd MyVimrcCmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings() "{{{
    " Overwrite settings.

    nmap <buffer> <ESC>      <Plug>(unite_exit)
    imap <buffer> jj      <Plug>(unite_insert_leave)
    imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)

    " <C-l>: manual neocomplcache completion.
    inoremap <buffer> <C-l>  <C-x><C-u><C-p><Down>

endfunction"}}}

let g:unite_source_file_mru_limit = 200
let g:unite_source_grep_max_candidates = 50000

" For optimize.
let g:unite_source_file_mru_filename_format = ''

let g:unite_data_directory = $DOTVIM.'/.unite'
"}}}
"---------------------------------------------------------------------------
" textobj-comment:"{{{
"
let g:textobj_comment_no_default_key_mappings = 1
omap ao	<Plug>(textobj-comment-a)
xmap ao	<Plug>(textobj-comment-a)
omap io	<Plug>(textobj-comment-i)
xmap io	<Plug>(textobj-comment-i)
"}}}
"---------------------------------------------------------------------------
" operator-replace:"{{{
"
map _  <Plug>(operator-replace)
"}}}
"---------------------------------------------------------------------------
" operator-camelize:"{{{
"
map <Leader>c <Plug>(operator-camelize)
map <Leader>C <Plug>(operator-decamelize)
"}}}
"---------------------------------------------------------------------------
" operator-sort:"{{{
"
map <Leader>s <Plug>(operator-sort)
"}}}
"---------------------------------------------------------------------------
" qfixhown.vim:"{{{
"
let QFixHowm_Key = 'g'
let QFixHowm_KeyB = ','

let howm_dir             = $DOTVIM.'/howm'
let howm_filename        = '%Y/%m/%Y-%m-%d-%H%M%S.howm'
let howm_fileencoding    = 'utf-8'
let howm_fileformat      = 'dos'
"}}}
"---------------------------------------------------------------------------
" qfixmemo.vim:"{{{
"
let qfixmemo_dir           = $DOTVIM.'/qfixmemo'
let qfixmemo_filename      = '%Y/%m/%Y-%m-%d-%H%M%S.txt'
let qfixmemo_fileencoding  = 'cp932'
let qfixmemo_fileformat    = 'dos'
let qfixmemo_filetype      = 'qfix_memo'
"}}}
"---------------------------------------------------------------------------
" qfixmru.vim:"{{{
"
let QFixMRU_Filename     = $DOTVIM.'/.qfixmru'
let QFixMRU_IgnoreFile   = ''
let QFixMRU_RegisterFile = ''
let QFixMRU_IgnoreTitle  = ''
let g:QFixMRU_Entries    = 20
let QFixMRU_EntryMax     = 300
"}}}
"---------------------------------------------------------------------------
" qfixgrep.vim:"{{{
"
let QFix_PreviewEnable    = 0
let QFix_HighSpeedPreview = 0
let QFix_DefaultPreview   = 0
let QFix_PreviewExclude = '\.pdf$\|\.mp3$\|\.jpg$\|\.bmp$\|\.png$\|\.zip$\|\.rar$\|\.exe$\|\.dll$\|\.lnk$'

let QFix_CopenCmd = ''
let QFix_Height = 10
let QFix_Width = 0
set previewheight=12
let QFix_PreviewHeight = 12
set winwidth=20
let QFix_WindowHeightMin = 0
let QFix_PreviewOpenCmd = ''
let QFix_PreviewWidth  = 0

let QFix_HeightFixMode         = 0

let QFix_CloseOnJump           = 0
let QFix_Edit = 'tab'

let QFix_PreviewFtypeHighlight = 1
let QFix_CursorLine            = 1
let QFix_PreviewCursorLine     = 1
"hi CursorLine guifg=NONE guibg=NONE gui=underline

let QFix_Copen_winfixheight = 1
let QFix_Copen_winfixwidth  = 1
let QFix_Preview_winfixheight = 1
let QFix_Preview_winfixwidth  = 1

let MyGrep_ExcludeReg = '[~#]$\|\.bak$\|\.o$\|\.obj$\|\.exe$\|[/\\]tags$\|[/\\]svn[/\\]\|[/\\]\.git[/\\]\|[/\\]\.hg[/\\]'
let mygrepprg = 'grep'
let MyGrep_ShellEncoding      = 'cp932'
let MyGrep_Damemoji           = 2
let MyGrep_DamemojiReplaceReg = '(..)'
let MyGrep_DamemojiReplace    = '[]'
let MyGrep_yagrep_opt = 0

let MyGrepcmd_useropt = ''

"let MyGrep_Key  = 'g'
"let MyGrep_KeyB = ','

let MyGrep_DefaultSearchWord = 1

let MyGrep_MenuBar = 3

autocmd MyVimrcCmd QuickfixCmdPre make,grep,grepadd,vimgrep,helpgrep copen
"}}}
"---------------------------------------------------------------------------
" vim-indent-guides:"{{{
"
"let g:indent_guides_indent_levels = 30
let g:indent_guides_auto_colors = 1
"let g:indent_guides_color_change_percent = 10
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
"let g:indent_guides_space_guides = 0
let g:indent_guides_enable_on_vim_startup = 0
"}}}
"---------------------------------------------------------------------------
" MultipleSearch:"{{{
"
let g:MultipleSearchMaxColors=13
let g:MultipleSearchColorSequence="red,yellow,blue,green,magenta,lightred,cyan,lightyellow,gray,brown,lightblue,darkmagenta,darkcyan"
let g:MultipleSearchTextColorSequence="white,black,white,black,white,black,black,black,black,white,black,white,white"
"}}}
"---------------------------------------------------------------------------
" vim-textmanip:"{{{
"
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)

xmap <M-d> <Plug>(textmanip-duplicate-down)
nmap <M-d> <Plug>(textmanip-duplicate-down)
xmap <M-D> <Plug>(textmanip-duplicate-up)
nmap <M-D> <Plug>(textmanip-duplicate-up)
"}}}
"---------------------------------------------------------------------------
" tcomment_vim:"{{{
"
let g:tcommentMapLeaderOp1 = ',c'
let g:tcommentMapLeaderOp2 = ',C'
"}}}
"---------------------------------------------------------------------------
" ideone-vim:"{{{
"
let g:ideone_put_url_to_clipboard_after_post = 0
let g:ideone_open_buffer_after_post = 1
"}}}
"---------------------------------------------------------------------------
" project.tar.gz:"{{{
"
let g:proj_flags = "imstc"
nmap <silent> <Leader>P <Plug>ToggleProject
"}}}
"---------------------------------------------------------------------------
" vimproc:"{{{
"
nmap <S-F6> <ESC>:<C-u>call vimproc#system("ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q")<CR>
"}}}
"---------------------------------------------------------------------------
" vimfiler:"{{{
"
nnoremap    [vimfiler]   <Nop>
nmap    <Space>v [vimfiler]

nnoremap <silent> [vimfiler]b  :<C-u>VimFilerBufferDir<CR>
nnoremap <silent> [vimfiler]c  :<C-u>VimFilerCurrentDir<CR>
nnoremap <silent> [vimfiler]d  :<C-u>VimFilerDouble<CR>
nnoremap <silent> [vimfiler]f  :<C-u>VimFilerSimple -no-quit -winwidth=32<CR>
nnoremap <silent> [vimfiler]s  :<C-u>VimShell<CR>

" Edit file by tabedit.
let g:vimfiler_edit_action = 'open'
let g:vimfiler_split_action = 'tabopen'

let g:vimfiler_as_default_explorer = 1

if s:MSWindows
    let g:unite_kind_file_use_trashbox = 1
endif

" Enable file operation commands.
let g:vimfiler_safe_mode_by_default = 0

let g:vimfiler_data_directory = $DOTVIM.'/.vimfiler'

let g:vimfiler_execute_file_list={'txt': 'vim',
            \'vim': 'vim'}
"}}}
"---------------------------------------------------------------------------
" vimshell:"{{{
"
let g:vimshell_interactive_encodings = {'git': 'utf-8'}
let g:vimshell_temporary_directory = $DOTVIM.'/.vimshell'
let g:vimshell_vimshrc_path = $DOTVIM.'/.vimshell/.vimshrc'
let g:vimshell_cd_command = 'TabpageCD'
"}}}
"---------------------------------------------------------------------------
" vim-quickrun:"{{{
"
if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif
" flymake for C/C++{{{
function! Flymake_for_CPP_Setting()
    try
        "" To highlight with a undercurl in quickfix error
        "" The following two lines are written in the .gvimrc
        "execute "highlight qf_error_ucurl gui=undercurl guisp=Red"
        "let g:hier_highlight_group_qf  = "qf_error_ucurl"

        let s:silent_quickfix = quickrun#outputter#quickfix#new()
        function! s:silent_quickfix.finish(session)
            call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
            :cclose
            :HierUpdate
            :QuickfixStatusEnable
        endfunction
        
        call quickrun#register_outputter("silent_quickfix", s:silent_quickfix)

        let g:quickrun_config["CppSyntaxCheck_gcc"] = {
            \ "type"  : "cpp",
            \ "exec"      : "%c %o %s:p ",
            \ "command"   : "g++",
            \ "cmdopt"    : "-fsyntax-only -std=gnu++0x ",
            \ "outputter" : "silent_quickfix",
            \ "runner"    : "vimproc"
        \ }

        let g:quickrun_config["CppSyntaxCheck_msvc"] = {
            \ "type"  : "cpp",
            \ "exec"      : "%c %o %s:p ",
            \ "command"   : "cl.exe",
            \ "cmdopt"    : "/Zs ",
            \ "outputter" : "silent_quickfix",
            \ "runner"    : "vimproc",
            \ "output_encode" : "sjis"
        \ }

        "autocmd MyVimrcCmd BufWritePost *.cpp,*.h,*.hpp :QuickRun CppSyntaxCheck_msvc
    catch /E117/
        
    endtry
endfunction
call Flymake_for_CPP_Setting()
"}}}
" settings for pandoc{{{
let g:quickrun_config['markdown'] = {
      \ 'type': 'markdown/pandoc',
      \ 'outputter': 'browser',
      \ 'cmdopt': '-s'
      \ }
"}}}
"}}}
"---------------------------------------------------------------------------
" vim-ambicmd:"{{{
"
if 1 && filereadable($DOTVIM.'/Bundle/vim-ambicmd/autoload/ambicmd.vim')
    cnoremap <expr> <Space> ambicmd#expand("\<Space>")
    cnoremap <expr> <CR> ambicmd#expand("\<CR>")
    cnoremap <expr> <C-f> ambicmd#expand("\<Right>")
    autocmd MyVimrcCmd CmdwinEnter * call s:init_cmdwin_ambicmd()
    function! s:init_cmdwin_ambicmd()
        inoremap <buffer> <expr> <Space> ambicmd#expand("\<Space>")
        inoremap <buffer> <expr> <CR> ambicmd#expand("\<CR>")
    endfunction
endif
"}}}
"---------------------------------------------------------------------------
" tcommand_vim:"{{{
"
noremap <Leader>: :TCommand<CR>
"}}}
"---------------------------------------------------------------------------
" Source-Explorer-srcexpl.vim:"{{{
"
" // The switch of the Source Explorer                                         "
" nmap <F8> :SrcExplToggle<CR>
"                                                                              "
" // Set the height of Source Explorer window                                  "
 let g:SrcExpl_winHeight = 8
"                                                                              "
" // Set 100 ms for refreshing the Source Explorer                             "
 let g:SrcExpl_refreshTime = 100
"                                                                              "
" // Set "Enter" key to jump into the exact definition context                 "
 let g:SrcExpl_jumpKey = "<ENTER>"
"                                                                              "
" // Set "Space" key for back from the definition context                      "
 let g:SrcExpl_gobackKey = "<SPACE>"
"                                                                              "
" // In order to Avoid conflicts, the Source Explorer should know what plugins "
" // are using buffers. And you need add their bufname into the list below     "
" // according to the command ":buffers!"                                      "
 let g:SrcExpl_pluginList = [
         \ "__Tag_List__",
         \ "_NERD_tree_",
         \ "Source_Explorer"
     \ ]
"                                                                              "
" // Enable/Disable the local definition searching, and note that this is not  "
" // guaranteed to work, the Source Explorer doesn't check the syntax for now. "
" // It only searches for a match with the keyword according to command 'gd'   "
 let g:SrcExpl_searchLocalDef = 1
"                                                                              "
" // Do not let the Source Explorer update the tags file when opening          "
 let g:SrcExpl_isUpdateTags = 0
"                                                                              "
" // Use 'Exuberant Ctags' with '--sort=foldcase -R .' or '-L cscope.files' to "
" //  create/update a tags file                                                "
 let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."
"                                                                              "
" // Set "<F12>" key for updating the tags file artificially                   "
" let g:SrcExpl_updateTagsKey = "<F12>"
"}}}
"---------------------------------------------------------------------------
" gtags.vim:"{{{
"
nmap <Leader>gs :<C-u>Gtags -s <C-R>=expand("<cword>")<CR><CR>
nmap <Leader>gg :<C-u>Gtags -g <C-R>=expand("<cword>")<CR><CR>
nmap <Leader>gf :<C-u>Gtags -f <C-R>=expand("<cfile>")<CR><CR>
nmap <Leader>gr :<C-u>Gtags -r <C-R>=expand("<cword>")<CR><CR>
nmap <Leader>gd :<C-u>Gtags -d <C-R>=expand("<cword>")<CR><CR>
"}}}
"---------------------------------------------------------------------------
" python-mode:"{{{
"
let g:pymode_lint_onfly = 1
let g:pymode_lint_write = 1
let g:pymode_lint_cwindow = 0
let g:pymode_lint_message = 1
let g:pydoc = "python -m pydoc"
let g:pymode_rope = 1
"}}}
"---------------------------------------------------------------------------
" perl-support.vim:"{{{
"
let g:Perl_Debugger = "ptkdb"
"}}}
"---------------------------------------------------------------------------
" haskellmode-vim:"{{{
"
if s:MSWindows
    let g:haddock_browser="C:/Program\ Files/Mozilla\ Firefox/firefox.exe"
else
    let g:haddock_browser="/usr/bin/firefox"
endif
"}}}
"---------------------------------------------------------------------------
" vimclojure:"{{{
"
let g:clj_highlight_builtins = 1
let g:clj_paren_rainbow = 1
"}}}

"---------------------------------------------------------------------------
" vim-ipi:"{{{
"
function! LazyLoading(ft)
    filetype plugin indent off
    for plugin_name in g:ll_plugins[a:ft]
        execute "silent! IP " . plugin_name
    endfor
    filetype plugin indent on
    execute "autocmd! MyIPI_" . a:ft

    if exists('g:ll_post_process[a:ft]')
        for post_process in g:ll_post_process[a:ft]
            execute post_process
        endfor
    endif
endfunction

let g:ll_plugins={}
let g:ll_plugins['c'] = [
            \ 'taglist.vim',
            \ 'TagHighlight',
            \ 'a.vim',
            \ 'c.vim',
            \ 'Source-Explorer-srcexpl.vim',
            \ 'trinity.vim',
            \ 'cscope-menu',
            \ 'gtags.vim',
            \ 'DoxygenToolkit.vim',
            \ ]
let g:ll_plugins['cpp'] = [
            \ 'taglist.vim',
            \ 'TagHighlight',
            \ 'a.vim',
            \ 'c.vim',
            \ 'Source-Explorer-srcexpl.vim',
            \ 'trinity.vim',
            \ 'cscope-menu',
            \ 'gtags.vim',
            \ 'DoxygenToolkit.vim',
            \ ]
let g:ll_plugins['python'] = [
            \ 'pytest.vim',
            \ 'python-mode',
            \ 'taglist.vim',
            \ 'TagHighlight',
            \ ]
let g:ll_plugins['perl'] = [
            \ 'perl-support.vim',
            \ 'taglist.vim',
            \ 'TagHighlight',
            \ ]
let g:ll_plugins['javascript'] = [
            \ 'vim-javascript',
            \ ]
let g:ll_plugins['haskell'] = [
            \ 'vim-filetype-haskell',
            \ 'haskellmode-vim',
            \ 'vim-syntax-haskell-cabal',
            \ 'ghcmod-vim',
            \ ]
let g:ll_post_process={}
let g:ll_post_process['c'] = [
            \ 'silent! ReadTypes',
            \ ]
let g:ll_post_process['cpp'] = [
            \ 'silent! ReadTypes',
            \ ]
let g:ll_post_process['python'] = [
            \ 'silent! ReadTypes',
            \ 'set filetype=python',
            \ ]
let g:ll_post_process['perl'] = [
            \ 'silent! ReadTypes',
            \ ]

if has('vim_starting') && s:ipi_loaded
    " lazy loading of each filetype
    if exists("g:ll_plugins")
        for k in keys(g:ll_plugins)
            execute "augroup " . "MyIPI_" . k
            execute "autocmd!"
            execute "autocmd FileType " . k . " call LazyLoading('" . k . "')"
            execute "augroup END"
        endfor
    endif

    " lazy loading for vim-ref
    nmap <silent> K :<C-u>silent! IP vim-ref<CR><Plug>(ref-keyword)
    vmap <silent> K :<C-u>silent! IP vim-ref<CR><Plug>(ref-keyword)
    command! -nargs=+ Ref
                \ execute 'silent! IP vim-ref'
                \ | call ref#ref(<q-args>)

    " lazy loading for vimfiler
    nnoremap <silent> [vimfiler]b  :<C-u>silent! IP vimfiler<CR>:<C-u>VimFilerBufferDir<CR>
    nnoremap <silent> [vimfiler]c  :<C-u>silent! IP vimfiler<CR>:<C-u>VimFilerCurrentDir<CR>
    nnoremap <silent> [vimfiler]d  :<C-u>silent! IP vimfiler<CR>:<C-u>VimFilerDouble<CR>
    nnoremap <silent> [vimfiler]f  :<C-u>silent! IP vimfiler<CR>:<C-u>VimFilerSimple -no-quit -winwidth=32<CR>

    " lazy loading for vim-quickrun
    function! LoadQuickRun()
        silent! IP vim-quickrun
        silent! IP quicklearn
        call Flymake_for_CPP_Setting()
    endfunction
    map <silent> <Leader>r :<C-u>call LoadQuickRun()<CR><Plug>(quickrun)
    command! -nargs=* -range=0 QuickRun
                \ call LoadQuickRun()
                \ | call quickrun#command(<q-args>, <count>, <line1>, <line2>)
endif
"}}}
"}}}

"---------------------------------------------------------------------------
" Key Mappings:"{{{
"
" Tabpage related mappings
nnoremap <Space>to :<C-u>tabnew<CR>
nnoremap <Space>tq :<C-u>tabclose<CR>

" Move to the position last edited
nnoremap gb '[
nnoremap gp ']

" 'Quote'
onoremap aq  a'
xnoremap aq  a'
onoremap iq  i'
xnoremap iq  i'

" "Double quote"
onoremap ad  a"
xnoremap ad  a"
onoremap id  i"
xnoremap id  i"

" (Round bracket)
onoremap ar  a)
xnoremap ar  a)
onoremap ir  i)
xnoremap ir  i)

" {Curly bracket}
onoremap ac  a}
xnoremap ac  a}
onoremap ic  i}
xnoremap ic  i}

" <Angle bracket>
onoremap aa  a>
xnoremap aa  a>
onoremap ia  i>
xnoremap ia  i>

" [sqUare bracket]
onoremap au  a]
xnoremap au  a]
onoremap iu  i]
xnoremap iu  i]

"}}}

"---------------------------------------------------------------------------
" External Settings:"{{{
"
if 1 && filereadable($MYLOCALVIMRC)
    source $MYLOCALVIMRC
endif
"}}}

" vim: foldmethod=marker
