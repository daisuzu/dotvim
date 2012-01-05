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
    set shellslash
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

"fileencodingsをデフォルトに戻す。
if &encoding == 'utf-8'
    set fileencodings=ucs-bom,utf-8,default,latin1
elseif &encoding == 'cp932'
    set fileencodings=ucs-bom
endif

" 文字コード自動認識のためにfileencodingsを設定する
if &encoding !=# 'utf-8'
    set encoding=japan
    set fileencoding=japan
endif
if has('iconv')
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
    " iconvがeucJP-msに対応しているかをチェック
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'eucjp-ms'
        let s:enc_jis = 'iso-2022-jp-3'
    " iconvがJISX0213に対応しているかをチェック
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'euc-jisx0213'
        let s:enc_jis = 'iso-2022-jp-3'
    endif
    " fileencodingsを構築
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
    "utf-8優先にする
    if &encoding == 'utf-8'
        set fileencodings-=utf-8
        let &fileencodings = substitute(&fileencodings, s:enc_jis, s:enc_jis.',utf-8','')
    endif
    " 定数を処分
    unlet s:enc_euc
    unlet s:enc_jis
endif

" 改行コードの自動認識
set fileformats=dos,unix,mac

" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
    function! AU_ReCheck_FENC()
        if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
            let &fileencoding=&encoding
            if s:MSWindows
                let &fileencoding='cp932'
            endif
        endif
    endfunction
    autocmd BufReadPost MyVimrcCmd * call AU_ReCheck_FENC()
endif

" Windowsで内部エンコーディングを cp932以外にしていて、
" 環境変数に日本語を含む値を設定したい場合に使用する
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
"vimrc_local.vimが存在し、g:no_vimrc_example=1になっていたら
"vimrc_example.vimを読込む
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

" <C-A>:インクリメントと<C-X>:デクリメントを再定義
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
    NeoBundle 'Shougo/neobundle.vim'
    NeoBundle 'Shougo/neocomplcache'
    NeoBundle 'Shougo/neocomplcache-clang'
    NeoBundle 'Shougo/vimfiler'
    NeoBundle 'Shougo/unite.vim'
    NeoBundle 'Shougo/unite-build'
    NeoBundle 'Shougo/vimproc'
    NeoBundle 'Shougo/vimshell'

    NeoBundle 'vim-jp/vimdoc-ja'

    NeoBundle 'kana/vim-textobj-user'
    NeoBundle 'kana/vim-textobj-indent'
    NeoBundle 'kana/vim-textobj-syntax'
    NeoBundle 'kana/vim-filetype-haskell'

    NeoBundle 'tpope/vim-surround'
    NeoBundle 'tpope/vim-markdown'
    NeoBundle 'tpope/vim-fugitive'

    NeoBundle 'gregsexton/gitv'

    NeoBundle 'thinca/vim-visualstar'
    NeoBundle 'thinca/vim-qfreplace'
    NeoBundle 'thinca/vim-ref'
    NeoBundle 'thinca/vim-logcat'
    NeoBundle 'thinca/vim-quickrun'
    NeoBundle 'thinca/vim-prettyprint'
    NeoBundle 'thinca/vim-editvar'
    NeoBundle 'thinca/vim-textobj-between'

    NeoBundle 'dannyob/quickfixstatus'

    NeoBundle 'jceb/vim-hier'

    "NeoBundle 't9md/vim-quickhl'
    NeoBundle 't9md/vim-textmanip'

    NeoBundle 'fuenor/qfixhowm'

    NeoBundle 'hsitz/VimOrganizer'

    NeoBundle 'scrooloose/nerdtree'

    NeoBundle 'abudden/TagHighlight'

    NeoBundle 'tomtom/tcommand_vim'
    NeoBundle 'tomtom/tcomment_vim'

    NeoBundle 'alfredodeza/pytest.vim'

    NeoBundle 'sjl/gundo.vim'

    NeoBundle 'lukerandall/haskellmode-vim'

    NeoBundle 'ujihisa/neco-ghc'
    NeoBundle 'ujihisa/unite-colorscheme'

    NeoBundle 'sgur/unite-qf'

    NeoBundle 'h1mesuke/unite-outline'

    NeoBundle 'tsukkee/unite-help'
    NeoBundle 'tsukkee/unite-tag'

    NeoBundle 'tacroe/unite-mark'

    NeoBundle 'sgur/unite-everything'

    NeoBundle 'zhaocai/unite-scriptnames'

    NeoBundle 'pangloss/vim-javascript'

    NeoBundle 'tyru/operator-camelize.vim'

    NeoBundle 'klen/python-mode'

    NeoBundle 'Takazudo/outline.vim'

    NeoBundle 'nathanaelkane/vim-indent-guides'

    NeoBundle 'gregsexton/VimCalc'

    NeoBundle 'kien/rainbow_parentheses.vim'

    NeoBundle 'Lokaltog/vim-easymotion'

    NeoBundle 'h1mesuke/vim-alignta'

    NeoBundle 'altercation/vim-colors-solarized'

    NeoBundle 'git://repo.or.cz/vcscommand'

    NeoBundle 'a.vim'
    "NeoBundle 'ACScope'
    NeoBundle 'Align'
    NeoBundle 'AnsiEsc.vim'
    NeoBundle 'BlockDiff'
    NeoBundle 'c.vim'
    NeoBundle 'CCTree'
    NeoBundle 'cecutil'
    NeoBundle 'copypath.vim'
    "NeoBundle 'CRefVim'
    NeoBundle 'cscope-menu'
    "NeoBundle 'cscope-quickfix'
    NeoBundle 'diffchanges.vim'
    NeoBundle 'DirDiff.vim'
    NeoBundle 'DoxygenToolkit.vim'
    NeoBundle 'DrawIt'
    NeoBundle 'errormarker.vim'
    NeoBundle 'foldsearch'
    NeoBundle 'format.vim'
    NeoBundle 'multvals.vim'
    NeoBundle 'MultipleSearch'
    "NeoBundle 'MultipleSearch2.vim'
    NeoBundle 'matchparenpp'
    NeoBundle 'matchit.zip'
    NeoBundle 'Marks-Browser'
    NeoBundle 'gtags.vim'
    NeoBundle 'occur.vim'
    NeoBundle 'operator-user'
    NeoBundle 'perl-support.vim'
    NeoBundle 'project.tar.gz'
    NeoBundle 'RST-Tables'
    NeoBundle 'histwin.vim'
    NeoBundle 'pydoc.vim'
