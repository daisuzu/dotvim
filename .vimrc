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
" Kaoriya:"{{{
"
if exists('g:no_vimrc_example') && g:no_vimrc_example == 1
    silent! source $VIMRUNTIME/vimrc_example.vim
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

"---------------------------------------------------------------------------
" MSWIN:"{{{
"
if exists("g:skip_loading_mswin") && g:skip_loading_mswin
    if (1 && filereadable($VIMRUNTIME . '/mswin.vim')) && !s:Android
        source $VIMRUNTIME/mswin.vim
    endif

    " some textobj plugins doesn't work on selection=exclusive
    set selection=inclusive

    " Redefinition <C-A>:increment and <C-X>:decrement
    noremap <C-i> <C-A>
    noremap <M-i> <C-X>
endif
"}}}
"}}}

"---------------------------------------------------------------------------
" Load Plugins:"{{{
"
" filetype off

"---------------------------------------------------------------------------
" neobundle.vim:"{{{
"
if has('vim_starting')
    set runtimepath+=$DOTVIM/Bundle/neobundle.vim/
endif

if !exists('$GIT_PROTOCOL')
    let $GIT_PROTOCOL = 'git'
endif
if s:Android
    let $GITHUB_COM = $GIT_PROTOCOL.'://207.97.227.239/'
else
    let $GITHUB_COM = $GIT_PROTOCOL.'://github.com/'
endif

let $BITBUCKET_ORG = 'https://bitbucket.org/'

command! -nargs=* MyNeoBundle
            \ call MyNeoBundle(substitute(<q-args>, '\s"[^"]\+$', '', ''))
function! MyNeoBundle(arg)
    let args = split(a:arg)
    if len(args) < 1
        return
    endif

    if eval(args[0])
        execute 'NeoBundle ' . join(args[1:])
    endif
endfunction

try
    call neobundle#rc($DOTVIM . '/Bundle/')

    " plugin management
    NeoBundleFetch $GITHUB_COM.'Shougo/neobundle.vim.git'

    " runtime for other plugins
    NeoBundle $GITHUB_COM.'mattn/webapi-vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/cecutil.git'
    NeoBundle $GITHUB_COM.'vim-scripts/tlib.git'

    " doc
    NeoBundle $GITHUB_COM.'vim-jp/vimdoc-ja.git'
    NeoBundle $GITHUB_COM.'thinca/vim-ref.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': [{'name': 'Ref',
                \                   'complete': 'customlist,ref#complete',}],
                \ }}
    NeoBundle $GITHUB_COM.'thinca/vim-ft-help_fold.git'

    " completion
    if has('lua')
        NeoBundle $GITHUB_COM.'Shougo/neocomplete.git', {
                    \ 'autoload': {
                    \     'insert': 1,
                    \ }}
    else
        NeoBundle $GITHUB_COM.'Shougo/neocomplcache.git', {'lazy': 1,
                    \ 'autoload': {
                    \     'insert': 1,
                    \ }}
    endif
    NeoBundle $GITHUB_COM.'Shougo/neosnippet.git', {'lazy': 1,
                \ 'autoload': {
                \     'insert': 1,
                \     'filetypes': 'snippet',
                \ }}
    NeoBundle $GITHUB_COM.'Shougo/neosnippet-snippets.git', {'lazy': 1,
                \ 'autoload': {
                \     'insert': 1,
                \     'filetypes': 'snippet',
                \ }}
    MyNeoBundle !s:Android $GITHUB_COM.'Rip-Rip/clang_complete.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', ],
                \ }}
    MyNeoBundle !s:Android $GITHUB_COM.'eagletmt/neco-ghc.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['haskell', ],
                \ }}
    NeoBundle $GITHUB_COM.'ujihisa/neco-look.git'

    " ctags
    NeoBundle $GITHUB_COM.'vim-scripts/taglist.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', 'python', 'perl', 'javascript', ],
                \ }}
    if executable('hg')
        NeoBundle $BITBUCKET_ORG.'abudden/taghighlight', {'lazy': 1,
                    \ 'autoload' : {
                    \     'filetypes': ['c', 'cpp', 'python', 'perl', 'javascript', ],
                    \ },
                    \ 'type': 'hg'}
    endif

    " vcs
    NeoBundle $GITHUB_COM.'tpope/vim-fugitive.git'
    NeoBundle $GITHUB_COM.'gregsexton/gitv.git'
    NeoBundle $GITHUB_COM.'kablamo/vim-git-log.git'
    NeoBundle $GITHUB_COM.'int3/vim-extradite.git'
    NeoBundle $GITHUB_COM.'rhysd/git-messenger.vim.git'
    " NeoBundle $GITHUB_COM.'airblade/vim-gitgutter.git'
    NeoBundle $GITHUB_COM.'mhinz/vim-signify.git'

    " unite
    NeoBundle $GITHUB_COM.'Shougo/unite.vim.git', {'lazy': 1,
                \ 'depends': [$GITHUB_COM.'Shougo/vimfiler.git',
                \             $GITHUB_COM.'Shougo/vimshell.git',
                \            ],
                \ 'autoload': {
                \     'commands': [{'name': 'Unite',
                \                   'complete': 'customlist,unite#complete_source'},
                \                   'UniteWithBufferDir',
                \                   'UniteWithCurrentDir',
                \                   'UniteWithCursorWord',
                \                   'UniteWithInput'],
                \ }}
    NeoBundle $GITHUB_COM.'Shougo/neomru.vim.git'
    MyNeoBundle !s:Android $GITHUB_COM.'Shougo/unite-build.git'
    NeoBundle $GITHUB_COM.'ujihisa/unite-colorscheme.git'
    NeoBundle $GITHUB_COM.'ujihisa/unite-font.git'
    NeoBundleLazy $GITHUB_COM.'ujihisa/quicklearn.git'
    NeoBundle $GITHUB_COM.'sgur/unite-qf.git'
    NeoBundle $GITHUB_COM.'osyo-manga/unite-quickfix.git'
    NeoBundle $GITHUB_COM.'h1mesuke/unite-outline.git'
    NeoBundle $GITHUB_COM.'h1mesuke/vim-alignta.git'
    NeoBundle $GITHUB_COM.'tsukkee/unite-help.git'
    MyNeoBundle !s:Android $GITHUB_COM.'tsukkee/unite-tag.git'
    NeoBundle $GITHUB_COM.'tacroe/unite-mark.git'
    MyNeoBundle !s:Android $GITHUB_COM.'sgur/unite-everything.git'
    NeoBundle $GITHUB_COM.'zhaocai/unite-scriptnames.git'
    NeoBundle $GITHUB_COM.'pasela/unite-webcolorname.git'
    NeoBundle $GITHUB_COM.'daisuzu/unite-grep_launcher.git'
    MyNeoBundle !s:Android $GITHUB_COM.'daisuzu/unite-gtags.git'
    NeoBundle $GITHUB_COM.'ujihisa/unite-haskellimport.git'
    NeoBundle $GITHUB_COM.'eagletmt/unite-haddock.git'
    NeoBundle $GITHUB_COM.'thinca/vim-unite-history.git'
    NeoBundle $GITHUB_COM.'Shougo/unite-ssh.git'

    " textobj
    NeoBundle $GITHUB_COM.'kana/vim-textobj-user.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-indent.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-syntax.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-line.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-fold.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-entire.git'
    NeoBundle $GITHUB_COM.'thinca/vim-textobj-between.git'
    NeoBundle $GITHUB_COM.'thinca/vim-textobj-comment.git'
    NeoBundle $GITHUB_COM.'h1mesuke/textobj-wiw.git'
    NeoBundle $GITHUB_COM.'vimtaku/vim-textobj-sigil.git'
    NeoBundle $GITHUB_COM.'sgur/vim-textobj-parameter.git'
    NeoBundle $GITHUB_COM.'terryma/vim-expand-region.git'

    " operator
    NeoBundle $GITHUB_COM.'kana/vim-operator-user.git'
    NeoBundle $GITHUB_COM.'kana/vim-operator-replace.git'
    NeoBundle $GITHUB_COM.'tyru/operator-camelize.vim.git'
    NeoBundle $GITHUB_COM.'tyru/operator-reverse.vim.git'
    NeoBundle $GITHUB_COM.'emonkak/vim-operator-sort.git'

    " quickfix
    NeoBundle $GITHUB_COM.'thinca/vim-qfreplace.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['quickfix', 'qf', 'unite', ],
                \ }}
    NeoBundleLazy  $GITHUB_COM.'dannyob/quickfixstatus.git'
    NeoBundleLazy $GITHUB_COM.'jceb/vim-hier.git'
    NeoBundle $GITHUB_COM.'fuenor/qfixhowm.git'

    " appearance
    MyNeoBundle !s:Android $GITHUB_COM.'thinca/vim-fontzoom.git', {'lazy': 1,
                \ 'gui': 1,
                \ 'autoload': {
                \     'mappings': [
                \                 ['n', '<Plug>(fontzoom-larger)'],
                \                 ['n', '<Plug>(fontzoom-smaller)']],
                \ }}
    MyNeoBundle !s:Android $GITHUB_COM.'nathanaelkane/vim-indent-guides.git'
    NeoBundle $GITHUB_COM.'daisuzu/rainbowcyclone.vim.git'

    " cursor movement
    NeoBundle $GITHUB_COM.'Lokaltog/vim-easymotion.git'
    NeoBundle $GITHUB_COM.'vim-scripts/matchparenpp.git'
    NeoBundle $GITHUB_COM.'vim-scripts/matchit.zip.git'

    " editing
    NeoBundle $GITHUB_COM.'tpope/vim-surround.git'
    NeoBundle $GITHUB_COM.'t9md/vim-textmanip.git', {'lazy': 1,
                \ 'autoload': {
                \     'mappings': [
                \                 ['x', '<Plug>(textmanip-move-up)'],
                \                 ['x', '<Plug>(textmanip-move-down)'],
                \                 ['x', '<Plug>(textmanip-move-right)'],
                \                 ['x', '<Plug>(textmanip-move-left)'],
                \                 ['nx', '<Plug>(textmanip-duplicate-down)'],
                \                 ['nx', '<Plug>(textmanip-duplicate-up)']],
                \ }}
    NeoBundle $GITHUB_COM.'tomtom/tcomment_vim.git'
    NeoBundle $GITHUB_COM.'kana/vim-niceblock.git'
    NeoBundle $GITHUB_COM.'kana/vim-altr.git'
    NeoBundle $GITHUB_COM.'vim-scripts/DrawIt.git'
    NeoBundle $GITHUB_COM.'vim-scripts/Unicode-RST-Tables.git'
    NeoBundle $GITHUB_COM.'vim-scripts/sequence.git'

    " search
    NeoBundle $GITHUB_COM.'thinca/vim-visualstar.git'
    NeoBundle $GITHUB_COM.'othree/eregex.vim.git'

    " quickrun
    NeoBundle $GITHUB_COM.'thinca/vim-quickrun.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': [{'name': 'QuickRun',
                \                   'complete': 'customlist,quickrun#complete',}],
                \     'mappings': ['nxo', '<Plug>(quickrun)'],
                \ }}
    NeoBundle $GITHUB_COM.'osyo-manga/vim-watchdogs.git', {'lazy': 1,
                \ 'depends': [$GITHUB_COM.'thinca/vim-quickrun.git',
                \             $GITHUB_COM.'osyo-manga/shabadou.vim.git',
                \             $GITHUB_COM.'dannyob/quickfixstatus.git',
                \             $GITHUB_COM.'jceb/vim-hier.git',
                \            ],
                \ 'autoload': {
                \     'commands': [{'name': 'WatchdogsRun',
                \                   'complete': 'customlist,quickrun#complete',},
                \                   'WatchdogsRunSilent'],
                \ }}
    NeoBundleLazy $GITHUB_COM.'osyo-manga/shabadou.vim.git'
    NeoBundle $GITHUB_COM.'daisuzu/quickrun-hook-sphinx.git'

    " utility
    NeoBundle $GITHUB_COM.'daisuzu/translategoogle.vim.git'
    NeoBundle $GITHUB_COM.'mattn/ideone-vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'Ideone',
                \ }}

    NeoBundle $GITHUB_COM.'vim-scripts/project.tar.gz.git'
    NeoBundle $GITHUB_COM.'Shougo/vimproc.git', {
                \ 'build': {
                \     'windows': 'make -f make_mingw32.mak',
                \     'cygwin': 'make -f make_cygwin.mak',
                \     'mac': 'make -f make_mac.mak',
                \     'unix': 'make -f make_unix.mak',
                \    },
                \ }
    MyNeoBundle !s:Android $GITHUB_COM.'Shougo/vinarise.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'Vinarise',
                \ }}
    MyNeoBundle !s:Android $GITHUB_COM.'s-yukikaze/vinarise-plugin-peanalysis.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'Vinarise',
                \ }}
    NeoBundle $GITHUB_COM.'Shougo/vimfiler.git', {'lazy': 1,
                \ 'depends': $GITHUB_COM.'Shougo/unite.vim.git',
                \ 'autoload': {
                \     'commands': [{'name': 'VimFiler',
                \                   'complete': 'customlist,vimfiler#complete' },
                \                   'VimFilerExplorer',
                \                   'VimFilerSimple',
                \                   'VimFilerBufferDir',
                \                   'VimFilerCurrentDir',
                \                   'VimFilerDouble',
                \                   'Edit', 'Read', 'Source', 'Write'],
                \     'mappings': ['<Plug>(vimfiler_switch)'],
                \ }}
    NeoBundle $GITHUB_COM.'Shougo/vimshell.git', {'lazy': 1,
                \ 'autoload' : {
                \     'commands': [{'name': 'VimShell',
                \                   'complete': 'customlist,vimshell#complete'},
                \                   'VimShellExecute',
                \                   'VimShellInteractive',
                \                   'VimShellTerminal',
                \                   'VimShellPop'],
                \     'mappings': ['<Plug>(vimshell_switch)'],
                \ }}
    NeoBundle $GITHUB_COM.'ujihisa/vimshell-ssh.git'
    MyNeoBundle !s:Android $GITHUB_COM.'thinca/vim-logcat.git', {'lazy': 1,
                \ 'depends': $GITHUB_COM.'Shougo/vimshell.git',
                \ 'autoload': {
                \     'commands': 'Logcat',
                \ }}
    NeoBundle $GITHUB_COM.'thinca/vim-prettyprint.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': [{'name': 'PP',
                \                   'complete': 'expression'},
                \                   'PrettyPrint'],
                \ }}
    NeoBundle $GITHUB_COM.'thinca/vim-editvar.git', {'lazy': 1,
                \ 'depends': $GITHUB_COM.'thinca/vim-prettyprint.git',
                \ 'autoload': {
                \     'commands': [{'name': 'Editvar',
                \                   'complete': 'var'}],
                \ }}
    NeoBundle $GITHUB_COM.'tyru/open-browser.vim.git'
    MyNeoBundle !s:Android $GITHUB_COM.'sjl/splice.vim.git'
    MyNeoBundle !s:Android $GITHUB_COM.'sjl/gundo.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'GundoToggle',
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/copypath.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': ['CopyPath', 'CopyFileName', ],
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/DirDiff.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'DirDiff',
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/ShowMultiBase.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'ShowMultiBase',
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/ttoc.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'TToC',
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/wokmarks.vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/sudo.vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/Align.git'
    NeoBundle $GITHUB_COM.'kana/vim-submode.git'
    NeoBundle $GITHUB_COM.'itchyny/thumbnail.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'Thumbnail',
                \ }}
    NeoBundle $GITHUB_COM.'itchyny/calendar.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'Calendar',
                \ }}
    NeoBundle $GITHUB_COM.'thinca/vim-scall.git'
    NeoBundle $GITHUB_COM.'mattn/sonictemplate-vim.git'
    NeoBundle $GITHUB_COM.'LeafCage/vimhelpgenerator.git'
    NeoBundle $GITHUB_COM.'t9md/vim-choosewin.git', {'lazy': 1,
                \ 'autoload': {
                \     'mappings': ['<Plug>(choosewin)'],
                \ }}

    " command extension
    NeoBundle $GITHUB_COM.'thinca/vim-ambicmd.git'
    NeoBundle $GITHUB_COM.'tyru/vim-altercmd.git'
    NeoBundle $GITHUB_COM.'tomtom/tcommand_vim.git', {'lazy': 1,
                \ 'depends': $GITHUB_COM.'vim-scripts/tlib.git',
                \ 'autoload': {
                \     'commands': 'TCommand',
                \ }}
    NeoBundleLazy $GITHUB_COM.'mbadran/headlights.git'

    " C/C++
    NeoBundle $GITHUB_COM.'vim-scripts/c.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', ],
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/CCTree.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', ],
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/Source-Explorer-srcexpl.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', ],
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/trinity.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', ],
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/cscope-menu.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', ],
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/gtags.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', ],
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/DoxygenToolkit.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['c', 'cpp', ],
                \ }}

    " Python
    NeoBundle $GITHUB_COM.'alfredodeza/pytest.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['python', ],
                \ }}
    NeoBundle $GITHUB_COM.'klen/python-mode.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['python', ],
                \ }}
    NeoBundle $GITHUB_COM.'davidhalter/jedi-vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['python', ],
                \ }}

    " Perl
    NeoBundle $GITHUB_COM.'vim-scripts/perl-support.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['perl', ],
                \ }}
    NeoBundle $GITHUB_COM.'c9s/perlomni.vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['perl', ],
                \ }}

    " JavaScript
    NeoBundle $GITHUB_COM.'pangloss/vim-javascript.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['javascript', ],
                \ }}
    if executable('npm')
        NeoBundle $GITHUB_COM.'marijnh/tern_for_vim.git', {'lazy': 1,
                    \ 'build': {
                    \     'others': 'npm install',
                    \  },
                    \ 'autoload': {
                    \     'filetypes': ['javascript', ],
                    \ }}
    endif
    " Haskell
    NeoBundle $GITHUB_COM.'kana/vim-filetype-haskell.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['haskell', ],
                \ }}
    NeoBundle $GITHUB_COM.'lukerandall/haskellmode-vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['haskell', ],
                \ }}
    NeoBundle $GITHUB_COM.'Twinside/vim-syntax-haskell-cabal.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['haskell', ],
                \ }}
    NeoBundle $GITHUB_COM.'eagletmt/ghcmod-vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['haskell', ],
                \ }}
    NeoBundle $GITHUB_COM.'dag/vim2hs.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['haskell', ],
                \ }}

    " Clojure
    NeoBundle $GITHUB_COM.'thinca/vim-ft-clojure.git'
    NeoBundle $GITHUB_COM.'tpope/vim-fireplace.git', {'lazy': 1,
                \ 'autoload': {
                \     'filetypes': ['clojure', ],
                \ }}
    NeoBundle $GITHUB_COM.'tpope/vim-classpath.git'

    " CSV
    NeoBundle $GITHUB_COM.'vim-scripts/csv.vim.git'

    " SQL
    NeoBundle $GITHUB_COM.'mattn/vdbi-vim.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': 'VDBI',
                \ }}
    NeoBundle $GITHUB_COM.'daisuzu/dbext.vim.git', {'lazy': 1,
                \ 'rev': 'Fix/SyntaxBroken',
                \ 'autoload': {
                \     'filetypes': ['sql', ],
                \ }}
    NeoBundle $GITHUB_COM.'vim-scripts/SQLUtilities.git', {'lazy': 1,
                \ 'autoload': {
                \     'commands': ['SQLUFormatter',
                \                  'SQLUFormatStmts'],
                \ }}

    " textile
    NeoBundle $GITHUB_COM.'timcharper/textile.vim.git'

    " colorscheme
    NeoBundle $GITHUB_COM.'altercation/vim-colors-solarized.git'
    NeoBundle $GITHUB_COM.'vim-scripts/Colour-Sampler-Pack.git'
