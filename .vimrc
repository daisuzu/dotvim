"---------------------------------------------------------------------------
" .vimrc
"---------------------------------------------------------------------------
" Initialize:"{{{
"
augroup MyVimrcCmd
    autocmd!
augroup END

let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')
let s:Android = !s:MSWindows && executable('uname') ? system('uname -m')=~#'armv7l' : 0

if !exists('$DOTVIM')
    if s:MSWindows
        let $DOTVIM = expand($VIM . '/vimfiles')
    else
        let $DOTVIM = expand('~/.vim')
    endif
endif

let $MYLOCALVIMRC = $DOTVIM.'/.local.vimrc'

nnoremap <silent> <Space>ev :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> <Space>eg :<C-u>edit $MYGVIMRC<CR>
nnoremap <silent> <Space>el :<C-u>edit $MYLOCALVIMRC<CR>

nnoremap <silent> <Space>tv :<C-u>tabedit $MYVIMRC<CR>
nnoremap <silent> <Space>tg :<C-u>tabedit $MYGVIMRC<CR>
nnoremap <silent> <Space>tl :<C-u>tabedit $MYLOCALVIMRC<CR>

nnoremap <silent> <Space>rv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif <CR>
nnoremap <silent> <Space>rg :<C-u>source $MYGVIMRC<CR>
nnoremap <silent> <Space>rl :<C-u>if 1 && filereadable($MYLOCALVIMRC) \| source $MYLOCALVIMRC \| endif <CR>

if s:MSWindows
    " set shellslash
    set visualbell t_vb=
endif
nnoremap <Space>o/ :<C-u>setlocal shellslash! shellslash?<CR>

set noautochdir
nnoremap <Space>oc :<C-u>setlocal autochdir! autochdir?<CR>

"---------------------------------------------------------------------------
" Encoding:"{{{
"
" based on encode.vim
" https://sites.google.com/site/fudist/Home/vim-nihongo-ban/vim-utf8
if !has('gui_macvim')
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
        " check whether iconv supports eucJP-ms.
        if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
            let s:enc_euc = 'eucjp-ms'
            let s:enc_jis = 'iso-2022-jp-3'
            " check whether iconv supports JISX0213.
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
        " give priority to utf-8
        if &encoding == 'utf-8'
            set fileencodings-=utf-8
            let &fileencodings = substitute(&fileencodings, s:enc_jis, s:enc_jis.',utf-8','')
        endif

        " clean up constant
        unlet s:enc_euc
        unlet s:enc_jis
    endif

    " set fileformats automatic recognition
    if s:MSWindows
        set fileformats=dos,unix,mac
    else
        set fileformats=unix,mac,dos
    endif

    " to use the encoding to fileencoding when not included the Japanese
    if has('autocmd')
        function! AU_ReCheck_FENC()
            if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
                let &fileencoding = &encoding
                if s:MSWindows
                    let &fileencoding = 'cp932'
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
        if s:MSWindows && has('iconv') && &enc != 'cp932'
            let cmd = iconv(cmd, &enc, 'cp932')
        endif
        exec cmd
    endfunction
endif
"}}}

"---------------------------------------------------------------------------
" MacVim:"{{{
"
if has('gui_macvim')
    set macmeta
    let macvim_hig_shift_movement = 1
    let macvim_skip_cmd_opt_movement = 1

    if has('kaoriya') && has('vim_starting')
        let $PATH = simplify($VIM . '/../../MacOS') . ':' . $PATH
        set migemodict=$VIMRUNTIME/dict/migemo-dict
        set migemo

        let $SSH_ASKPASS = simplify($VIM . '/../../MacOS') . '/macvim-askpass'
        set noimdisable
        set imdisableactivate
    endif
endif
"}}}
"}}}

"---------------------------------------------------------------------------
" Load Plugins:"{{{
"
let $PACKPATH = $DOTVIM . '/pack/Bundle'
if !exists('$GIT_PROTOCOL')
    let $GIT_PROTOCOL = 'https'
endif
if s:Android
    let $GITHUB_COM = $GIT_PROTOCOL.'://207.97.227.239/'
else
    let $GITHUB_COM = $GIT_PROTOCOL.'://github.com/'
endif
" let $BITBUCKET_ORG = 'https://bitbucket.org/'

let s:plugins = {'start': [], 'opt': []}
call add(s:plugins.opt, $GITHUB_COM.'mattn/webapi-vim')
call add(s:plugins.opt, $GITHUB_COM.'vim-jp/vimdoc-ja')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-ref')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-ft-help_fold')
call add(s:plugins.opt, $GITHUB_COM.'tpope/vim-fugitive')
call add(s:plugins.opt, $GITHUB_COM.'gregsexton/gitv')
call add(s:plugins.opt, $GITHUB_COM.'mhinz/vim-signify')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-textobj-user')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-textobj-indent')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-textobj-syntax')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-textobj-line')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-textobj-fold')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-textobj-entire')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-textobj-between')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-textobj-comment')
call add(s:plugins.opt, $GITHUB_COM.'h1mesuke/textobj-wiw')
call add(s:plugins.opt, $GITHUB_COM.'vimtaku/vim-textobj-sigil')
call add(s:plugins.opt, $GITHUB_COM.'sgur/vim-textobj-parameter')
call add(s:plugins.opt, $GITHUB_COM.'terryma/vim-expand-region')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-operator-user')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-operator-replace')
call add(s:plugins.opt, $GITHUB_COM.'tyru/operator-camelize.vim')
call add(s:plugins.opt, $GITHUB_COM.'tyru/operator-reverse.vim')
call add(s:plugins.opt, $GITHUB_COM.'emonkak/vim-operator-sort')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-qfreplace')
call add(s:plugins.opt, $GITHUB_COM.'dannyob/quickfixstatus')
call add(s:plugins.opt, $GITHUB_COM.'jceb/vim-hier')
call add(s:plugins.opt, $GITHUB_COM.'fuenor/qfixhowm')
if !s:Android
    call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-fontzoom')
endif
if !s:Android
    call add(s:plugins.opt, $GITHUB_COM.'nathanaelkane/vim-indent-guides')
endif
call add(s:plugins.opt, $GITHUB_COM.'daisuzu/rainbowcyclone.vim')
call add(s:plugins.opt, $GITHUB_COM.'vim-scripts/matchparenpp')
call add(s:plugins.opt, $GITHUB_COM.'vim-scripts/matchit.zip')
call add(s:plugins.opt, $GITHUB_COM.'tpope/vim-surround')
call add(s:plugins.opt, $GITHUB_COM.'t9md/vim-textmanip')
call add(s:plugins.opt, $GITHUB_COM.'tomtom/tcomment_vim')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-niceblock')
call add(s:plugins.opt, $GITHUB_COM.'kana/vim-altr')
call add(s:plugins.opt, $GITHUB_COM.'vim-scripts/Unicode-RST-Tables')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-visualstar')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-quickrun')
call add(s:plugins.opt, $GITHUB_COM.'osyo-manga/vim-watchdogs')
call add(s:plugins.opt, $GITHUB_COM.'osyo-manga/shabadou.vim')
call add(s:plugins.opt, $GITHUB_COM.'daisuzu/quickrun-hook-sphinx')
call add(s:plugins.opt, $GITHUB_COM.'rhysd/vim-grammarous')
call add(s:plugins.opt, $GITHUB_COM.'Shougo/vimproc.vim')
if !s:Android
    call add(s:plugins.opt, $GITHUB_COM.'Shougo/vinarise')
endif
if !s:Android
    call add(s:plugins.opt, $GITHUB_COM.'s-yukikaze/vinarise-plugin-peanalysis')
endif
call add(s:plugins.opt, $GITHUB_COM.'daisuzu/tree.vim')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-prettyprint')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-editvar')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-showtime')
call add(s:plugins.opt, $GITHUB_COM.'tyru/open-browser.vim')
call add(s:plugins.opt, $GITHUB_COM.'yuratomo/w3m.vim')
if !s:Android
    call add(s:plugins.opt, $GITHUB_COM.'sjl/gundo.vim')
endif
call add(s:plugins.opt, $GITHUB_COM.'vim-scripts/sudo.vim')
call add(s:plugins.opt, $GITHUB_COM.'vim-scripts/Align')
call add(s:plugins.opt, $GITHUB_COM.'h1mesuke/vim-alignta')
call add(s:plugins.opt, $GITHUB_COM.'thinca/vim-scall')
call add(s:plugins.opt, $GITHUB_COM.'mattn/sonictemplate-vim')
call add(s:plugins.opt, $GITHUB_COM.'LeafCage/vimhelpgenerator')
call add(s:plugins.opt, $GITHUB_COM.'t9md/vim-choosewin')
call add(s:plugins.opt, $GITHUB_COM.'tyru/vim-altercmd')
call add(s:plugins.opt, $GITHUB_COM.'alfredodeza/pytest.vim')
call add(s:plugins.opt, $GITHUB_COM.'klen/python-mode')
call add(s:plugins.opt, $GITHUB_COM.'davidhalter/jedi-vim')
call add(s:plugins.opt, $GITHUB_COM.'vim-perl/vim-perl')
call add(s:plugins.opt, $GITHUB_COM.'c9s/perlomni.vim')
call add(s:plugins.opt, $GITHUB_COM.'pangloss/vim-javascript')
call add(s:plugins.opt, $GITHUB_COM.'marijnh/tern_for_vim')
call add(s:plugins.opt, $GITHUB_COM.'vim-scripts/SQLUtilities')
call add(s:plugins.opt, $GITHUB_COM.'mattn/emmet-vim')
call add(s:plugins.opt, $GITHUB_COM.'hail2u/vim-css3-syntax')
call add(s:plugins.opt, $GITHUB_COM.'fatih/vim-go')

function! s:has_plugin(name)
    return globpath(&runtimepath, 'plugin/' . a:name . '.vim') !=# ''
                \ || globpath(&runtimepath, 'autoload/' . a:name . '.vim') !=# ''
endfunction

function! s:mkdir_if_not_exists(path)
    if !isdirectory(a:path)
        call mkdir(a:path, 'p')
    endif
endfunction

function! s:create_helptags(path)
    if isdirectory(a:path)
        execute 'helptags ' . a:path
    endif
endfunction

function! InstallPackPlugins()
    for key in keys(s:plugins)
        let dir = expand($PACKPATH . '/' . key)
        call s:mkdir_if_not_exists(dir)

        for url in s:plugins[key]
            let dst = expand(dir . '/' . split(url, '/')[-1])
            if isdirectory(dst)
                " plugin is already installed
                continue
            endif

            echo 'installing: ' . dst
            let cmd = printf('git clone --recursive %s %s', url, dst)
            call system(cmd)
            call s:create_helptags(expand(dst . '/doc/'))
        endfor
    endfor
endfunction

function! UpdateHelpTags()
    for key in keys(s:plugins)
        let dir = expand($PACKPATH . '/' . key)

        for url in s:plugins[key]
            let dst = expand(dir . '/' . split(url, '/')[-1])
            if !isdirectory(dst)
                " plugin is not installed
                continue
            endif

            echo 'helptags: ' . dst
            call s:create_helptags(expand(dst . '/doc/'))
        endfor
    endfor
endfunction

function! UpdatePackPlugins()
    topleft split
    edit `='[update plugins]'`
    setlocal buftype=nofile

    let s:pidx = 0
    call timer_start(100, 'PluginUpdateHandler', {'repeat': len(s:plugins.opt)})
endfunction

function! PluginUpdateHandler(timer)
    let dir = expand($PACKPATH . '/' . 'opt')
    let url = s:plugins.opt[s:pidx]
    let dst = expand(dir . '/' . split(url, '/')[-1])

    let cmd = printf('git -C %s pull --ff --ff-only', dst)
    call job_start(cmd, {'out_io': 'buffer', 'out_name': '[update plugins]'})

    let s:pidx += 1
endfunction

let s:pidx = 0
function! PackAddHandler(timer)
    let plugin_name = split(s:plugins.opt[s:pidx], '/')[-1]

    let plugin_path = expand($PACKPATH . '/opt/' . plugin_name)
    if isdirectory(plugin_path)
        execute 'packadd ' . plugin_name
    endif

    let s:pidx += 1
    if s:pidx == len(s:plugins.opt)
        " for filetype plugin
        " filetype plugin indent on
        " fugitive.vim requires do autocmd
        doautocmd BufReadPost
        IndentGuidesEnable
    endif
endfunction

if has('vim_starting') && has('timers')
    packadd vim-textobj-user
    packadd vim-operator-user
    autocmd MyVimrcCmd VimEnter * call timer_start(1, 'PackAddHandler', {'repeat': len(s:plugins.opt)})
endif

filetype plugin indent on
"}}}

"---------------------------------------------------------------------------
" Mouse:"{{{
"
set mouse=a
set nomousefocus
set nomousehide
"set guioptions+=a
"}}}

"---------------------------------------------------------------------------
" Edit:"{{{
"
set nobackup
set browsedir=buffer
set clipboard=unnamed,unnamedplus
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab
set backspace=indent,eol,start
set whichwrap=b,s,<,>,[,]
set wildmenu
set virtualedit+=block
set autoindent
" Smart indenting
set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
" for smartindent
inoremap # X<C-H><C-V>#
set completeopt=menuone,longest,preview
" settings for Japanese folding
set formatoptions+=mM
" don't continue the comment line automatically
set formatoptions-=ro
autocmd MyVimrcCmd FileType * setlocal formatoptions-=ro
" settings for Japanese formatting
let format_allow_over_tw = 1
set nrformats=alpha,hex
" tags "{{{
set tags=./tags
set tags+=tags;
set tags+=./**/tags
"}}}
" grep "{{{
if executable('jvgrep')
    set grepprg=jvgrep\ -n\ --no-color
else
    set grepprg=grep\ -nH
endif
command! -nargs=+ Sgrep silent grep! <args>
nnoremap <Space>sg :<C-u>Sgrep <cword> %<CR>
autocmd MyVimrcCmd QuickfixCmdPre make,grep,grepadd,vimgrep,vimgrepadd,helpgrep copen
"}}}
autocmd MyVimrcCmd InsertLeave * if &paste | set nopaste | endif
nnoremap <Space>op :<C-u>set paste! paste?<CR>
"}}}

"---------------------------------------------------------------------------
" View:"{{{
"
" Fonts:"{{{
if has('xfontset')
    set guifontset=a14,r14,k14
elseif has('unix')

elseif has('mac')
    set guifont=Osaka-mono:h14
elseif s:MSWindows
"    set guifont=MS_Gothic:h12:cSHIFTJIS
"    set guifontwide=MS_Gothic:h12:cSHIFTJIS
    set guifont=MS_Gothic:h10:cSHIFTJIS
    set linespace=1
endif

" For Printer :
if has('printer')
    if s:MSWindows
        set printfont=MS_Mincho:h12:cSHIFTJIS
"       set printfont=MS_Gothic:h12:cSHIFTJIS
    endif
endif
"}}}

" Color Scheme:"{{{
colorscheme torte
"}}}

set nonumber
nnoremap <Space>on :<C-u>setlocal number! number?<CR>

set showmatch
set laststatus=2
set cmdheight=2
set showcmd
set title
set showtabline=2
set display=uhex
set previewheight=12
set winwidth=20

set t_Co=256

set nowrap
nnoremap <Space>ow :<C-u>setlocal wrap! wrap?<CR>

set nolist
nnoremap <Space>ol :<C-u>setlocal list! list?<CR>
set listchars=tab:>-,extends:<,precedes:>,trail:-,eol:$,nbsp:%

" Limit horizontal scrollbar size to the length of the cursor line
set guioptions+=h
" Hide Toolbar
set guioptions-=T
" Toggle horizontal scrollbar
nnoremap <silent> <Space>oh :
            \ if &guioptions =~# 'b' <Bar>
            \     set guioptions-=b <Bar>
            \ else <Bar>
            \     set guioptions+=b <Bar>
            \ endif <CR>

if has('gui_running')
    " Window width
    set columns=160
    " Window height
    set lines=40
endif
" Command-line height
set cmdheight=2

" Tabline settings "{{{
function! s:is_modified(n) "{{{
    return getbufvar(a:n, '&modified') == 1 ? '+' : ''
endfunction "}}}
function! s:tabpage_label(n) "{{{
    let title = gettabwinvar(a:n, 0, 'title')
    if title !=# ''
        return title
    endif

    let bufnrs = tabpagebuflist(a:n)
    let buflist = join(map(copy(bufnrs), 'v:val . s:is_modified(v:val)'), ',')

    let curbufnr = bufnrs[tabpagewinnr(a:n) - 1]
    let fname = pathshorten(bufname(curbufnr))

    let label = '[' . buflist . ']' . fname

    let hi = a:n is tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'

    return '%' . a:n . 'T' . hi . label . '%T%#TabLineFill#'
endfunction "}}}
function! MakeTabLine() "{{{
    let titles =map(range(1, tabpagenr('$')), 's:tabpage_label(v:val)')
    let sep = ' | '
    let tabpages = join(titles, sep) . sep . '%#TabLineFill#%T'
    let info = fnamemodify(getcwd(), '~:') . ' '
    return tabpages . '%=' . info
endfunction "}}}
set guioptions-=e
set tabline=%!MakeTabLine()
"}}}

" Visualization of the full-width space and the blank at the end of the line "{{{
if has('syntax')
    syntax on

    " for POD bug
    " syn sync fromstart

    function! ActivateInvisibleIndicator()
        syntax match InvisibleJISX0208Space "\%u3000" display containedin=ALL
        highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
        syntax match InvisibleTrailedSpace "\s\+$" display containedin=ALL
        if has('gui_macvim')
            highlight InvisibleTrailedSpace term=underline ctermbg=darkgray guibg=lightgray
        else
            highlight InvisibleTrailedSpace term=underline ctermbg=darkgray gui=undercurl guisp=darkorange
        endif
        syntax match InvisibleTab "\t" display containedin=ALL
        highlight InvisibleTab term=underline ctermbg=white gui=undercurl guisp=darkslategray
    endfunction
    call ActivateInvisibleIndicator()
    augroup invisible
        autocmd! invisible
        autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
    augroup END
endif
"}}}

" XPstatusline + fugitive#statusline "{{{
let g:statusline_max_path = 50
function! StatusLineGetPath() "{{{
    let p = expand('%:.:h')
    let p = substitute(p, expand('$HOME'), '~', '')
    if len(p) > g:statusline_max_path
        let p = simplify(p)
        let p = pathshorten(p)
    endif
    return p
endfunction "}}}

nnoremap <Plug>view:switch_status_path_length :let g:statusline_max_path = 200 - g:statusline_max_path<cr>
nnoremap ,t <Plug>view:switch_status_path_length

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

    " buffer number
    setlocal statusline+=%#StatuslineBufNr#%-1.2n
    " flags
    setlocal statusline+=\ %h%#StatuslineFlag#%m%r%w
    " path
    setlocal statusline+=%#StatuslinePath#\ %-0.50{StatusLineGetPath()}%0*
    " file name
    setlocal statusline+=%#StatuslineFileName#\/%t
    " file size
    setlocal statusline+=%#StatuslineFileSize#\ \(%{GetFileSize()}\)

    try
        call fugitive#statusline()
        " Git branch name
        setlocal statusline+=\ %{fugitive#statusline()}
    catch /E117/

    endtry

    " current char
    setlocal statusline+=%#StatuslineChar#\ \ %{GetCharacterCode()}
    " encoding
    setlocal statusline+=%#StatuslineTermEnc#(%{&termencoding},
    " file encoding
    setlocal statusline+=%#StatuslineFileEnc#%{&fileencoding},
    " file format
    setlocal statusline+=%#StatuslineFileFormat#%{&fileformat}\)

    " filetype
    setlocal statusline+=%#StatuslineFileType#\ %{strlen(&ft)?&ft:'**'}\ .
    " syntax name
    setlocal statusline+=%#StatuslineSyn#\ %{synIDattr(synID(line('.'),col('.'),1),'name')}\ %0*
    " real syntax name
    setlocal statusline+=%#StatuslineRealSyn#\ %{StatusLineRealSyn()}\ %0*

    setlocal statusline+=%=

    " position
    setlocal statusline+=\ %-10.(%l/%L,%c-%v%)
    " position percentage
    setlocal statusline+=\ %P
endfunction "}}}

function! s:SetSimpleStatusline() "{{{
    setlocal statusline=

    " path
    setlocal statusline+=%#StatuslineNC#%-0.20{StatusLineGetPath()}%0*
    " file name
    setlocal statusline+=\/%t
endfunction "}}}

" Get character code on cursor with 'fileencoding'.
function! GetCharacterCode()
    let str = iconv(matchstr(getline('.'), '.', col('.') - 1), &enc, &fenc)
    let out = '0x'
    for i in range(strlen(str))
        let out .= printf('%02X', char2nr(str[i]))
    endfor
    if str ==# ''
        let out .= '00'
    endif
    return out
endfunction

" Return the current file size in human readable format.
function! GetFileSize()
    let size = &encoding ==# &fileencoding || &fileencoding ==# ''
                \        ? line2byte(line('$') + 1) - 1 : getfsize(expand('%'))

    if size < 0
        let size = 0
    endif

    let format = has('float') ? '%0.2f' : '%d'
    let div_unit = has('float') ? 1024.0 : 1024
    for unit in ['B', 'KB', 'MB']
        if size < 1024
            " return size . unit
            return printf(format . unit, size)
        endif
        let size = size / div_unit
    endfor
    return printf(format . 'GB', size)
endfunction
"}}}

augroup MyVimrcCmd
    autocmd ColorScheme * call s:onColorScheme()
augroup END
function! s:onColorScheme()
    " IME Color "{{{
    if has('multi_byte_ime') || has('xim')
        " Set the color of the cursor when the IME ON
        highlight CursorIM guibg=Purple guifg=NONE
        " Default IME settings in search mode and insert mode
        set iminsert=0 imsearch=0
        if has('xim') && has('GUI_GTK')
            "set imactivatekey=C-Space
        endif
    endif

    if has('multi_byte_ime')
        "    highlight Cursor guifg=NONE guibg=Green
        highlight CursorIM guifg=NONE guibg=Purple
    endif
    "}}}
    " Additional settings of Color "{{{
    " highlight Cursor      guifg=Black   guibg=Green   gui=bold
    highlight Search      ctermfg=Black ctermbg=Red   cterm=bold  guifg=Black  guibg=Red  gui=bold
    " highlight StatusLine  ctermfg=White ctermbg=Blue guifg=blue guibg=white
    highlight Visual      cterm=reverse guifg=#404040 gui=bold
    highlight Folded      guifg=blue    guibg=darkgray
    " highlight Folded      guifg=blue    guibg=cadetblue
    highlight Identifier  cterm=none ctermfg=14

    highlight TabLine     ctermfg=Black ctermbg=White guifg=Black   guibg=#dcdcdc gui=underline
    highlight TabLineFill term=none     cterm=none    ctermfg=Black ctermbg=White guifg=Black   guibg=#dcdcdc gui=underline
    highlight TabLineSel  term=bold     cterm=bold    ctermfg=White ctermbg=Blue  guifg=White guibg=Blue gui=bold

    highlight DiffChange              ctermbg=55
    highlight DiffAdd                 ctermbg=18
    highlight DiffText    cterm=bold  ctermbg=88
    "}}}
    " For completion menu "{{{
    highlight Pmenu       ctermfg=White ctermbg=DarkBlue  guifg=#0033ff guibg=#99cccc gui=none
    highlight PmenuSel    ctermfg=Black ctermbg=Cyan      guifg=#ccffff guibg=#006699 gui=none
    highlight PmenuSbar   ctermfg=White ctermbg=LightCyan guifg=#ffffff guibg=#848484 gui=none
    highlight PmenuThumb  ctermfg=White ctermbg=DarkGreen guifg=#ffffff guibg=#006699 gui=none
    "}}}
    " For indent-guides "{{{
    let cterm_colors = (&background == 'dark') ? ['darkgray', 'gray'] : ['lightgray', 'white']
    let gui_colors   = (&background == 'dark') ? ['grey15', 'grey30']  : ['grey70', 'grey85']

    execute 'highlight IndentGuidesEven guibg=' . gui_colors[0] . ' guifg=' . gui_colors[1] . ' ctermbg=' . cterm_colors[0] . ' ctermfg=' . cterm_colors[1]
    execute 'highlight IndentGuidesOdd  guibg=' . gui_colors[1] . ' guifg=' . gui_colors[0] . ' ctermbg=' . cterm_colors[1] . ' ctermfg=' . cterm_colors[0]
    "}}}

    " For signfy "{{{
    highlight SignifySignAdd    cterm=bold ctermbg=237  ctermfg=119 guifg=Black guibg=Green
    highlight SignifySignDelete cterm=bold ctermbg=237  ctermfg=167 guifg=Black guibg=Red
    highlight SignifySignChange cterm=bold ctermbg=237  ctermfg=227 guifg=Black guibg=Yellow
    "}}}
endfunction
call s:onColorScheme()
"}}}

"---------------------------------------------------------------------------
" Search:"{{{
"
set nowrapscan
set incsearch

set ignorecase
nnoremap <Space>oi :<C-u>setlocal ignorecase! ignorecase?<CR>

set smartcase
nnoremap <Space>os :<C-u>setlocal smartcase! smartcase?<CR>

set hlsearch
nohlsearch
nnoremap <ESC><ESC> :nohlsearch<CR>
"}}}

"---------------------------------------------------------------------------
"  Utilities:"{{{
"
try
    call altercmd#load()
catch /E117/

endtry

" TabpageCD "{{{
command! -bar -complete=dir -nargs=?
            \ CD
            \ TabpageCD <args>
command! -bar -complete=dir -nargs=?
            \ TabpageCD
            \ execute 'cd' fnameescape(expand(<q-args>))
            \ | let t:cwd = getcwd()

autocmd MyVimrcCmd TabEnter *
            \   if exists('t:cwd') && !isdirectory(t:cwd)
            \ |     unlet t:cwd
            \ | endif
            \ | if !exists('t:cwd')
            \ |     let t:cwd = getcwd()
            \ | endif
            \ | execute 'cd' fnameescape(expand(t:cwd))

" Exchange ':cd' to ':TabpageCD'.
try
    AlterCommand cd CD
catch /E492/

endtry
"}}}

" CD to the directory of open files "{{{
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
endfunction "}}}
nnoremap <silent> <Space>cd :<C-u>TCD<CR>

" Files "{{{
cabbrev %% %:p:h

command! -bar ToScratch setlocal buftype=nofile bufhidden=hide noswapfile
command! -bar ToScratchForFiles ToScratch | setlocal iskeyword+=.

command! -bar -nargs=? ModsNew execute '<mods> new' | if '<args>' ==# 'Files:.' | edit `='[Files:' . fnamemodify(getcwd(), ':p:h') . ']'` | elseif len('<args>') | edit [<args>] | endif

if executable('files')
    let s:files_cmd = 'files -a'
    let s:files_opts = ''
elseif s:MSWindows
    let s:files_cmd = 'dir'
    let s:files_opts = '/b /s /a-d'
else
    let s:files_cmd = 'find '
    let s:files_opts = '-type f'
endif
command! -bar -nargs=1 -complete=dir Files <mods> ModsNew Files:<args> | ToScratchForFiles | execute 'r! ' . s:files_cmd . ' "<args>" ' . s:files_opts

command! FilesBuffer <mods> Files %:p:h
command! FilesCurrent <mods> Files .
command! MRU <mods> ModsNew MRU | ToScratchForFiles | call append(0, filter(v:oldfiles, 'filereadable(expand(v:val))')) | normal gg

function! SpExe(cmd) abort
    return split(execute(a:cmd), '\n')
endfunction
command! ScriptNames <mods> ModsNew ScriptNames | ToScratchForFiles | call append(0, SpExe('scriptnames')) | normal gg
command! Buffers <mods> ModsNew Buffers | ToScratchForFiles | call append(0, SpExe('buffers')) | normal gg
command! Ls <mods> ModsNew Buffers | ToScratchForFiles | call append(0, SpExe('ls')) | normal gg
"}}}
" Occur "{{{
command! Occur execute 'vimgrep /' . @/ . '/ %'
command! StarOccur execute 'vimgrep /' . expand('<cword>') . '/ %'
nnoremap <Leader>oc :<C-u>Occur<CR>
nnoremap <Leader>so :<C-u>StarOccur<CR>
"}}}
" SwapColon "{{{
nnoremap <Space>sc :<C-u>SwapColon<CR>
command! SwapColon call SwapColon()
function! SwapColon()
    if maparg(';', 'n') == ':'
        nunmap ;
        nunmap :
        vunmap ;
        vunmap :
        nunmap q;
    else
        nnoremap ; :
        nnoremap : ;
        vnoremap ; :
        vnoremap : ;
        nnoremap q; q:
    endif
endfunction
"}}}
" TermGuiColors "{{{
command! TermGuiColors call TermGuiColors()
function! TermGuiColors()
    execute "set t_8f=\e[38;2;%lu;%lu;%lum"
    execute "set t_8b=\e[48;2;%lu;%lu;%lum"
    set termguicolors
endfunction
"}}}
" Command-line window "{{{
autocmd MyVimrcCmd CmdwinEnter * call s:init_cmdwin()
function! s:init_cmdwin()
    nnoremap <buffer> q :<C-u>quit<CR>
    nnoremap <buffer> <TAB> :<C-u>quit<CR>

    inoremap <buffer><expr><C-h> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
    inoremap <buffer><expr><BS> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"

    inoremap <buffer><expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

    startinsert!
endfunction
"}}}
" DiffClip() "{{{
" http://vimwiki.net/?tips%2F49
command! -nargs=0 -range DiffClip <line1>, <line2>:call DiffClip('0')
" get diff with register reg
function! DiffClip(reg) range
    exe "let @a=@" . a:reg
    exe a:firstline  . "," . a:lastline . "y b"
    tabnew "new
    " clear the buffer after close this window
    set buftype=nofile bufhidden=wipe
    put a
    diffthis
    lefta vnew "vnew
    set buftype=nofile bufhidden=wipe
    put b
    diffthis
endfunction
"}}}
" DiffScratch() "{{{
command! DiffScratch call DiffScratch()
function! DiffScratch()
    tabnew
    set buftype=nofile bufhidden=wipe
    diffthis
    lefta vnew
    set buftype=nofile bufhidden=wipe
    diffthis
endfunction
"}}}
" NextIndent() "{{{
" http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
"
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
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
    let line = line('.')
    let column = col('.')
    let lastline = line('$')
    let indent = indent(line)
    let stepvalue = a:fwd ? 1 : -1

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
" Split and Go "{{{
" USAGE:
" [count]sag - Split the current window horizontally and, go to line [count].
" [count]sav - Split the current window vertically and, go to line [count].
nnoremap sag :<C-u>SplitAndGo split<CR>
nnoremap sav :<C-u>SplitAndGo vsplit<CR>

command! -count=1 -nargs=1 -complete=customlist,SAG_Complete SplitAndGo call SplitAndGo(<q-args>)

function! SplitAndGo(cmd)
    let cnt = v:count ? v:count : 1
    let cmd = cnt > line('.') ? 'botright '.a:cmd  : 'topleft '.a:cmd

    " execute cmd
    call s:split(cmd, 'preview')
    execute cnt
    normal! zv
endfunction

function! SAG_Complete(ArgLead, CmdLine, CursorPos)
    return ['split', 'vsplit']
endfunction

" For don't split the window if the window name is already exists.
" http://d.hatena.ne.jp/osyo-manga/20120826/1345944705
function! s:is_number(str)
    return (type(a:str) == type(0)) || (a:str =~ '^\d\+$')
endfunction

function! s:winnrlist(...)
    return a:0
                \ ? range(1, tabpagewinnr(a:1, "$"))
                \ : range(1, tabpagewinnr(tabpagenr(), "$"))
endfunction

function! s:winlist(...)
    let tabnr = a:0 == 0 ? tabpagenr() : a:1
    return map(s:winnrlist(tabnr), '{
                \     "winnr" : v:val,
                \     "name"  : gettabwinvar(tabnr, v:val, "name")
                \ }')
endfunction

function! s:winnr(...)
    return a:0 == 0 ? winnr()
                \ : a:1 ==# "$" ? winnr("$")
                \ : a:1 ==# "#" ? winnr("#")
                \ : !s:is_number(a:1) ? (filter(s:winlist(), 'v:val.name ==# a:1') + [{'winnr' : '-1'}])[0].winnr
                \ : a:1
endfunction

function! s:winname(...)
    return a:0 == 0 ? s:winname(winnr())
                \ : a:1 ==# "$" ? s:winname(winnr("$"))
                \ : a:1 ==# "#" ? s:winname(winnr("#"))
                \ : !s:is_number(a:1) ? (filter(s:winlist(), 'v:val.name ==# a:1') + [{'name' : ''}])[0].name
                \ : (filter(s:winlist(), 'v:val.winnr ==# a:1') + [{'name' : ''}])[0].name
endfunction

function! s:split(cmd, name)
    let winnr = s:winnr(a:name)
    if winnr == -1
        silent execute a:cmd
        let w:name = a:name
    else
        silent execute winnr . 'wincmd w'
    endif
endfunction

" split the window with specifying the window name.
" if the window name is already exists, move to there.
command! -count=0 -nargs=1
            \   Split call s:split("split", <q-args>) | if <count> | silent execute <count> | endif

" open the preview window by specifying the line number.
" 123ss
" nnoremap <silent> ss :<C-u>execute v:count."Split preview"<CR>
"}}}
" CtagsR "{{{
if executable('ctags')
    " Execute ctags command. And echo for error.
    command! -nargs=? -complete=file -bar CtagsR call CtagsR([<f-args>])

    function! CtagsR(args)
        let args = a:args
        let dir = '.'
        if !empty(args) && isdirectory(args[0])
            let dir = args[0]
            call remove(args, 0)
        endif

        if !empty(args) && args[0] !~# '^-'
            echoerr 'Invalid options: ' . join(args)
            return
        endif

        let tagfile = s:tagfile()
        if tagfile !=# ''
            let dir = fnamemodify(tagfile, ':h')
            let args += ['-f', tagfile]
        endif

        if s:MSWindows
            let enc = get({
                        \     'utf-8': 'utf8',
                        \     'cp932': 'sjis',
                        \     'euc-jp': 'euc',
                        \ }, &l:fileencoding ==# '' ? &encoding : &l:fileencoding, '')
            if enc !=# ''
                let args += ['--jcode=' . enc]
            endif
        endif
        let lang = get({
                    \     'cpp': 'C++',
                    \     'c': 'C++',
                    \     'java': 'Java',
                    \ }, &l:filetype, '')
        if lang !=# ''
            let args += ['--languages=' . lang]
        endif
        let opt = get({
                    \     'cpp': '--sort=yes --c++-kinds=+p --fields=+iaS --extra=+q',
                    \ }, &l:filetype, '')
        if opt !=# ''
            let args += [opt]
        endif

        call map(add(args, dir), 'shellescape(v:val)')

        let cmd = printf('ctags -R --tag-relative=yes %s', join(args))
        if s:MSWindows
            let cmd = 'start /b ' . cmd
        else
            let cmd .= ' &'
        endif
        silent execute '!' . cmd
    endfunction

    function! s:tagfile()
        let files = tagfiles()
        return empty(files) ? '' : files[0]
    endfunction
endif
"}}}
" Overrides fileencoding "{{{
command! -bang -bar -complete=file -nargs=? EncodeIso2022jp edit<bang> ++enc=iso-2022-jp <args>
command! -bang -bar -complete=file -nargs=? EncodeCp932 edit<bang> ++enc=cp932 <args>
command! -bang -bar -complete=file -nargs=? EncodeEuc edit<bang> ++enc=euc-jp <args>
command! -bang -bar -complete=file -nargs=? EncodeUtf8 edit<bang> ++enc=utf-8 <args>
command! -bang -bar -complete=file -nargs=? EncodeUtf16 edit<bang> ++enc=ucs-2le <args>
command! -bang -bar -complete=file -nargs=? EncodeUtf16be edit<bang> ++enc=ucs-2 <args>

command! -bang -bar -complete=file -nargs=? EncodeJis  EncodeIso2022jp<bang> <args>
command! -bang -bar -complete=file -nargs=? EncodeSjis  EncodeCp932<bang> <args>
command! -bang -bar -complete=file -nargs=? EncodeUnicode EncodeUtf16<bang> <args>
"}}}
" ginger "{{{
let s:endpoint = 'http://services.gingersoftware.com/Ginger/correct/json/GingerTheText'
let s:apikey = '6ae0c3a0-afdc-4532-a810-82ded0054236'
function! s:ginger(text)
    let res = webapi#json#decode(webapi#http#get(s:endpoint, {
                \ 'lang': 'US',
                \ 'clientVersion': '2.0',
                \ 'apiKey': s:apikey,
                \ 'text': a:text}).content)
    let i = 0
    for rs in res['LightGingerTheTextResult']
        let [from, to] = [rs['From'], rs['To']]
        if i < from
            echon a:text[i : from-1]
        endif
        echohl ErrorMsg
        echon a:text[from : to]
        echohl None
        let i = to + 1
    endfor
    if i < len(a:text)
        echon a:text[i :]
    endif
endfunction

command! -nargs=+ Ginger call s:ginger(<q-args>)
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
autocmd MyVimrcCmd FileType vim,help setlocal keywordprg=:help

let g:ref_cache_dir = $DOTVIM.'/.vim_ref_cache'

" Python
let g:ref_pydoc_cmd = 'python -m pydoc'

" webdict
let g:ref_source_webdict_sites = {
            \     'wikipedia:ja': {
            \         'url': 'http://ja.wikipedia.org/wiki/%s',
            \         'keyword_encoding': 'utf-8',
            \         'cache': '0',
            \     },
            \     'wikipedia:en': {
            \         'url': 'http://en.wikipedia.org/wiki/%s',
            \         'keyword_encoding': 'utf-8',
            \         'cache': '0',
            \     },
            \     'wiktionary': {
            \         'url': 'http://ja.wiktionary.org/wiki/%s',
            \         'keyword_encoding': 'utf-8',
            \         'cache': '0',
            \     },
            \     'alc': {
            \         'url': 'http://eow.alc.co.jp/%s',
            \         'keyword_encoding': 'utf-8',
            \         'cache': '0',
            \     },
            \ }

function! g:ref_source_webdict_sites.wiktionary.filter(output)
    return join(split(a:output, "\n")[18:], "\n")
endfunction

function! g:ref_source_webdict_sites.alc.filter(output)
    return join(split(a:output, "\n")[38:], "\n")
endfunction

let g:ref_source_webdict_sites.default = 'alc'
"}}}
"---------------------------------------------------------------------------
" vim-fugitive:"{{{
"
nnoremap <Space>gd :<C-u>Gdiff<CR>
nnoremap <Space>gs :<C-u>Gstatus<CR>
nnoremap <Space>ga :<C-u>Gwrite<CR>
nnoremap <Space>gc :<C-u>Gcommit<CR>
nnoremap <Space>gC :<C-u>Git commit --amend<CR>
nnoremap <Space>gb :<C-u>Gblame<CR>
nnoremap <Space>gv :<C-u>Gitv<CR>
nnoremap <Space>gV :<C-u>Gitv!<CR>

if s:MSWindows
    autocmd MyVimrcCmd FileType gitcommit setlocal encoding=utf-8
    autocmd MyVimrcCmd FileType gitcommit setlocal fileencoding=utf-8
    autocmd MyVimrcCmd FileType gitcommit setlocal fileencodings=utf-8
endif
"}}}
"---------------------------------------------------------------------------
" vim-signify:"{{{
"
nmap <leader>gj <plug>(signify-next-hunk)
nmap <leader>gk <plug>(signify-prev-hunk)
"}}}
"---------------------------------------------------------------------------
" textobj-user:"{{{
"
" textobj-ruledline "{{{
" ruled line for rst's table
if s:has_plugin('textobj/user')
    call textobj#user#plugin('ruledline', {
                \     '-': {
                \         '*pattern*': '-\+',
                \         'select': ['aR', 'iR'],
                \     },
                \ })
endif
"}}}
"}}}
"---------------------------------------------------------------------------
" textobj-comment:"{{{
"
let g:textobj_comment_no_default_key_mappings = 1
omap ao <Plug>(textobj-comment-a)
xmap ao <Plug>(textobj-comment-a)
omap io <Plug>(textobj-comment-i)
xmap io <Plug>(textobj-comment-i)
"}}}
"---------------------------------------------------------------------------
" textobj-wiw:"{{{
"
omap am <Plug>(textobj-wiw-a)
xmap am <Plug>(textobj-wiw-a)
omap im <Plug>(textobj-wiw-i)
xmap im <Plug>(textobj-wiw-i)
"}}}
"---------------------------------------------------------------------------
" textobj-parameter:"{{{
"
let g:vim_textobj_parameter_mapping = 'a'
"}}}
"---------------------------------------------------------------------------
" expand-region:"{{{
"
vmap + <Plug>(expand_region_expand)
vmap - <Plug>(expand_region_shrink)
"}}}
"---------------------------------------------------------------------------
" operator-user:"{{{
"
if s:has_plugin('operator/user')
" operator-fillblank "{{{
" replace selection with space
" fixed by id:tyru
" http://d.hatena.ne.jp/tyru/20121217/operator_fillblank
function! OperatorFillBlank(motion_wise)
    let v = operator#user#visual_command_from_wise_name(a:motion_wise)
    execute 'normal! `['.v.'`]"xy'
    let text = getreg('x', 1)
    let text = s:map_lines(text,
                \ 'substitute(v:val, ".", "\\=s:charwidthwise_r(submatch(0))", "g")')
    call setreg('x', text, v)
    normal! gv"xp
endfunction
function! s:charwidthwise_r(char)
    return repeat(' ', exists('*strwidth') ? strwidth(a:char) : 1)
endfunction
function! s:map_lines(str, expr)
    return join(map(split(a:str, '\n', 1), a:expr), "\n")
endfunction
call operator#user#define('fillblank', 'OperatorFillBlank')
map <Leader>b <Plug>(operator-fillblank)
"}}}
" operator-retab "{{{
call operator#user#define_ex_command('retab', 'retab')
map <Leader>t <Plug>(operator-retab)
"}}}
" operator-join "{{{
call operator#user#define_ex_command('join', 'join')
map <Leader>j <Plug>(operator-join)
"}}}
" operator-uniq "{{{
call operator#user#define_ex_command('uniq', 'sort u')
map <Leader>u <Plug>(operator-uniq)
"}}}
" operator-blank-killer "{{{
call operator#user#define_ex_command('blank-killer', 's/\s\+$//')
map <Leader>k <Plug>(operator-blank-killer)
"}}}
endif
"}}}
"---------------------------------------------------------------------------
" operator-replace:"{{{
"
map  _ <Plug>(operator-replace)
vmap p <Plug>(operator-replace)
"}}}
"---------------------------------------------------------------------------
" operator-camelize:"{{{
"
map <Leader>c <Plug>(operator-camelize)
map <Leader>C <Plug>(operator-decamelize)
"}}}
"---------------------------------------------------------------------------
" operator-reverse:"{{{
"
map <Leader>rl <Plug>(operator-reverse-lines)
map <Leader>rt <Plug>(operator-reverse-text)
"}}}
"---------------------------------------------------------------------------
" operator-sort:"{{{
"
map <Leader>s <Plug>(operator-sort)
"}}}
"---------------------------------------------------------------------------
" vim-hier:"{{{
"
" To highlight with a undercurl in quickfix error
execute 'highlight qf_error_ucurl gui=undercurl guisp=Red'
let g:hier_highlight_group_qf = 'qf_error_ucurl'

function! ResetHierAutocmd()
    try
        autocmd! Hier
    catch /E216/

    endtry
endfunction

augroup MyHier
    autocmd!
    autocmd QuickFixCmdPre * call ResetHierAutocmd()
augroup END
"}}}
"---------------------------------------------------------------------------
" qfixhowm.vim:"{{{
"
let QFixHowm_Key = 'g'
let QFixHowm_KeyB = ','

let howm_dir = $DOTVIM.'/howm'
let howm_filename = '%Y/%m/%Y-%m-%d-%H%M%S.howm'
let howm_fileencoding = 'utf-8'
let howm_fileformat = 'dos'
"}}}
"---------------------------------------------------------------------------
" qfixmemo.vim:"{{{
"
let qfixmemo_dir = $DOTVIM.'/qfixmemo'
let qfixmemo_filename = '%Y/%m/%Y-%m-%d-%H%M%S.txt'
let qfixmemo_fileencoding = 'cp932'
let qfixmemo_fileformat = 'dos'
let qfixmemo_filetype = 'qfix_memo'
"}}}
"---------------------------------------------------------------------------
" qfixmru.vim:"{{{
"
let QFixMRU_Filename = $DOTVIM.'/.qfixmru'
let QFixMRU_IgnoreFile = ''
let QFixMRU_RegisterFile = ''
let QFixMRU_IgnoreTitle = ''
let g:QFixMRU_Entries = 20
let QFixMRU_EntryMax = 300
"}}}
"---------------------------------------------------------------------------
" qfixgrep.vim:"{{{
"
let QFix_PreviewEnable = 0
let QFix_HighSpeedPreview = 0
let QFix_DefaultPreview = 0
let QFix_PreviewExclude = '\.pdf$\|\.mp3$\|\.jpg$\|\.bmp$\|\.png$\|\.zip$\|\.rar$\|\.exe$\|\.dll$\|\.lnk$'

let QFix_CopenCmd = ''
let QFix_Height = 10
let QFix_Width = 0
let QFix_PreviewHeight = 12
let QFix_WindowHeightMin = 0
let QFix_PreviewOpenCmd = ''
let QFix_PreviewWidth = 0

let QFix_HeightFixMode = 0

let QFix_CloseOnJump = 0
let QFix_Edit = 'tab'

let QFix_PreviewFtypeHighlight = 1
let QFix_CursorLine = 1
let QFix_PreviewCursorLine = 1
"hi CursorLine guifg = NONE guibg = NONE gui = underline

let QFix_Copen_winfixheight = 1
let QFix_Copen_winfixwidth = 1
let QFix_Preview_winfixheight = 1
let QFix_Preview_winfixwidth = 1

let MyGrep_ExcludeReg = '[~#]$\|\.bak$\|\.o$\|\.obj$\|\.exe$\|[/\\]tags$\|[/\\]svn[/\\]\|[/\\]\.git[/\\]\|[/\\]\.hg[/\\]'
let mygrepprg = 'grep'
let MyGrep_ShellEncoding = 'cp932'
let MyGrep_Damemoji = 2
let MyGrep_DamemojiReplaceReg = '(..)'
let MyGrep_DamemojiReplace = '[]'
let MyGrep_yagrep_opt = 0

let MyGrepcmd_useropt = ''

"let MyGrep_Key = 'g'
"let MyGrep_KeyB = ','

let MyGrep_DefaultSearchWord = 1

let MyGrep_MenuBar = 3

let g:QFixWin_EnableMode = 1
"}}}
"---------------------------------------------------------------------------
" vim-fontzoom:"{{{
"
nmap + <Plug>(fontzoom-larger)
nmap - <Plug>(fontzoom-smaller)
"}}}
"---------------------------------------------------------------------------
" vim-indent-guides:"{{{
"
" let g:indent_guides_indent_levels = 30
let g:indent_guides_auto_colors = 0
" let g:indent_guides_color_change_percent = 10
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
" let g:indent_guides_space_guides = 0
let g:indent_guides_enable_on_vim_startup = 1

try
    IndentGuidesEnable
catch /E492/

endtry
"}}}
"---------------------------------------------------------------------------
" rainbowcyclone.vim:"{{{
"
    nmap c/ <Plug>(rc_search_forward)
    nmap c? <Plug>(rc_search_backward)
    nmap c* <Plug>(rc_search_forward_with_cursor)
    nmap c# <Plug>(rc_search_backward_with_cursor)
    nmap cn <Plug>(rc_search_forward_with_last_pattern)
    nmap cN <Plug>(rc_search_backward_with_last_pattern)
    " nmap <Esc><Esc> <Plug>(rc_reset):nohlsearch<CR>
    " nnoremap <Esc><Esc> :<C-u>RCReset<CR>:nohlsearch<CR>
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
let g:tcommentTextObjectInlineComment = ''
"}}}
"---------------------------------------------------------------------------
" vim-altr:"{{{
"
    nnoremap <silent> tf :<C-u>call altr#forward()<CR>
    nnoremap <silent> tb :<C-u>call altr#back()<CR>
"}}}
"---------------------------------------------------------------------------
" Unicode-RST-Table:"{{{
"
let g:no_rst_table_maps = 0

if has('python3')
    noremap <silent> ,,c :python3 CreateTable()<CR>
    noremap <silent> ,,f :python3 FixTable()<CR>
elseif has('python')
    noremap <silent> ,,c :python CreateTable()<CR>
    noremap <silent> ,,f :python FixTable()<CR>
endif
"}}}
"---------------------------------------------------------------------------
" vim-quickrun:"{{{
"
nmap <Leader>r <Plug>(quickrun)
omap <Leader>r <Plug>(quickrun)
xmap <Leader>r <Plug>(quickrun)

if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif

let g:quickrun_config['_'] = {
            \     'outputter/buffer/split' : ':botright 8sp',
            \     'runner' : 'job',
            \ }
let g:quickrun_config['watchdogs_checker/_'] = {
            \     'hook/close_buffer/enable_exit' : 1,
            \     'hook/close_buffer/enable_failure' : 1,
            \     'hook/close_buffer/enable_empty_data' : 1,
            \     'outputter' : 'multi:buffer:quickfix',
            \     'hook/inu/enable' : 1,
            \     'hook/inu/wait' : 20,
            \     'runner' : 'job',
            \ }

" settings for lightweight markup language "{{{
let g:quickrun_config['markdown'] = {
            \     'type': 'markdown/pandoc',
            \     'outputter': 'browser',
            \     'cmdopt': '-s'
            \ }
let g:quickrun_config['markdown/pandoc/docx'] = {
            \ 'input' : '%{expand("%")}',
            \ 'command': 'pandoc',
            \ 'cmdopt' : '%{tempname()}.docx',
            \ 'exec': ['%c -s --from=markdown --to=docx -o "%o" %a',
            \          (has('win32') || has('win64'))
            \          ? 'move /Y "%o" "%S:p:r.docx"'
            \          : 'mv %o %S:pr:r.docx'],
            \ 'outputter' : 'error',
            \ 'output_encode' : 'cp932',
            \ }

let g:quickrun_config['html/pandoc/markdown'] = {
            \ 'command': 'pandoc',
            \ 'input' : '%{expand("%")}',
            \ 'exec': '%c -s --from=html --to=markdown %o %a',
            \ }

let g:quickrun_config['textile'] = {
            \     'type': 'textile/redcloth'
            \ }
let g:quickrun_config['textile/redcloth'] = {
            \     'command'   : 'redcloth',
            \     'exec'      : '%c %s',
            \     'outputter' : 'browser',
            \ }
let g:quickrun_config['textile/pandoc'] = {
            \     'command': 'pandoc',
            \     'outputter': 'browser',
            \     'cmdopt': '-s',
            \     'exec': '%c --from=textile --to=html %o %s %a',
            \ }
let g:quickrun_config['textile/pandoc/docx'] = {
            \ 'input' : '%{expand("%")}',
            \ 'command': 'pandoc',
            \ 'cmdopt' : '%{tempname()}.docx',
            \ 'exec': ['%c -s --from=textile --to=docx -o "%o" %a',
            \          (has('win32') || has('win64'))
            \          ? 'move /Y "%o" "%S:p:r.docx"'
            \          : 'mv %o %S:pr:r.docx'],
            \ 'outputter' : 'error',
            \ 'output_encode' : 'cp932',
            \ }

let g:quickrun_config['rst'] = {
            \     'type': 'rst/sphinx'
            \ }
let g:quickrun_config['rst/sphinx'] = {
            \     'command': 'make',
            \     'outputter': 'quickfix',
            \     'hook/sphinx_open/enable' : 1,
            \     'hook/sphinx_html2pdf/enable' : 1,
            \     'hook/sphinx_html2pdf/options': [
            \         '-B 0',
            \         '-L 0',
            \         '-R 0',
            \         '-T 0',
            \     ],
            \     'cmdopt': 'html',
            \     'exec': '%c %o'
            \ }
let g:quickrun_config['rst/pandoc'] = {
            \ 'input' : '%{expand("%")}',
            \ 'command': 'pandoc',
            \ 'exec': '%c -s --from=rst --to=html %o %a',
            \ 'outputter' : 'browser',
            \ 'output_encode' : 'utf-8',
            \ }
let g:quickrun_config['rst/pandoc/docx'] = {
            \ 'input' : '%{expand("%")}',
            \ 'command': 'pandoc',
            \ 'cmdopt' : '%{tempname()}.docx',
            \ 'exec': ['%c -s --from=rst --to=docx -o "%o" %a',
            \          (has('win32') || has('win64'))
            \          ? 'move /Y "%o" "%S:p:r.docx"'
            \          : 'mv %o %S:pr:r.docx'],
            \ 'outputter' : 'error',
            \ 'output_encode' : 'cp932',
            \ }

let g:quickrun_config['diag'] = {
            \     'type': 'diag/blockdiag'
            \ }
let g:quickrun_config['diag/blockdiag'] = {
            \     'command': 'blockdiag',
            \     'exec': '%c %s',
            \ }
"}}}

if s:has_plugin('vim-watchdogs')
    call watchdogs#setup(g:quickrun_config)
endif
"}}}
"---------------------------------------------------------------------------
" tree.vim:"{{{
"
function! TreeResize()
    augroup TreeCmd
        autocmd!
        autocmd BufEnter <buffer> vertical resize 32
        autocmd BufLeave <buffer> vertical resize 32
    augroup END
    doautocmd TreeCmd BufEnter
endfunction

nnoremap <silent> <Space>vf :<C-u>execute 'vertical '. v:count .'Tree' <Bar> call TreeResize()<CR>

function! GoToFileVertical()
    let file = fnameescape(expand('<cfile>'))

    let winlist = filter(range(1, winnr('$')), 'bufnr("%") != winbufnr(v:val) && getwinvar(v:val, "&previewwindow") != 1')
    if len(winlist) > 1
        let choose = choosewin#start(winlist)
        if len(choose) == 0
            return
        endif
        let winlist[0] = choose[1]
    endif

    execute winlist[0] . 'wincmd w'
    execute 'edit ' . file
endfunction

nnoremap <silent> <C-w>e :<C-u>call GoToFileVertical()<CR>
"}}}
"---------------------------------------------------------------------------
" vim-scall:"{{{
"
let g:scall_function_name = 'S'
"}}}
"---------------------------------------------------------------------------
" sonictemplate-vim:"{{{
"
let g:sonictemplate_vim_template_dir = expand($DOTVIM . '/.template')
"}}}
"---------------------------------------------------------------------------
" vimhelpgenerator:"{{{
"
let g:vimhelpgenerator_defaultlanguage = 'en'
"}}}
"---------------------------------------------------------------------------
" vim-choosewin:"{{{
"
nmap <Leader>- <Plug>(choosewin)
let g:choosewin_overlay_enable = 1
let g:choosewin_overlay_clear_multibyte = 1
"}}}
"---------------------------------------------------------------------------
" python-mode:"{{{
"
let g:pymode_lint_on_fly = 1
let g:pymode_lint_on_write = 1
let g:pymode_lint_cwindow = 0
let g:pymode_lint_message = 1
let g:pymode_lint_signs = 1
let g:pydoc = 'python -m pydoc'
let g:pymode_rope = 0
let g:pymode_folding = 0
let g:pymode_run = 0
let g:pymode_trim_whitespaces = 0
"}}}
"---------------------------------------------------------------------------
" jedi-vim:"{{{
"
autocmd MyVimrcCmd FileType python setlocal omnifunc=jedi#completions
" let g:jedi#popup_on_dot = 0
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#smart_auto_mappings = 0
let g:jedi#rename_command = '<Leader>jr'
"}}}
"---------------------------------------------------------------------------
" perlomni.vim:"{{{
"
if has('vim_starting')
    let $PATH = $PACKPATH. '/opt/perlomni.vim/bin:' . $PATH
endif
"}}}
"---------------------------------------------------------------------------
" tern_for_vim:"{{{
"
autocmd MyVimrcCmd FileType javascript setlocal omnifunc=tern#Complete
"}}}
"---------------------------------------------------------------------------
" SQLUtilities:"{{{
"
let g:sqlutil_align_comma = 1
"}}}
"---------------------------------------------------------------------------
" vim-go:"{{{
"
let g:go_textobj_enabled = 0

autocmd MyVimrcCmd FileType go nmap <leader>b <Plug>(go-build)
autocmd MyVimrcCmd FileType go nmap <leader>t <Plug>(go-test)
autocmd MyVimrcCmd FileType go call s:go_import_commands()

" same as vim-go-extra
function! s:go_import_commands()
    command! -buffer -nargs=? -complete=customlist,go#package#Complete Drop GoDrop <args>
    command! -buffer -nargs=1 -complete=customlist,go#package#Complete Import GoImport <args>
    command! -buffer -nargs=* -complete=customlist,go#package#Complete ImportAs GoImportAs <args>
endfunction
"}}}
"}}}

"---------------------------------------------------------------------------
" Key Mappings:"{{{
"
nnoremap Y y$
nnoremap X ^x

noremap <Space>h ^
noremap <Space>l $
map <Space>n %

" leave insertmode
" inoremap <expr> j getline('.')[col('.') - 2] ==# 'j' ? "\<BS>\<ESC>" : 'j'
inoremap jj <ESC>

"paste
inoremap <C-v> <C-r>+
" swap <C-v> to <C-a>
inoremap <C-a> <C-v>

" insert blank in normal mode
nnoremap <C-Space> i <Esc><Right>

" improve replacement of twice the width of characters in linewise
xnoremap <expr> r mode() ==# 'V' ? "\<C-v>0o$r" : "r"

" Tabpage related mappings
nnoremap <Space>tn :<C-u>tabnew<CR>
nnoremap <Space>tc :<C-u>tabclose<CR>
nnoremap <Space>tC :<C-u>tabclose!<CR>
nnoremap <Space>ts :<C-u>tabs<CR>

" Window related mappings
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-h> <C-w>h
nnoremap <M-l> <C-w>l
inoremap <M-j> <Esc><C-w>j
inoremap <M-k> <Esc><C-w>k
inoremap <M-h> <Esc><C-w>h
inoremap <M-l> <Esc><C-w>l

nnoremap <M-+> <C-w>+
nnoremap <M--> <C-w>-
nnoremap <M->> <C-w>>
nnoremap <M-<> <C-w><
inoremap <M-+> <Esc><C-w>+
inoremap <M--> <Esc><C-w>-
inoremap <M->> <Esc><C-w>>
inoremap <M-<> <Esc><C-w><

" Move to the position last edited
nnoremap gb '[
nnoremap gp ']

" Select last changed
nnoremap gc `[v`]
vnoremap gc :<C-u>normal gc<CR>
onoremap gc :<C-u>normal gc<CR>

" 'Quote'
onoremap aq a'
xnoremap aq a'
onoremap iq i'
xnoremap iq i'

" "Double quote"
onoremap ad a"
xnoremap ad a"
onoremap id i"
xnoremap id i"

" {Curly bracket}
onoremap ac a}
xnoremap ac a}
onoremap ic i}
xnoremap ic i}

" <aNgle bracket>
onoremap an a>
xnoremap an a>
onoremap in i>
xnoremap in i>

" [sqUare bracket]
onoremap au a]
xnoremap au a]
onoremap iu i]
xnoremap iu i]

" for cmdline-mode
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>

cnoremap <Left> <Space><BS><Left>
cnoremap <Right> <Space><BS><Right>

" paste
cnoremap <C-v> <C-r>+
"}}}

"---------------------------------------------------------------------------
" FileTypes:"{{{
"
autocmd MyVimrcCmd FileType rst setlocal suffixesadd=.rst
autocmd MyVimrcCmd BufNewFile,BufReadPost *.diag setlocal filetype=diag
autocmd MyVimrcCmd FileType help call MyFileTypeHelp()
function! MyFileTypeHelp() "{{{
    if &l:buftype !=# 'help'
        setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78
        if exists('+colorcolumn')
            setlocal colorcolumn=+1
        endif
        if has('conceal')
            setlocal conceallevel=0
        endif
    endif
endfunction "}}}
autocmd MyVimrcCmd FileType showtime IndentGuidesDisable
"}}}

"---------------------------------------------------------------------------
" External Settings:"{{{
"
if 1 && filereadable($MYLOCALVIMRC)
    source $MYLOCALVIMRC
endif
"}}}

" vim: foldmethod=marker