"    NeoBundle 'XPstatusline'
    NeoBundle 'Source-Explorer-srcexpl.vim'
    NeoBundle 'trinity.vim'
    NeoBundle 'ShowMultiBase'
    NeoBundle 'ttoc'
    NeoBundle 'tlib'
    NeoBundle 'taglist.vim'
    NeoBundle 'tagexplorer.vim'
    "NeoBundle 'Vim-JDE'
    NeoBundle 'VOoM'
    NeoBundle 'wokmarks.vim'
    NeoBundle 'L9'
    "NeoBundle 'QuickBuf'
    NeoBundle 'sequence'
    NeoBundle 'Tabbi'
    NeoBundle 'ttags'
    NeoBundle 'csv.vim'
    "NeoBundle 'highlight.vim'
    NeoBundle 'Search-unFold'
    NeoBundle 'thermometer'

    NeoBundle 'Color-Sampler-Pack'
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
set clipboard+=unnamed
" タブの画面上での幅
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
" タブをスペースに展開する(noexpandtab:展開しない)
set expandtab
" 自動的にインデントする (noautoindent:インデントしない)
set autoindent
" Smart indenting
set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
inoremap # X<C-H><C-V>#
" バックスペースでインデントや改行を削除できるようにする
set backspace=indent,eol,start
" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
" テキスト挿入中の自動折り返しを日本語に対応させる
set formatoptions&
set formatoptions+=mM
" 日本語整形スクリプト(by. 西岡拓洋さん)用の設定
let format_allow_over_tw = 1    " ぶら下り可能幅
" バックアップファイルを作成しない (次行の先頭の " を削除すれば有効になる)
set nobackup
" tags設定{{{
set tags=./tags
"上位下位ディレクトリのctagsファイルを探す
set tags+=tags;
set tags+=./**/tags
"}}}
" grep設定{{{
set grepprg=grep\ -nH
"set grepprg=ack.pl\ -a
au MyVimrcCmd QuickfixCmdPost make,grep,grepadd,vimgrep,helpgrep copen
au MyVimrcCmd QuickfixCmdPost l* lopen
"}}}
" あらゆる言語に対してキーワードの補完を有効にする{{{
autocmd MyVimrcCmd FileType *
\   if &l:omnifunc == ''
\ |   setlocal omnifunc=syntaxcomplete#Complete
\ | endif
"}}}
"}}}