catch /E117/

endtry
"}}}

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
set grepprg=grep\ -nH
"set grepprg=ack.pl\ -a
" autocmd MyVimrcCmd QuickfixCmdPost make,grep,grepadd,vimgrep,vimgrepadd,helpgrep copen
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
try
    colorscheme motus
catch /E185/
    colorscheme torte
endtry
"}}}

set number
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
    return getbufvar(a:n, "&modified") == 1 ? "+" : ""
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
    let info = fnamemodify(getcwd(),"~:") . ' '
    return tabpages . '%=' . info
endfunction "}}}
set guioptions-=e
set tabline=%!MakeTabLine()
"}}}

" Visualization of the full-width space and the blank at the end of the line "{{{
if has("syntax")
    syntax on

    " for POD bug
    " syn sync fromstart

    function! ActivateInvisibleIndicator()
        let bufname = bufname('%')
        if bufname =~? '\[unite\]'
            return
        elseif bufname =~? 'vimfiler:'
            return
        endif

        syntax match InvisibleJISX0208Space "　" display containedin=ALL
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
    highlight Cursor      guifg=Black   guibg=Green   gui=bold
    highlight Search      ctermfg=Black ctermbg=Red   cterm=bold  guifg=Black  guibg=Red  gui=bold
    highlight StatusLine  ctermfg=White ctermbg=Blue guifg=white guibg=blue
    highlight Visual      cterm=reverse guifg=#404040 gui=bold
    highlight Folded      guifg=blue    guibg=darkgray
    " highlight Folded      guifg=blue    guibg=cadetblue

    highlight TabLine     ctermfg=Black ctermbg=White guifg=Black   guibg=#dcdcdc gui=underline
    highlight TabLineFill ctermfg=White ctermbg=Black guifg=Black   guibg=#dcdcdc gui=underline
    highlight TabLineSel  term=bold     cterm=bold    ctermfg=White ctermbg=Blue  guifg=White guibg=Blue gui=bold
    "}}}
    " For completion menu "{{{
    highlight Pmenu       ctermfg=White ctermbg=DarkBlue  guifg=#0033ff guibg=#99cccc gui=none
    highlight PmenuSel    ctermfg=Black ctermbg=Cyan      guifg=#ccffff guibg=#006699 gui=none
    highlight PmenuSbar   ctermfg=White ctermbg=LightCyan guifg=#ffffff guibg=#848484 gui=none
    highlight PmenuThumb  ctermfg=White ctermbg=DarkGreen guifg=#ffffff guibg=#006699 gui=none
    "}}}
    " For unite "{{{
    highlight UniteAbbr   guifg=#80a0ff    gui=underline
    highlight UniteCursor ctermbg=Blue     guifg=black     guibg=lightblue  gui=bold
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
" cscope_maps.vim "{{{
" http://cscope.sourceforge.net/cscope_vim_tutorial.html
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CSCOPE settings for vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" This file contains some boilerplate settings for vim's cscope interface,
" plus some keyboard mappings that I've found useful.
"
" USAGE:
" -- vim 6:     Stick this file in your ~/.vim/plugin directory (or in a
"               'plugin' directory in some other directory that is in your
"               'runtimepath'.
"
" -- vim 5:     Stick this file somewhere and 'source cscope.vim' it from
"               your ~/.vimrc file (or cut and paste it into your .vimrc).
"
" NOTE:
" These key maps use multiple keystrokes (2 or 3 keys).  If you find that vim
" keeps timing you out before you can complete them, try changing your timeout
" settings, as explained below.
"
" Happy cscoping,
"
" Jason Duell       jduell@alumni.princeton.edu     2002/3/7
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


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

    nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nnoremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>

    nnoremap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nnoremap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>


    " Hitting CTRL-space *twice* before the search type does a vertical
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nnoremap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nnoremap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>


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
" FullScreenToggle() "{{{
command! FullScreenToggle call FullScreenToggle()
function! FullScreenToggle()
    if s:is_full_screen
        call FullScreenOff()
    else
        call FullScreenOn()
    endif
endfunction

let s:is_full_screen = 0
function! FullScreenOn()
    let s:columns = &columns
    let s:lines = &lines
    set columns=9999
    set lines=999
    let s:is_full_screen = 1
endfunction
function! FullScreenOff()
    execute 'set columns=' . s:columns
    execute 'set lines=' . s:lines
    let s:is_full_screen = 0
endfunction
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
        silent execute winnr . "wincmd w"
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
" Capture "{{{
command!
            \ -nargs=+ -complete=command
            \ Capture
            \ call s:cmd_capture(<q-args>)

function! s:cmd_capture(q_args) "{{{
    redir => output
    silent execute a:q_args
    redir END
    let output = substitute(output, '^\n\+', '', '')

    belowright new

    silent file `=printf('[Capture: %s]', a:q_args)`
    setlocal buftype=nofile bufhidden=unload noswapfile nobuflisted
    call setline(1, split(output, '\n'))
endfunction "}}}
"}}}
" ContinuousNumber "{{{
nnoremap <silent> co :ContinuousNumber <C-a><CR>
vnoremap <silent> co :ContinuousNumber <C-a><CR>
command! -count -nargs=1 ContinuousNumber let c = col('.')
            \ | for n in range(1, <count>?<count>-line('.'):1)
            \ |     exec 'normal! j' . n . <q-args>
            \ |     call cursor('.', c)
            \ | endfor
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
        let [from, to] = [rs["From"], rs["To"]]
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
" s:has_plugin(name) "{{{
function! s:has_plugin(name)
    return globpath(&runtimepath, 'plugin/' . a:name . '.vim') !=# ''
                \ || globpath(&runtimepath, 'autoload/' . a:name . '.vim') !=# ''
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
" vim-ref:"{{{
"
autocmd MyVimrcCmd FileType vim,help setlocal keywordprg=:help

let g:ref_cache_dir = $DOTVIM.'/.vim_ref_cache'

" Python
let g:ref_pydoc_cmd = "python -m pydoc"

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
if has('lua')
"---------------------------------------------------------------------------
" neocomplete:"{{{
"
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#data_directory = $DOTVIM.'/.neocomplete'

let s:is_installed_neocomplete = 0
if s:has_plugin('neobundle')
    let s:is_installed_neocomplete = neobundle#is_installed('neocomplete')
endif

if s:is_installed_neocomplete
    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)
    inoremap <expr><C-g> neocomplete#undo_completion()
    inoremap <expr><C-l> neocomplete#complete_common_string()
    imap <C-q> <Plug>(neocomplete_start_unite_quick_match)

    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
        return neocomplete#smart_close_popup() . "\<CR>"
    endfunction

    " SuperTab like snippets behavior.
    "imap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"

    " <TAB>: completion.
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ neocomplete#start_manual_complete()
    function! s:check_back_space() "{{{
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
    endfunction "}}}
    " <S-TAB>: completion back.
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    " <C-y>: paste.
    inoremap <expr><C-y>  pumvisible() ? neocomplete#close_popup() :  "\<C-r>\""
    " <C-e>: close popup.
    inoremap <expr><C-e>  pumvisible() ? neocomplete#cancel_popup() : "\<End>"

    " <C-n>: neocomplete.
    inoremap <expr><C-n>  pumvisible() ? "\<C-n>" : "\<C-x>\<C-u>\<C-p>\<Down>"
    " <C-p>: keyword completion.
    inoremap <expr><C-p>  pumvisible() ? "\<C-p>" : "\<C-p>\<C-n>"

    " <C-f>, <C-b>: page move.
    inoremap <expr><C-f>  pumvisible() ? "\<PageDown>" : "\<Right>"
    inoremap <expr><C-b>  pumvisible() ? "\<PageUp>"   : "\<Left>"

    " For cursor moving in insert mode(Not recommended)
    "inoremap <expr><Left> neocomplete#close_popup() . "\<Left>"
    "inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
    "inoremap <expr><Up> neocomplete#close_popup() . "\<Up>"
    "inoremap <expr><Down> neocomplete#close_popup() . "\<Down>"
    " Or set this.
    "let g:neocomplete#enable_cursor_hold_i = 1

    " AutoComplPop like behavior.
    "let g:neocomplete#enable_auto_select = 1

    " Shell like behavior(not recommended).
    "set completeopt&
    "set completeopt+=longest
    "let g:neocomplete#enable_auto_select = 1
    "let g:neocomplete#disable_auto_complete = 1
    "inoremap <expr><TAB> pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
    "inoremap <expr><CR> neocomplete#smart_close_popup() . "\<CR>"

    call neocomplete#custom#source('look', 'min_pattern_length', 4)
endif

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0

" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Use fuzzy completion.
let g:neocomplete#enable_fuzzy_completion = 1

let g:neocomplete#ignore_source_files = ['tag.vim']

" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
" Set auto completion length.
let g:neocomplete#auto_completion_start_length = 2
" Set manual completion length.
let g:neocomplete#manual_completion_start_length = 0
" Set minimum keyword length.
let g:neocomplete#min_keyword_length = 3

let g:neocomplete#skip_auto_completion_time = '0.6'
let g:neocomplete#enable_insert_char_pre = 0

" For auto select.
let g:neocomplete#enable_auto_select = 0

let g:neocomplete#enable_auto_delimiter = 1
let g:neocomplete#disable_auto_select_buffer_name_pattern =
            \ '\[Command Line\]'
let g:neocomplete#max_list = 100

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
            \ 'default': '',
            \ 'vimshell': $DOTVIM.'/.vimshell/command-history',
            \ }

" Set includeexpr
if !exists('g:neocomplete#sources#file_include#exprs')
    let g:neocomplete#sources#file_include#exprs = {}
endif
let g:neocomplete#sources#file_include#exprs.perl = 'fnamemodify(substitute(v:fname, "/", "::", "g"), ":r")'

" Set omni patterns
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif
if !exists('g:neocomplete#sources#omni#functions')
    let g:neocomplete#sources#omni#functions = {}
endif

let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

" For jedi-vim
let g:neocomplete#sources#omni#input_patterns.python = '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
let g:neocomplete#enable_auto_close_preview = 1

" For perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'

" Set force omni patterns
let g:neocomplete#force_overwrite_completefunc = 1
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif

" For clang_complete
let g:neocomplete#force_omni_input_patterns.c =
            \ '[^.[:digit:] *\t]\%(\.\|->\)\w*'
let g:neocomplete#force_omni_input_patterns.cpp =
            \ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
let g:neocomplete#force_omni_input_patterns.objc =
            \ '[^.[:digit:] *\t]\%(\.\|->\)\w*'
let g:neocomplete#force_omni_input_patterns.objcpp =
            \ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'

" Define keyword pattern.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns._ = '[0-9a-zA-Z:#_]\+'
let g:neocomplete#keyword_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

let g:neocomplete#sources#vim#complete_functions = {
            \     'Ref': 'ref#complete',
            \     'Unite': 'unite#complete_source',
            \     'VimShellExecute': 'vimshell#vimshell_execute_complete',
            \     'VimShellInteractive': 'vimshell#vimshell_execute_complete',
            \     'VimShellTerminal': 'vimshell#vimshell_execute_complete',
            \     'VimShell': 'vimshell#complete',
            \     'VimFiler': 'vimfiler#complete',
            \     'Vinarise': 'vinarise#complete',
            \ }

" For snippet_complete marker.
if has('conceal')
    set conceallevel=2 concealcursor=i
endif
"}}}
else
"---------------------------------------------------------------------------
" neocomplcache:"{{{
"
let g:neocomplcache_enable_at_startup = 1

let s:is_installed_neocomplcache = 0
if s:has_plugin('neobundle')
    let s:is_installed_neocomplcache = neobundle#is_installed('neocomplcache')
endif

if s:is_installed_neocomplcache
    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)
    inoremap <expr><C-g> neocomplcache#undo_completion()
    inoremap <expr><C-l> neocomplcache#complete_common_string()
    imap <C-q> <Plug>(neocomplcache_start_unite_quick_match)

    " SuperTab like snippets behavior.
    "imap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <expr><silent> <CR> <SID>my_cr_function()
    function! s:my_cr_function()
        return pumvisible() ? neocomplcache#close_popup() . "\<CR>" : "\<CR>"
    endfunction

    " <TAB>: completion.
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ neocomplcache#start_manual_complete()
    function! s:check_back_space() "{{{
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
    endfunction "}}}
    " <S-TAB>: completion back.
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y> neocomplcache#close_popup()
    inoremap <expr><C-e> neocomplcache#cancel_popup()

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
endif

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Use fuzzy completion.
let g:neocomplcache_enable_fuzzy_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
" Set auto completion length.
let g:neocomplcache_auto_completion_start_length = 2
" Set manual completion length.
let g:neocomplcache_manual_completion_start_length = 0
" Set minimum keyword length.
let g:neocomplcache_min_keyword_length = 3
let g:neocomplcache_enable_cursor_hold_i = 0
let g:neocomplcache_cursor_hold_i_time = 300
let g:neocomplcache_enable_insert_char_pre = 0
let g:neocomplcache_enable_prefetch = 0
let g:neocomplcache_skip_auto_completion_time = '0.6'

if !exists('g:neocomplcache_wildcard_characters')
    let g:neocomplcache_wildcard_characters = {}
endif
let g:neocomplcache_wildcard_characters._ = '-'

" For auto select.
let g:neocomplcache_enable_auto_select = 0

let g:neocomplcache_enable_auto_delimiter = 1

let g:neocomplcache_disable_auto_select_buffer_name_pattern = '\[Command Line\]'

let g:neocomplcache_max_list = 100
let g:neocomplcache_force_overwrite_completefunc = 1

let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Disable caching buffer name
let g:neocomplcache_disable_caching_file_path_pattern = '\.txt'
let g:neocomplcache_temporary_dir = $DOTVIM.'/.neocon'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
            \     'default' : $DOTVIM.'/.neo_default',
            \ }

" Define keyword pattern.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
" let g:neocomplcache_keyword_patterns.default = '\h\w*'
let g:neocomplcache_keyword_patterns.default = '[0-9a-zA-Z:#_]\+'

" For snippet_complete marker.
if has('conceal')
    set conceallevel=2 concealcursor=i
endif

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.php = '[^. *\t]\.\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.mail = '^\s*\w\+'
let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
let g:neocomplcache_caching_limit_file_size = 500000

if !exists('g:neocomplcache_same_filetype_lists')
    let g:neocomplcache_same_filetype_lists = {}
endif

let g:neocomplcache_source_look_dictionary_path = ''

if !exists('g:neocomplcache_force_omni_patterns')
    let g:neocomplcache_force_omni_patterns = {}
endif
" let g:neocomplcache_force_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
" For clang_complete
let g:neocomplcache_force_omni_patterns.c =
            \ '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_force_omni_patterns.cpp =
            \ '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For jedi-vim.
let g:neocomplcache_force_omni_patterns.python = '[^. \t]\.\w*'

let g:neocomplcache_ignore_composite_filetype_lists = {
            \     'python.unit': 'python',
            \     'php.unit': 'php',
            \ }

let g:neocomplcache_vim_completefuncs = {
            \     'Ref': 'ref#complete',
            \     'Unite': 'unite#complete_source',
            \     'VimShellExecute': 'vimshell#vimshell_execute_complete',
            \     'VimShellInteractive': 'vimshell#vimshell_execute_complete',
            \     'VimShellTerminal': 'vimshell#vimshell_execute_complete',
            \     'VimShell': 'vimshell#complete',
            \     'VimFiler': 'vimfiler#complete',
            \     'Vinarise': 'vinarise#complete',
            \}
if !exists('g:neocomplcache_source_completion_length')
    let g:neocomplcache_source_completion_length = {
                \     'look' : 4,
                \ }
endif
"}}}
endif
"---------------------------------------------------------------------------
" neosnippet:"{{{
"
let g:neosnippet#snippets_directory = $DOTVIM.'/.snip/'
"}}}
"---------------------------------------------------------------------------
" clang_complete:"{{{
"
let g:clang_complete_auto = 0
let g:clang_auto_select = 0
let g:clang_use_library = 1

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
" taghighlight:"{{{
"
function! s:recallReadTypesCmd()
    for ft in keys(g:rt_cmd_registered)
        execute 'autocmd MyVimrcCmd FileType ' . ft . ' silent! ReadTypes'
    endfor
endfunction

if exists('g:rt_cmd_registered')
    call s:recallReadTypesCmd()
else
    let g:rt_cmd_registered = {}
endif

function! s:registerReadTypesCmd(ft)
    if !get(g:rt_cmd_registered, a:ft)
        execute 'autocmd MyVimrcCmd FileType ' . a:ft . ' silent! ReadTypes'
        let g:rt_cmd_registered[a:ft] = 1
    endif
endfunction
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

if s:MSWindows
    autocmd MyVimrcCmd FileType gitcommit setlocal encoding=utf-8
    autocmd MyVimrcCmd FileType gitcommit setlocal fileencoding=utf-8
    autocmd MyVimrcCmd FileType gitcommit setlocal fileencodings=utf-8
endif
"}}}
"---------------------------------------------------------------------------
" vim-signify:"{{{
"
"}}}
"---------------------------------------------------------------------------
" unite.vim:"{{{
"
" The prefix key.
nnoremap [unite] <Nop>
nmap f [unite]

nnoremap <silent> [unite]a  :<C-u>Unite -prompt=#\  buffer bookmark neomru/file file<CR>
nnoremap <silent> [unite]b  :<C-u>UniteWithBufferDir -buffer-name=files -prompt=%\  buffer bookmark neomru/file file<CR>
nnoremap <silent> [unite]c  :<C-u>UniteWithCurrentDir -buffer-name=files buffer bookmark neomru/file file<CR>
nnoremap <silent> [unite]e  :<C-u>Unite -buffer-name=files everything<CR>
nnoremap <silent> [unite]f  :<C-u>Unite source<CR>
nnoremap <expr>   [unite]g  ':<C-u>Unite grep:*::' . expand("<cword>")
nnoremap <silent> [unite]h  :<C-u>UniteWithCursorWord help<CR>
nnoremap <silent> [unite]l  :<C-u>Unite line<CR>
nnoremap <silent> [unite]m  :<C-u>Unite mark -no-quit<CR>
nnoremap <silent> [unite]o  :<C-u>Unite outline<CR>
nnoremap <silent> [unite]pi :<C-u>Unite neobundle/install<CR>
nnoremap <silent> [unite]pu :<C-u>Unite neobundle/update<CR>
nnoremap <silent> [unite]pl :<C-u>Unite neobundle<CR>
nnoremap <silent> [unite]r  :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]s  :<C-u>Unite scriptnames<CR>
nnoremap <silent> [unite]t  :<C-u>Unite buffer_tab tab buffer<CR>
nnoremap <silent> [unite]w  :<C-u>Unite window<CR>
nnoremap <silent> [unite]y  :<C-u>Unite history/yank<CR>
nnoremap <silent> [unite]:  :<C-u>Unite history/command<CR>
nnoremap <silent> [unite];  :<C-u>Unite history/command<CR>
nnoremap <silent> [unite]/  :<C-u>Unite history/search<CR>

let g:unite_source_history_yank_enable = 1

let g:unite_kind_file_cd_command = 'TabpageCD'
let g:unite_kind_file_lcd_command = 'TabpageCD'

" Start insert.
let g:unite_enable_start_insert = 1

autocmd MyVimrcCmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings() "{{{
    " Overwrite settings.

    nmap <buffer> <ESC> <Plug>(unite_exit)
    imap <buffer> jj <Plug>(unite_insert_leave)
    imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
    inoremap <buffer> <expr> <C-y> unite#do_action('insert')

    " <C-l>: manual neocomplcache completion.
    inoremap <buffer> <C-l> <C-x><C-u><C-p><Down>

endfunction "}}}

let g:unite_source_grep_max_candidates = 50000

let g:unite_data_directory = $DOTVIM.'/.unite'

" highlight UniteAbbr     guifg=#80a0ff    gui=underline
" highlight UniteCursor   guifg=black     guibg=lightblue  gui=bold
let g:unite_cursor_line_highlight = 'UniteCursor'
let g:unite_abbr_highlight = 'UniteAbbr'
"}}}
"---------------------------------------------------------------------------
" neomru.vim:"{{{
"
let g:neomru#file_mru_path = $DOTVIM.'/.neomru/file'
let g:neomru#directory_mru_path = $DOTVIM.'/.neomru/directory'
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
let g:loaded_textobj_parameter = 1
if s:has_plugin('textobj/user')
    call textobj#user#plugin('parameter', {
                \     '-': {
                \         'select-i': "ip",  '*select-i-function*': 'textobj#parameter#select_i',
                \         'select-a': "ap",  '*select-a-function*': 'textobj#parameter#select_a',
                \     }
                \ })
endif
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
execute "highlight qf_error_ucurl gui=undercurl guisp=Red"
let g:hier_highlight_group_qf = "qf_error_ucurl"

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

autocmd MyVimrcCmd QuickfixCmdPre make,grep,grepadd,vimgrep,vimgrepadd,helpgrep copen
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
if s:has_plugin('rainbowcyclone')
    nmap c/ <Plug>(rc_search_forward)
    nmap c? <Plug>(rc_search_backward)
    nmap c* <Plug>(rc_search_forward_with_cursor)
    nmap c# <Plug>(rc_search_backward_with_cursor)
    nmap cn <Plug>(rc_search_forward_with_last_pattern)
    nmap cN <Plug>(rc_search_backward_with_last_pattern)
    " nmap <Esc><Esc> <Plug>(rc_reset):nohlsearch<CR>
    nnoremap <Esc><Esc> :<C-u>RCReset<CR>:nohlsearch<CR>
endif
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
" vim-niceblock:"{{{
"
if s:has_plugin('niceblock')
    xnoremap <expr> r niceblock#force_blockwise('r')
endif
"}}}
"---------------------------------------------------------------------------
" vim-altr:"{{{
if s:has_plugin('altr')
    nnoremap <silent> tf :<C-u>call altr#forward()<CR>
    nnoremap <silent> tb :<C-u>call altr#back()<CR>
endif
"
"}}}
"---------------------------------------------------------------------------
" Unicode-RST-Table:"{{{
"
let g:no_rst_table_maps = 0
if s:has_plugin('rst_table')
    if has('python3')
        noremap <silent> ,,c :python3 CreateTable()<CR>
        noremap <silent> ,,f :python3 FixTable()<CR>
    elseif has('python')
        noremap <silent> ,,c :python CreateTable()<CR>
        noremap <silent> ,,f :python FixTable()<CR>
    endif
endif
"}}}
"---------------------------------------------------------------------------
" eregex.vim:"{{{
"
let g:eregex_default_enable = 0
nnoremap ,/ :<C-u>M/
nnoremap ,? :<C-u>M?
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
            \ }
let g:quickrun_config['watchdogs_checker/_'] = {
            \     'hook/close_unite_quickfix/enable_hook_loaded' : 1,
            \     'hook/unite_quickfix/enable_failure' : 1,
            \     'hook/close_quickfix/enable_exit' : 1,
            \     'hook/close_buffer/enable_exit' : 1,
            \     'hook/close_buffer/enable_failure' : 1,
            \     'hook/close_buffer/enable_empty_data' : 1,
            \     'outputter' : 'multi:buffer:quickfix',
            \     'hook/inu/enable' : 1,
            \     'hook/inu/wait' : 20,
            \     'runner' : 'vimproc',
            \     'runner/vimproc/updatetime' : 40,
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

if s:has_plugin('neobundle')
    let bundle = neobundle#get('vim-quickrun')

    function! bundle.hooks.on_source(bundle)
        NeoBundleSource quicklearn
    endfunction

    let bundle = neobundle#get('vim-watchdogs')
    function! bundle.hooks.on_source(bundle)
        call watchdogs#setup(g:quickrun_config)
    endfunction

    unlet bundle
endif
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
" vimfiler:"{{{
"
nnoremap [vimfiler] <Nop>
nmap <Space>v [vimfiler]

nnoremap <silent> [vimfiler]b :<C-u>VimFilerBufferDir<CR>
nnoremap <silent> [vimfiler]c :<C-u>VimFilerCurrentDir<CR>
nnoremap <silent> [vimfiler]d :<C-u>VimFilerDouble<CR>
nnoremap <silent> [vimfiler]f :<C-u>VimFilerSimple -no-quit -winwidth=32<CR>
nnoremap <silent> [vimfiler]s :<C-u>VimShell<CR>

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

let g:vimfiler_execute_file_list={
            \     'txt': 'vim',
            \     'vim': 'vim'
            \ }
"}}}
"---------------------------------------------------------------------------
" vimshell:"{{{
"
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_prompt = '% '
let g:vimshell_interactive_encodings = {'git': 'utf-8'}
let g:vimshell_data_directory = $DOTVIM.'/.vimshell'
let g:vimshell_vimshrc_path = $DOTVIM.'/.vimshell/.vimshrc'
let g:vimshell_cd_command = 'TabpageCD'
let g:vimshell_scrollback_limit = 50000

autocmd MyVimrcCmd FileType vimshell call s:vimshell_settings()
function! s:vimshell_settings()
    inoremap <silent><expr><buffer> <Up> unite#sources#vimshell_history#start_complete(!0)
    inoremap <silent><expr><buffer> <Down> unite#sources#vimshell_history#start_complete(!0)
endfunction
"}}}
"---------------------------------------------------------------------------
" vim-submode:"{{{
"
if s:has_plugin('submode')
    call submode#enter_with('undo/redo', 'n', '', 'g-', 'g-')
    call submode#enter_with('undo/redo', 'n', '', 'g+', 'g+')
    call submode#map('undo/redo', 'n', '', '-', 'g-')
    call submode#map('undo/redo', 'n', '', '+', 'g+')

    call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
    call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
    call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
    call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
    call submode#map('winsize', 'n', '', '>', '<C-w>>')
    call submode#map('winsize', 'n', '', '<', '<C-w><')
    call submode#map('winsize', 'n', '', '+', '<C-w>+')
    call submode#map('winsize', 'n', '', '-', '<C-w>-')

    call submode#enter_with('winmove', 'n', '', '<C-w>w', '<C-w>w')
    call submode#enter_with('winmove', 'n', '', '<C-w>j', '<C-w>j')
    call submode#enter_with('winmove', 'n', '', '<C-w>k', '<C-w>k')
    call submode#enter_with('winmove', 'n', '', '<C-w>h', '<C-w>h')
    call submode#enter_with('winmove', 'n', '', '<C-w>l', '<C-w>l')
    call submode#map('winmove', 'n', '', 'w', '<C-w>w')
    call submode#map('winmove', 'n', '', 'j', '<C-w>j')
    call submode#map('winmove', 'n', '', 'k', '<C-w>k')
    call submode#map('winmove', 'n', '', 'h', '<C-w>h')
    call submode#map('winmove', 'n', '', 'l', '<C-w>l')

    call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
    call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
    call submode#map('changetab', 'n', '', 't', 'gt')
    call submode#map('changetab', 'n', '', 'T', 'gT')
endif
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
let g:vimhelpgenerator_defaultlanguage = 'ja'
"}}}
"---------------------------------------------------------------------------
" vim-choosewin:"{{{
"
nmap <Leader>- <Plug>(choosewin)
let g:choosewin_overlay_enable = 1
let g:choosewin_overlay_clear_multibyte = 1
"}}}
"---------------------------------------------------------------------------
" vim-ambicmd:"{{{
"
if s:has_plugin('ambicmd')
    cnoremap <expr> <Space> ambicmd#expand("\<Space>")
    cnoremap <expr> <CR> ambicmd#expand("\<CR>")
    " cnoremap <expr> <C-f> ambicmd#expand("\<Right>")

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
" CCTree.vim:"{{{
"
if s:has_plugin('neobundle')
    let bundle = neobundle#get('CCTree')

    function! bundle.hooks.on_source(bundle)
        execute 'source ' . a:bundle.rtp . '/ftplugin/cctree.vim'
    endfunction

    unlet bundle
endif
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
nnoremap <Leader>gs :<C-u>Gtags -s <C-R>=expand("<cword>")<CR><CR>
nnoremap <Leader>gg :<C-u>Gtags -g <C-R>=expand("<cword>")<CR><CR>
nnoremap <Leader>gf :<C-u>Gtags -f <C-R>=expand("<cfile>")<CR><CR>
nnoremap <Leader>gr :<C-u>Gtags -r <C-R>=expand("<cword>")<CR><CR>
nnoremap <Leader>gd :<C-u>Gtags -d <C-R>=expand("<cword>")<CR><CR>
"}}}
"---------------------------------------------------------------------------
" python-mode:"{{{
"
let g:pymode_lint_on_fly = 1
let g:pymode_lint_on_write = 1
let g:pymode_lint_cwindow = 0
let g:pymode_lint_message = 1
let g:pymode_lint_signs = 1
let g:pydoc = "python -m pydoc"
let g:pymode_rope = 0
let g:pymode_folding = 0
let g:pymode_run = 0
let g:pymode_trim_whitespaces = 0
"}}}
"---------------------------------------------------------------------------
" jedi-vim:"{{{
"
let g:jedi#popup_on_dot = 0
let g:jedi#rename_command = '<Leader>jr'
"}}}
"---------------------------------------------------------------------------
" perl-support.vim:"{{{
"
let g:Perl_Debugger = "ptkdb"
"}}}
"---------------------------------------------------------------------------
" perlomni.vim:"{{{
"
if has('vim_starting')
    let $PATH = $DOTVIM . '/Bundle/perlomni.vim/bin:' . $PATH
endif
"}}}
"---------------------------------------------------------------------------
" haskellmode-vim:"{{{
"
if s:MSWindows
    let g:haddock_browser = "C:/Program\ Files/Mozilla\ Firefox/firefox.exe"
else
    let g:haddock_browser = "/usr/bin/firefox"
endif
"}}}
"---------------------------------------------------------------------------
" vim2hs:"{{{
"
vmap <silent> ios <Plug>InnerOffside
onoremap <silent> ios :normal vios<CR>
"}}}
"---------------------------------------------------------------------------
" dbext.vim:"{{{
"
let g:dbext_default_history_file = $DOTVIM.'/dbext_sql_history.txt'
"}}}
"---------------------------------------------------------------------------
" SQLUtilities:"{{{
"
let g:sqlutil_align_comma = 1
"}}}
"}}}

"---------------------------------------------------------------------------
" Key Mappings:"{{{
"
nnoremap ,f f
nnoremap ,t t

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

" insert blank in normal mode
nnoremap <C-Space> i <Esc><Right>
nnoremap <C-o> o<Esc>
nnoremap <M-o> O<Esc>

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

" (Round bracket)
onoremap ar a)
xnoremap ar a)
onoremap ir i)
xnoremap ir i)

" {Curly bracket}
onoremap ac a}
xnoremap ac a}
onoremap ic i}
xnoremap ic i}

" <Angle bracket>
onoremap aa a>
xnoremap aa a>
onoremap ia i>
xnoremap ia i>

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
"}}}

"---------------------------------------------------------------------------
" External Settings:"{{{
"
if 1 && filereadable($MYLOCALVIMRC)
    source $MYLOCALVIMRC
endif
"}}}

" vim: foldmethod=marker