"---------------------------------------------------------------------------
" View:"{{{
"
" 行番号を表示 (nonumber:非表示)
set number
" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
" コマンドラインの高さ (Windows用gvim使用時はgvimrcを編集すること)
set cmdheight=2
" コマンドをステータス行に表示
set showcmd
" タイトルを表示
set title
" 常にタブバーを表示
set showtabline=2
" 印字不可能文字を16進数で表示
set display=uhex
" 長い行を折り折り返さない (wrap:折り返す)
set nowrap
nnoremap <Space>ow :<C-u>setlocal wrap!\|setlocal wrap?<CR>
" タブや改行を表示 (list:表示)
set nolist
nnoremap <Space>ol :<C-u>setlocal list!\|setlocal list?<CR>
" どの文字でタブや改行を表示するかを設定
set listchars=tab:>-,extends:<,precedes:>,trail:-,eol:$,nbsp:%
" 全角スペース・行末のスペース・タブの可視化{{{
if has("syntax")
    syntax on

    " PODバグ対策
    syn sync fromstart

    function! ActivateInvisibleIndicator()
        " 下の行の"　"は全角スペース
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
fun! StatusLineGetPath() "{{{
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
    au! Statusline

    au BufEnter * call <SID>SetFullStatusline()
    au BufLeave,BufNew,BufRead,BufNewFile * call <SID>SetSimpleStatusline()
augroup END

fun! StatusLineRealSyn()
    let synId = synID(line('.'),col('.'),1)
    let realSynId = synIDtrans(synId)
    if synId == realSynId
        return 'Normal'
    else
        return synIDattr( realSynId, 'name' )
    endif
endfunction

fun! s:SetFullStatusline() "{{{
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

fun! s:SetSimpleStatusline() "{{{
    setlocal statusline=
    setlocal statusline+=%#StatuslineNC#%-0.20{StatusLineGetPath()}%0* " path
    setlocal statusline+=\/%t\                       " file name
endfunction "}}}
"}}}
"}}}

"---------------------------------------------------------------------------
" Search:"{{{
"
" 検索時にファイルの最後まで行ったら最初に戻らない(wrapscan:戻る)
set nowrapscan

set ignorecase
nnoremap <Space>oi :<C-u>setlocal ignorecase!\|setlocal ignorecase?<CR>

set smartcase
nnoremap <Space>os :<C-u>setlocal smartcase!\|setlocal smartcase?<CR>

set hlsearch
"Escの2回押しでハイライト消去
nmap <ESC><ESC> :nohlsearch<CR><ESC>
"}}}

"---------------------------------------------------------------------------
"  Utilities:"{{{
"
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
cnoreabbrev <expr> cd (getcmdtype() == ':' && getcmdline() ==# 'cd') ? 'TabpageCD' : 'cd'
"}}}

" 開いているファイルのディレクトリに移動する{{{
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
nnoremap <A-Up> [c
nnoremap <A-Down> ]c
function! DiffGet() "{{{
    try
        execute 'diffget'
    catch/E101/
        execute 'diffget //2'
    endtry
    call SetDiffupdateMap()
endfunction "}}}
nnoremap <A-Right> :<C-u>call DiffGet()<CR>
function! DiffPut() "{{{
    try
        execute 'diffput'
    catch/E101/
        execute 'diffget //3'
    endtry
    call SetDiffupdateMap()
endfunction "}}}
nnoremap <A-Left> :<C-u>call DiffPut()<CR>
function! SetDiffupdateMap() "{{{
    if &diff
        nnoremap <F5> :<C-u>diffupdate<CR>
    else
        nnoremap <F5> :<C-u>Unite buffer<CR>
    endif
endfunction "}}}
au MyVimrcCmd BufEnter * call SetDiffupdateMap()
"}}}

" LoadRope() "ropevim{{{
if has('python')
let loaded_ropevim = 0

function! LoadRope()
python << EOF
try:
    import ropevim
except :
    pass
EOF
endfunction

if !exists("loaded_alternateFile")
    call LoadRope()
    let loaded_ropevim = 1
endif
endif
"}}}
" DiffClip() "クリップボードと選択行でdiff{{{
command! -nargs=0 -range DiffClip <line1>, <line2>:call DiffClip('0')
"レジスタ reg とdiffをとる
function! DiffClip(reg) range
    exe "let @a=@" . a:reg
    exe a:firstline  . "," . a:lastline . "y b"
    tabnew "new
    " このウィンドウを閉じたらバッファを消去するようにする
    set buftype=nofile bufhidden=wipe
    put a
    diffthis
    lefta vnew "vnew
    set buftype=nofile bufhidden=wipe
    put b
    diffthis
endfunction
"}}}
" NextIndent() "次のインデントに移動{{{
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
" flymake for python, perl{{{
augroup FlyQuickfixMakeCmd
    autocmd!
augroup END

function! FlyquickfixPrgSet(mode)
    if a:mode == 0
        """ setting for pylint
"        setlocal makeprg=/usr/bin/pylint\ --rcfile=$HOME/.pylint\ -e\ %
"        setlocal makeprg=pylint.bat\ %
        setlocal makeprg=python\ -m\ pylint.lint\ %
        setlocal errorformat=%t:%l:%m
        let g:flyquickfixmake_mode = 0
"        echo "flymake prg: pylint"
    elseif a:mode == 1
        """ setting for pyflakes
        setlocal makeprg=pyflakes\ %
        setlocal errorformat=%f:%l:%m
        let g:flyquickfixmake_mode = 1
"        echo "flymake prg: pyflakes"
    elseif a:mode == 8
        """ setting for pep8.py
        setlocal makeprg=pep8\ %
        setlocal errorformat=%f:%l:%c:%m
        let g:flyquickfixmake_mode = 8
"        echo "flymake prg: pep8"
    elseif a:mode == 10
        """ setting for perl
        setlocal makeprg=vimparse.pl\ -c\ %
        setlocal errorformat=%f:%l:%m
"        setlocal shellpipe=2>&1\ >
        let g:flyquickfixmake_mode = 10
"        echo "flymake prg: perl"
    endif
endfunction

function! FlyquickfixToggleSet()
    if g:python_flyquickfixmake == 1
        au! FlyQuickfixMakeCmd
        echo "not-used flymake"
        let g:python_flyquickfixmake = 0
    else
        echo "used flymake"
        let g:python_flyquickfixmake = 1
        au FlyQuickfixMakeCmd BufWritePost *.py make
        au FlyQuickfixMakeCmd BufWritePost *.pm,*.pl,*.t make
    endif
endfunction

if !exists("g:python_flyquickfixmake")
    let g:python_flyquickfixmake = 1
    call FlyquickfixPrgSet(8)

    "au BufWritePost *.py silent make
    au FlyQuickfixMakeCmd BufWritePost *.py make
    au FlyQuickfixMakeCmd BufWritePost *.pm,*.pl,*.t make
endif

if !exists("g:flyquickfixmake_mode")
    let g:flyquickfixmake_mode = 8
endif

function! FlyquickfixReSet()
    if g:flyquickfixmake_mode == 0
        call FlyquickfixPrgSet(0)
    elseif g:flyquickfixmake_mode == 1
        call FlyquickfixPrgSet(1)
    elseif g:flyquickfixmake_mode == 8
        call FlyquickfixPrgSet(8)
    else
        call FlyquickfixPrgSet(10)
    endif
endfunction

au MyVimrcCmd BufEnter *.py call FlyquickfixReSet()
au MyVimrcCmd BufEnter *.pm,*.pl,*.t call FlyquickfixPrgSet(10)
" 新規ファイルからperlファイルを作成するときにmakeprgをperl用に変更する
au MyVimrcCmd FileType perl call FlyquickfixPrgSet(10)

noremap fs :call FlyquickfixToggleSet()<CR>
noremap pl :call FlyquickfixPrgSet(0)<CR>
noremap pf :call FlyquickfixPrgSet(1)<CR>
noremap p8 :call FlyquickfixPrgSet(8)<CR>
"}}}
" cscope_maps{{{
"
" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim... 
if has("cscope")

    """"""""""""" Standard cscope/vim boilerplate

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


    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.  
    "

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>


    " Hitting CTRL-space *twice* before the search type does a vertical 
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>


    """"""""""""" key map timeouts
    "
    " By default Vim will only wait 1 second for each keystroke in a mapping.
    " You may find that too short with the above typemaps.  If so, you should
    " either turn off mapping timeouts via 'notimeout'.
    "
    "set notimeout 
    "
    " Or, you can keep timeouts, by uncommenting the timeoutlen line below,
    " with your own personal favorite value (in milliseconds):
    "
    "set timeoutlen=4000
    "
    " Either way, since mapping timeout settings by default also set the
    " timeouts for multicharacter 'keys codes' (like <F1>), you should also
    " set ttimeout and ttimeoutlen: otherwise, you will experience strange
    " delays as vim waits for a keystroke after you hit ESC (it will be
    " waiting to see if the ESC is actually part of a key code like <F1>).
    "
    "set ttimeout 
    "
    " personally, I find a tenth of a second to work well for key code
    " timeouts. If you experience problems and have a slow terminal or network
    " connection, set it higher.  If you don't set ttimeoutlen, the value for
    " timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
    "
    "set ttimeoutlen=100

endif
"}}}
" unite-quickgrep "{{{
let g:quickgrep_words = {}
" let g:quickgrep_words['keyword1'] = 'a grep word'
" let g:quickgrep_words['keyword2'] = 'grep word 1\|grep word 2'

let s:source_quickgrep = {
      \ 'name': 'quickgrep',
      \ 'hooks' : {},
      \ }
call unite#define_source(s:source_quickgrep)

let s:quickgrep_list = []
function! s:source_quickgrep.hooks.on_init(args, context)
    let s:quickgrep_list = []    
    for key in keys(g:quickgrep_words)
        call add(s:quickgrep_list, {
              \ 'word' : key,
              \ 'kind' : 'command',
              \ 'action__command' : 'vimgrep /' . g:quickgrep_words[key] . '/ %',
              \ })
    endfor
endfunc

function! s:source_quickgrep.gather_candidates(args, context)
    return s:quickgrep_list
endfunction
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
" qfixhown.vim:"{{{
"
"キーマップリーダー
let QFixHowm_Key = 'g'
let QFixHowm_KeyB = ','
"howm_dirはファイルを保存したいディレクトリを設定。
let howm_dir             = $DOTVIM.'/howm'
let howm_filename        = '%Y/%m/%Y-%m-%d-%H%M%S.howm'
let howm_fileencoding    = 'utf-8'
let howm_fileformat      = 'dos'
"}}}
"---------------------------------------------------------------------------
" qfixmemo.vim:"{{{
"
" メモファイルの保存先
let qfixmemo_dir           = $DOTVIM.'/qfixmemo'
" メモファイルのファイル名
let qfixmemo_filename      = '%Y/%m/%Y-%m-%d-%H%M%S.txt'
" メモファイルのファイルエンコーディング
let qfixmemo_fileencoding  = 'cp932'
" メモファイルのファイルフォーマット(改行コード)
let qfixmemo_fileformat    = 'dos'
" メモのファイルタイプ
let qfixmemo_filetype      = 'qfix_memo'
"}}}
"---------------------------------------------------------------------------
" qfixmru.vim:"{{{
"
" MRUの保存ファイル名
let QFixMRU_Filename     = $DOTVIM.'/.qfixmru'
" MRUに登録しないファイル名(正規表現)
let QFixMRU_IgnoreFile   = ''
" MRUに登録するファイルの正規表現(設定すると指定ファイル以外登録されない)
let QFixMRU_RegisterFile = ''
" MRUに登録しないタイトル(正規表現)
let QFixMRU_IgnoreTitle  = ''
" MRU表示数
let g:QFixMRU_Entries    = 20
" MRU内部のエントリ最大保持数
let QFixMRU_EntryMax     = 300
"}}}
"---------------------------------------------------------------------------
" qfixgrep.vim:"{{{
"
"Quickfixウィンドウでプレビューを有効にする。
let QFix_PreviewEnable    = 0
"ハイスピードプレビューを有効にする
let QFix_HighSpeedPreview = 0
"プレビューをQFixGrep、QFixHowm以外でも有効にする
let QFix_DefaultPreview   = 0
"プレビュー対象外ファイルの指定
let QFix_PreviewExclude = '\.pdf$\|\.mp3$\|\.jpg$\|\.bmp$\|\.png$\|\.zip$\|\.rar$\|\.exe$\|\.dll$\|\.lnk$'

"Quickfixウィンドウの開き方指定
let QFix_CopenCmd = ''
"Quickfixウィンドウの高さ
let QFix_Height = 10
"Quickfixウィンドウの幅
let QFix_Width = 0
"プレビューウィンドウの高さ
set previewheight=12
"プレビューウィンドウの高さ(previewheightを使用したくない場合)
let QFix_PreviewHeight = 12
"カレントウィンドウの最低幅
set winwidth=20
"ファイルを開いたウィンドウの最低高さ。
let QFix_WindowHeightMin = 0
"プレビューウィンドウの開き方指定
let QFix_PreviewOpenCmd = ''
" プレビューウィンドウの横幅指定
let QFix_PreviewWidth  = 0

"QuickfixウィンドウサイズをQFix_HeightDefaultに固定する/しない。
"QFix_HeightDefaultは無指定なら、起動時にQFix_Heightに設定される。
let QFix_HeightFixMode         = 0

"Quickfixウィンドウから開いた後ウィンドウを閉じる/閉じない。
let QFix_CloseOnJump           = 0
"Quickfixウィンドウの <S-CR> は分割ではなくタブで開くには 'tab'に設定する。
let QFix_Edit = ''

"Quickfixウィンドウのプレビューでfiletypeのハイライトを有効にする。
"環境やファイルサイズによっては重くなるので、その場合はOFFにしてください。
let QFix_PreviewFtypeHighlight = 1
"カーソルラインを表示する
let QFix_CursorLine            = 1
"プレビュー画面のカーソルラインを表示する
let QFix_PreviewCursorLine     = 1
"アンダーラインにしたい場合は次のようにハイライトを設定する。
"hi CursorLine guifg=NONE guibg=NONE gui=underline

"Quickfixウィンドウの属性
let QFix_Copen_winfixheight = 1
let QFix_Copen_winfixwidth  = 1
"previewウィンドウの属性
let QFix_Preview_winfixheight = 1
let QFix_Preview_winfixwidth  = 1

"grepの対象にしたくないファイル名の正規表現
let MyGrep_ExcludeReg = '[~#]$\|\.bak$\|\.o$\|\.obj$\|\.exe$\|[/\\]tags$\|[/\\]svn[/\\]\|[/\\]\.git[/\\]\|[/\\]\.hg[/\\]'
"使用するgrepの指定。
let mygrepprg = 'grep'
"外部grep(shell)のエンコードを指定する。
let MyGrep_ShellEncoding      = 'cp932'
"「だめ文字」対策を有効/無効
let MyGrep_Damemoji           = 2
"「だめ文字」を置き換える正規表現
let MyGrep_DamemojiReplaceReg = '(..)'
"「だめ文字」を自分で追加指定したい場合は正規表現で指定する。
let MyGrep_DamemojiReplace    = '[]'
"yagrepのマルチバイトオプション
let MyGrep_yagrep_opt = 0

"ユーザ定義可能な追加オプション
let MyGrepcmd_useropt = ''

"Grepコマンドのキーマップ
"let MyGrep_Key  = 'g'
"Grepコマンドの2ストローク目キーマップ
"let MyGrep_KeyB = ','

"QFixGrepの検索時にカーソル位置の単語を拾う/拾わない
let MyGrep_DefaultSearchWord = 1

"gvimのメニューバーに登録する/しない
let MyGrep_MenuBar = 3
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
" vim-textmanip:"{{{
"
"" 選択したテキストの移動
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)
"" 行の複製
xmap <M-d> <Plug>(textmanip-duplicate-down)
nmap <M-d> <Plug>(textmanip-duplicate-down)
xmap <M-D> <Plug>(textmanip-duplicate-up)
nmap <M-D> <Plug>(textmanip-duplicate-up)
"}}}
"---------------------------------------------------------------------------
" tcommand_vim:"{{{
"
noremap <Leader>: :TCommand<CR>
"}}}
"---------------------------------------------------------------------------
" Marks-Browser:"{{{
"
let marksCloseWhenSelected = 0
"}}}
"---------------------------------------------------------------------------
" Align:"{{{
"
let g:Align_xstrlen = 3
"}}}
"---------------------------------------------------------------------------
" MultipleSearch:"{{{
"
let g:MultipleSearchMaxColors=13
let g:MultipleSearchColorSequence="red,yellow,blue,green,magenta,lightred,cyan,lightyellow,gray,brown,lightblue,darkmagenta,darkcyan"
let g:MultipleSearchTextColorSequence="white,black,white,black,white,black,black,black,black,white,black,white,white"
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
let g:ref_alc_start_linenumber = 39 " 余計な行を読み飛ばす
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
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
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

try
    call neocomplcache#is_enabled()
    " Plugin key-mappings.
    imap <C-k>     <Plug>(neocomplcache_snippets_expand)
    smap <C-k>     <Plug>(neocomplcache_snippets_expand)
    inoremap <expr><C-g>     neocomplcache#undo_completion()
    inoremap <expr><C-l>     neocomplcache#complete_common_string()

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

    " AutoComplPop like behavior.
    "let g:neocomplcache_enable_auto_select = 1

    " Shell like behavior(not recommended).
    "set completeopt&
    "set completeopt+=longest
    "let g:neocomplcache_enable_auto_select = 1
    "let g:neocomplcache_disable_auto_complete = 1
    "inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<TAB>"
    "inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
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
let g:neocomplcache_include_paths.c = "C:/MinGW/lib/gcc/mingw32/4.5.2/include"
let g:neocomplcache_include_paths.cpp = "C:/MinGW/lib/gcc/mingw32/4.5.2/include/c++,C:/boost_1_47_0"
"}}}
"---------------------------------------------------------------------------
" neocomplcache-clang:"{{{
"
" Use clang dll.
let g:neocomplcache_clang_use_library = 1
"let g:neocomplcache_clang_library_path='C:/GnuWin32/bin'
" More user include path.
let g:neocomplcache_clang_user_options =
\ '-I C:/MinGW/lib/gcc/mingw32/4.5.2/include '.
\ '-I C:/MinGW/lib/gcc/mingw32/4.5.2/include/c++ '.
\ '-I C:/MinGW/lib/gcc/mingw32/4.6.2/include '.
\ '-I C:/MinGW/lib/gcc/mingw32/4.6.2/include/c++ '.
\ '-I C:/Program\ Files/Microsoft\ Visual\ Studio\ 9.0/VC/include '.
\ '-I C:/Program\ Files/Microsoft\ SDKs/Windows/v6.0A/Include '.
\ '-I C:/boost_1_47_0 '.
\ '-fms-extensions -fgnu-runtime '.
\ '-include malloc.h '
" More neocomplcache candidates.
let g:neocomplcache_max_list = 1000
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
nnoremap <silent> [unite]r  :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]o  :<C-u>Unite outline<CR>
nnoremap <silent> [unite]h  :<C-u>UniteWithCursorWord help<CR>
nnoremap <silent> [unite]pi  :<C-u>Unite neobundle/install<CR>
nnoremap <silent> [unite]pu  :<C-u>Unite neobundle/install:!<CR>
nnoremap <silent> [unite]pl  :<C-u>Unite neobundle<CR>
nnoremap  [unite]f  :<C-u>Unite source<CR>

" Start insert.
let g:unite_enable_start_insert = 1

autocmd MyVimrcCmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()"{{{
    " Overwrite settings.

    nmap <buffer> <ESC>      <Plug>(unite_exit)
    imap <buffer> jj      <Plug>(unite_insert_leave)
    "imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)

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
" vimfiler:"{{{
"
" Edit file by tabedit.
let g:vimfiler_edit_action = 'open'
let g:vimfiler_split_action = 'tabopen'

let g:vimfiler_as_default_explorer = 0

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
"}}}
"---------------------------------------------------------------------------
" vimproc:"{{{
"
nmap <S-F6> <ESC>:<C-u>call vimproc#system("ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q")<CR>
"}}}
"---------------------------------------------------------------------------
" errormarker.vim:"{{{
"
let errormarker_disablemappings = 1
"}}}
"---------------------------------------------------------------------------
" python-mode:"{{{
"
let g:pymode_lint_write = 0
let g:pydoc = "python -m pydoc"
let g:pymode_rope = 0
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
"}}}
"---------------------------------------------------------------------------
" vim-qfreplace:"{{{
"
"if !exists('b:undo_ftplugin')
"    let b:undo_ftplugin = ''
"endif
"let b:undo_ftplugin .= '| execute "delcommand Qfreplace"'

command! -nargs=? -buffer Qfreplace call qfreplace#start(<q-args>)
au MyVimrcCmd Bufenter * command! -nargs=? -buffer Qfreplace call qfreplace#start(<q-args>)
"}}}
"---------------------------------------------------------------------------
" perl-support.vim:"{{{
"
let g:Perl_Debugger = "ptkdb"
"}}}
"---------------------------------------------------------------------------
" project.tar.gz:"{{{
"
let g:proj_flags = "imstc"
nmap <silent> <Leader>P <Plug>ToggleProject
"}}}
"---------------------------------------------------------------------------
" vim-fugitive:"{{{
"
nnoremap <Space>gd :<C-u>Gdiff<CR>
nnoremap <Space>gs :<C-u>Gstatus<CR>
nnoremap <Space>gl :<C-u>Glog<CR>
nnoremap <Space>ga :<C-u>Gwrite<CR>
nnoremap <Space>gc :<C-u>Gcommit<CR>
nnoremap <Space>gC :<C-u>Git commit --amend<CR>
nnoremap <Space>gb :<C-u>Gblame<CR>
nnoremap <Space>gv :<C-u>Gitv<CR>
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
" vim-quickrun:"{{{
"
" flymake for C/C++{{{
try
    if !exists('g:quickrun_config')
        let g:quickrun_config = {}
    endif

    "" quickfix のエラー箇所を波線でハイライト
    "" 以下の2行は   _gvimrcに記載
    "execute "highlight qf_error_ucurl gui=undercurl guisp=Red"
    "let g:hier_highlight_group_qf  = "qf_error_ucurl"

    " quickfix に出力して、ポッポアップはしない outputter/quickfix
    " すでに quickfix ウィンドウが開いている場合は閉じるので注意
    let s:silent_quickfix = quickrun#outputter#quickfix#new()
    function! s:silent_quickfix.finish(session)
        call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
        :cclose
        " vim-hier の更新
        :HierUpdate
        " quickfix への出力後に quickfixstatus を有効に
        :QuickfixStatusEnable
    endfunction
    " quickrun に登録
    call quickrun#register_outputter("silent_quickfix", s:silent_quickfix)

    " シンタックスチェック用の quickrun.vim のコンフィグ
    " gcc 版
    let g:quickrun_config["CppSyntaxCheck_gcc"] = {
        \ "type"  : "cpp",
        \ "exec"      : "%c %o %s:p ",
        \ "command"   : "g++",
        \ "cmdopt"    : "-fsyntax-only -std=gnu++0x ",
        \ "outputter" : "silent_quickfix",
        \ "runner"    : "vimproc"
    \ }

    " msvc 版
    " .h ファイルの場合はうまく動かない
    let g:quickrun_config["CppSyntaxCheck_msvc"] = {
        \ "type"  : "cpp",
        \ "exec"      : "%c %o %s:p ",
        \ "command"   : "cl.exe",
        \ "cmdopt"    : "/Zs ",
        \ "outputter" : "silent_quickfix",
        \ "runner"    : "vimproc",
        \ "output_encode" : "sjis"
    \ }

    " ファイルの保存後に quickrun.vim が実行するように設定する
    "autocmd MyVimrcCmd BufWritePost *.cpp,*.h,*.hpp :QuickRun CppSyntaxCheck_msvc
catch /E117/
    
endtry
"}}}
" settings for pandoc{{{
let g:quickrun_config['markdown'] = {
      \ 'type': 'markdown/pandoc',
      \ 'outputter': 'browser',
      \ 'cmdopt': '-s'
      \ }
"}}}
"}}}
"}}}

"---------------------------------------------------------------------------
" Key Mappings:"{{{
"
"ファイラー呼び出し
nnoremap <F8> :<C-u>VimFilerSimple -no-quit -winwidth=32<CR>
nnoremap <S-F8> :<C-u>NERDTreeToggle<CR>

"マーク一覧呼び出し
nnoremap <F7> :<C-u>MarksBrowser<CR>

"Taglist呼び出し
nnoremap <F6> :<C-u>TagExplorer<CR>

"バッファ一覧呼び出し
nnoremap <F5> :<C-u>Unite buffer<CR>

nnoremap <F4> :<C-u>NeoComplCacheEnable<CR>
nnoremap <S-F4> :<C-u>NeoComplCacheDisable<CR>

" 最後に編集された位置に移動
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

" コメント/コメントアウト設定{{{
" lhs comments
vmap ,# :s/^/#/<CR>:nohlsearch<CR>
vmap ,/ :s/^/\/\//<CR>:nohlsearch<CR>
vmap ,> :s/^/> /<CR>:nohlsearch<CR>
vmap ," :s/^/\"/<CR>:nohlsearch<CR>
vmap ,% :s/^/%/<CR>:nohlsearch<CR>
vmap ,! :s/^/!/<CR>:nohlsearch<CR>
vmap ,; :s/^/;/<CR>:nohlsearch<CR>
vmap ,- :s/^/--/<CR>:nohlsearch<CR>
vmap ,c :s/^\/\/\\|^--\\|^> \\|^[#"%!;]//<CR>:nohlsearch<CR>

" wrapping comments
vmap ,* :s/^\(.*\)$/\/\* \1 \*\//<CR>:nohlsearch<CR>
vmap ,( :s/^\(.*\)$/\(\* \1 \*\)/<CR>:nohlsearch<CR>
vmap ,< :s/^\(.*\)$/<!-- \1 -->/<CR>:nohlsearch<CR>
vmap ,d :s/^\([/(]\*\\|<!--\) \(.*\) \(\*[/)]\\|-->\)$/\2/<CR>:nohlsearch<CR>

" block comments
vmap ,b v`<I<CR><esc>k0i/*<ESC>`>j0i*/<CR><esc><ESC>
vmap ,h v`<I<CR><esc>k0i<!--<ESC>`>j0i--><CR><esc><ESC>
"}}}
"}}}

"---------------------------------------------------------------------------
" External Settings:"{{{
"
if 1 && filereadable($MYLOCALVIMRC)
    source $MYLOCALVIMRC
endif
"}}}

" vim: foldmethod=marker
