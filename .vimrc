"---------------------------------------------------------------------------
" .vimrc
"---------------------------------------------------------------------------
" Initialize:"{{{
"
augroup MyVimrcCmd
    autocmd!
augroup END

let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')

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
set encoding=utf-8
scriptencoding utf-8
set fileencodings=ucs-bom,utf-8,cp932,latin1
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

let s:plugins = {'start': [], 'opt': []}
call add(s:plugins.opt, 'https://github.com/vim-jp/vimdoc-ja')
call add(s:plugins.opt, 'https://github.com/tpope/vim-fugitive')
call add(s:plugins.opt, 'https://github.com/mhinz/vim-signify')
call add(s:plugins.opt, 'https://github.com/kana/vim-textobj-user')
call add(s:plugins.opt, 'https://github.com/kana/vim-textobj-indent')
call add(s:plugins.opt, 'https://github.com/kana/vim-textobj-syntax')
call add(s:plugins.opt, 'https://github.com/kana/vim-textobj-line')
call add(s:plugins.opt, 'https://github.com/kana/vim-textobj-fold')
call add(s:plugins.opt, 'https://github.com/kana/vim-textobj-entire')
call add(s:plugins.opt, 'https://github.com/thinca/vim-textobj-between')
call add(s:plugins.opt, 'https://github.com/thinca/vim-textobj-comment')
call add(s:plugins.opt, 'https://github.com/h1mesuke/textobj-wiw')
call add(s:plugins.opt, 'https://github.com/vimtaku/vim-textobj-sigil')
call add(s:plugins.opt, 'https://github.com/sgur/vim-textobj-parameter')
call add(s:plugins.opt, 'https://github.com/terryma/vim-expand-region')
call add(s:plugins.opt, 'https://github.com/kana/vim-operator-user')
call add(s:plugins.opt, 'https://github.com/kana/vim-operator-replace')
call add(s:plugins.opt, 'https://github.com/tyru/operator-camelize.vim')
call add(s:plugins.opt, 'https://github.com/tyru/operator-reverse.vim')
call add(s:plugins.opt, 'https://github.com/emonkak/vim-operator-sort')
call add(s:plugins.opt, 'https://github.com/thinca/vim-qfreplace')
call add(s:plugins.opt, 'https://github.com/nathanaelkane/vim-indent-guides')
call add(s:plugins.opt, 'https://github.com/daisuzu/rainbowcyclone.vim')
call add(s:plugins.opt, 'https://github.com/vim-scripts/matchparenpp')
call add(s:plugins.opt, 'https://github.com/tpope/vim-surround')
call add(s:plugins.opt, 'https://github.com/t9md/vim-textmanip')
call add(s:plugins.opt, 'https://github.com/kana/vim-niceblock')
call add(s:plugins.opt, 'https://github.com/kana/vim-altr')
call add(s:plugins.opt, 'https://github.com/vim-scripts/Unicode-RST-Tables')
call add(s:plugins.opt, 'https://github.com/thinca/vim-visualstar')
call add(s:plugins.opt, 'https://github.com/thinca/vim-quickrun')
call add(s:plugins.opt, 'https://github.com/Shougo/vinarise')
call add(s:plugins.opt, 'https://github.com/s-yukikaze/vinarise-plugin-peanalysis')
call add(s:plugins.opt, 'https://github.com/daisuzu/tree.vim')
call add(s:plugins.opt, 'https://github.com/thinca/vim-prettyprint')
call add(s:plugins.opt, 'https://github.com/thinca/vim-editvar')
call add(s:plugins.opt, 'https://github.com/thinca/vim-showtime')
call add(s:plugins.opt, 'https://github.com/tyru/open-browser.vim')
call add(s:plugins.opt, 'https://github.com/thinca/vim-scall')
call add(s:plugins.opt, 'https://github.com/mattn/sonictemplate-vim')
call add(s:plugins.opt, 'https://github.com/t9md/vim-choosewin')
call add(s:plugins.opt, 'https://github.com/prabirshrestha/vim-lsp')
call add(s:plugins.opt, 'https://github.com/mattn/vim-lsp-settings')
call add(s:plugins.opt, 'https://github.com/github/copilot.vim')

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

            echomsg 'helptags: ' . dst
            call s:create_helptags(expand(dst . '/doc/'))
        endfor
    endfor
endfunction

function! UpdatePackPlugins()
    topleft split
    edit `='[update plugins]'`
    setlocal buftype=nofile

    let s:pidx = 0
    let s:update_done = 0
    call timer_start(100, 'PluginUpdateHandler', {'repeat': len(s:plugins.opt)})
endfunction

function! PluginUpdateHandler(timer)
    let dir = expand($PACKPATH . '/' . 'opt')
    let url = s:plugins.opt[s:pidx]
    let dst = expand(dir . '/' . split(url, '/')[-1])

    let cmd = printf('git -C %s pull --ff-only', dst)
    call job_start(cmd, {
                \ 'out_io': 'buffer', 'out_name': '[update plugins]',
                \ 'exit_cb': function('s:on_update_exit'),
                \ })

    let s:pidx += 1
endfunction

function! s:on_update_exit(job, status) abort
    let s:update_done += 1
    if s:update_done == len(s:plugins.opt)
        call UpdateHelpTags()
        echomsg 'UpdatePackPlugins: done'
    endif
endfunction

let s:pidx = 0
function! PackAddHandler(timer)
    if s:pidx == 0
        autocmd! MyVimrcCmd VimEnter
    endif

    let plugin_name = split(s:plugins.opt[s:pidx], '/')[-1]

    let plugin_path = expand($PACKPATH . '/opt/' . plugin_name)
    if isdirectory(plugin_path)
        execute 'packadd ' . plugin_name
    endif

    let s:pidx += 1
    if s:pidx == len(s:plugins.opt)
        packadd cfilter
        packadd matchit
        call s:load_comment()
        " for filetype plugin
        doautocmd FileType
        doautocmd VimEnter
    endif
endfunction

function! s:load_comment()
    let filename = fnamemodify($MYVIMRC, ':p:h') . '/comment.vim'
    if filereadable(filename)
        execute 'source ' . filename
        return
    endif
    " fall back to loading the comment package if comment.vim is not readable
    packadd comment
    nmap  <silent> ,c  gc
    xmap  <silent> ,c  gc
    nmap  <silent> ,cc gcc
    " restore text object mappings overridden by the comment package
    onoremap ac a}
    xnoremap ac a}
    onoremap ic i}
    xnoremap ic i}
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
set ttimeout
set ttimeoutlen=50
set whichwrap=b,s,<,>,[,]
set wildmenu
set virtualedit+=block
set autoindent
" Smart indenting
set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
" for smartindent
inoremap # X<C-H><C-V>#
set completeopt=menuone,longest
" settings for Japanese folding
set formatoptions+=mM
" don't continue the comment line automatically
set formatoptions-=r formatoptions-=o
autocmd MyVimrcCmd FileType * setlocal formatoptions-=r formatoptions-=o
" settings for Japanese formatting
let format_allow_over_tw = 1
set nrformats=alpha,hex
" tags "{{{
set tags=./tags
set tags+=tags;
"}}}
" grep "{{{
command! UseGitgrep set grepprg=git\ grep\ -n\ --no-color
command! UseJvgrep set grepprg=jvgrep\ -n\ --no-color
if executable('jvgrep')
    :UseJvgrep
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
set display=truncate,uhex
set previewheight=12
set winwidth=20

set t_Co=256
if &term =~# 'xterm'
    let &t_SI = "\<Esc>[5 q"
    let &t_SR = "\<Esc>[3 q"
    let &t_EI = "\<Esc>[1 q"
endif

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
        " syntax match InvisibleTab "\t" display containedin=ALL
        " highlight InvisibleTab term=underline ctermbg=white gui=undercurl guisp=darkslategray
    endfunction
    call ActivateInvisibleIndicator()
    augroup invisible
        autocmd! invisible
        autocmd BufNew,BufRead,Syntax * call ActivateInvisibleIndicator()
        autocmd ColorScheme * call ActivateInvisibleIndicator()
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
    " Color name: $VIMRUNTIME/colors/lists/default.vim
    " IME Color "{{{
    if has('multi_byte_ime') || has('xim')
        " Set the color of the cursor when the IME ON
        highlight CursorIM guibg=#a020f0 guifg=NONE
        " Default IME settings in search mode and insert mode
        set iminsert=0 imsearch=0
        if has('xim') && has('GUI_GTK')
            "set imactivatekey=C-Space
        endif
    endif

    if has('multi_byte_ime')
        "    highlight Cursor guifg=NONE guibg=Green
        highlight CursorIM guifg=NONE guibg=#a020f0
    endif
    "}}}
    " Additional settings of Color "{{{
    " highlight Cursor      guifg=Black   guibg=Green   gui=bold
    highlight Search      ctermfg=Black ctermbg=Red   cterm=bold  guifg=#000000  guibg=#ff0000  gui=bold
    highlight Visual      cterm=reverse guifg=#404040 gui=bold
    highlight Folded      guifg=blue    guibg=darkgray

    highlight TabLine     ctermfg=Black ctermbg=White guifg=#000000   guibg=#dcdcdc gui=underline
    highlight TabLineFill term=none     cterm=none    ctermfg=Black ctermbg=White guifg=#000000   guibg=#dcdcdc gui=underline
    highlight TabLineSel  term=bold     cterm=bold    ctermfg=White ctermbg=Blue  guifg=White guibg=Blue gui=bold
    "}}}
    " For completion menu "{{{
    highlight Pmenu       ctermfg=White ctermbg=DarkBlue  guifg=#0033ff guibg=#99cccc gui=none
    highlight PmenuSel    ctermfg=Black ctermbg=Cyan      guifg=#ccffff guibg=#006699 gui=none
    highlight PmenuSbar   ctermfg=White ctermbg=LightCyan guifg=#ffffff guibg=#848484 gui=none
    highlight PmenuThumb  ctermfg=White ctermbg=DarkGreen guifg=#ffffff guibg=#006699 gui=none
    "}}}
    " For indent-guides "{{{
    let cterm_colors = (&background == 'dark') ? ['darkgray', 'gray'] : ['lightgray', 'white']
    let gui_colors   = (&background == 'dark') ? ['#262626', '#4d4d4d']  : ['#b3b3b3', '#d9d9d9']

    execute 'highlight IndentGuidesEven guibg=' . gui_colors[0] . ' guifg=' . gui_colors[1] . ' ctermbg=' . cterm_colors[0] . ' ctermfg=' . cterm_colors[1]
    execute 'highlight IndentGuidesOdd  guibg=' . gui_colors[1] . ' guifg=' . gui_colors[0] . ' ctermbg=' . cterm_colors[1] . ' ctermfg=' . cterm_colors[0]
    "}}}

    " For signify "{{{
    highlight SignifySignAdd    cterm=bold ctermbg=237  ctermfg=119 guifg=#000000 guibg=#00ff00
    highlight SignifySignDelete cterm=bold ctermbg=237  ctermfg=167 guifg=#000000 guibg=#ff0000
    highlight SignifySignChange cterm=bold ctermbg=237  ctermfg=227 guifg=#000000 guibg=#ffff00
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
" :tcd to the directory of the current file or specified path "{{{
command! -nargs=? -complete=dir -bang TCD call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        if &buftype !=# 'terminal'
            tcd %:p:h
        endif
    else
        execute 'tcd' . a:directory
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
command! GoScratch set ft=go | ToScratch | Template main

command! -bar -nargs=? ModsNew <mods> new | if <q-args> ==# 'Files:.' | edit `='[Files:' . fnamemodify(getcwd(), ':p:h') . ']'` | elseif len(<q-args>) | edit [<args>] | endif

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
command! MRU <mods> ModsNew MRU | ToScratchForFiles | call setline(1, filter(copy(v:oldfiles), 'filereadable(expand(v:val))'))

" list results of given ex-cmd(e.g. :buffers, :scriptnames)
command! -nargs=1 -complete=command L <mods> ModsNew <args> | ToScratchForFiles | call setline(1, split(execute(<q-args>), '\n'))
command! ScriptNames <mods> L scriptnames
command! Buffers <mods> L buffers
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
" Qf2Loc"{{{
command! Qf2Loc call setloclist(0, getqflist())
command! Loc2Qf call setqflist(getloclist(0))
"}}}
" SudoWrite"{{{
command! SudoWrite execute 'write !sudo tee ' . shellescape(expand('%:p'), 1) . ' > /dev/null' | edit!
"}}}
" Align"{{{
" :[range]Align[!] [{pattern} ...]
function! s:align(line1, line2, first, ...) abort
    let pat = a:0 ? '\%(' . join(a:000, '\|') . '\)' : '\s\+'
    let rows = []
    for [i, line] in items(getline(a:line1, a:line2))
        let str = trim(line)
        let seps = matchstrlist([str], pat)->filter({_, m -> m.text !=# ''})
        if empty(seps)
            continue
        endif
        let fields = []
        let start = 0
        for m in a:first ? seps[:0] : seps
            let fields += [str->strpart(start, m.byteidx - start)->trim(), trim(m.text)]
            let start = m.byteidx + strlen(m.text)
        endfor
        call add(rows, [a:line1 + i, fields->add(str->strpart(start)->trim())])
    endfor
    if empty(rows)
        return
    endif
    " use the indent of the first aligned line for all lines
    let indent = getline(rows[0][0])->matchstr('^\s*')
    let widths = repeat([0], rows->mapnew({_, r -> len(r[1])})->max())
    for [lnum, fields] in rows
        for [c, f] in items(fields)
            let widths[c] = max([widths[c], strdisplaywidth(f)])
        endfor
    endfor
    " skip columns that are empty in every line (e.g. whitespace separators)
    let cols = range(len(widths))->filter({_, c -> widths[c] > 0})
    for [lnum, fields] in rows
        let cells = cols->mapnew({_, c -> printf('%-*S', widths[c], get(fields, c, ''))})
        call setline(lnum, trim(indent . join(cells), '', 2))
    endfor
endfunction
command! -range -bang -nargs=* Align call s:align(<line1>, <line2>, <bang>0, <f-args>)
"}}}
" GitLog"{{{
" :GitLog[!] [{git-log-args}]
function! s:git_log(file, args) abort
    let top = systemlist('git -C ' . shellescape(expand('%:p:h')) . ' rev-parse --show-toplevel')
    if v:shell_error
        echohl ErrorMsg | echomsg 'GitLog: ' . join(top) | echohl None
        return
    endif
    let show = {'dir': top[0], 'path': a:file ? expand('%:p') : '', 'paths': {}, 'buf': -1, 'hash': ''}
    let git = ['git', '-C', show.dir, '-c', 'core.quotePath=false']
    let follow = empty(show.path) ? [] : ['--follow', '--', show.path]
    " colored only to tell the refs from a subject starting with (
    let raw = systemlist(join(map(git + ['lg', '--color=always'] + a:args + follow, 'shellescape(v:val)')))
    if v:shell_error
        echohl ErrorMsg | echomsg 'GitLog: ' . join(raw) | echohl None
        return
    endif
    if !empty(show.path)
        " the paths of the file in each commit, to show the diff before a rename
        let hash = ''
        for line in systemlist(join(map(git + ['log'] + a:args + ['--format=%x09%h', '--name-status'] + follow, 'shellescape(v:val)')))
            if line =~# '^\t'
                let hash = line[1 :]
            elseif line =~# '\t'
                let show.paths[hash] = split(line, '\t')[1 :]
            endif
        endfor
    endif
    let lines = map(copy(raw), {_, l -> substitute(l, '\e\[[0-9;]*m', '', 'g')})
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap
    call setline(1, lines)
    " highlight the format of `git lg`
    syntax match gitLogHash /^[*|\/\\_ .-]*\zs\x\{7,}/ nextgroup=gitLogDate skipwhite
    syntax match gitLogDate /\[[^]]*\]/ contained
    syntax match gitLogRelDate /(\%(\d\+ \a\+,\? \)\+ago)\ze <[^>]*>$/
    syntax match gitLogAuthor /<[^>]*>$/
    highlight default link gitLogHash Identifier
    highlight default link gitLogDate Constant
    highlight default link gitLogRefs Special
    highlight default link gitLogRelDate Comment
    highlight default link gitLogAuthor Type
    " the refs are colored inside the parens, a subject is not
    call prop_type_add('gitLogRefs', {'bufnr': bufnr(), 'highlight': 'gitLogRefs'})
    for [i, l] in items(raw)
        let p = match(l, '(\e\[')
        if p >= 0
            let col = strlen(substitute(l[: p], '\e\[[0-9;]*m', '', 'g'))
            let end = matchend(lines[i], '([^)]*)', col - 1)
            call prop_add(i + 1, col, {'type': 'gitLogRefs', 'length': end - col + 1})
        endif
    endfor
    let b:git_log = show
    nnoremap <buffer> <silent> <CR> :<C-u>call <SID>git_log_show()<CR>
    nnoremap <buffer> <silent> q :<C-u>tabclose<CR>
    call s:git_log_show()
endfunction

function! s:git_log_show() abort
    let show = b:git_log
    let hash = getline('.')->matchstr('^[*|/\\_ .-]*\zs\x\{7,}')
    if empty(hash) || hash ==# show.hash && bufwinid(show.buf) >= 0
        return
    endif
    if bufwinid(show.buf) < 0
        " (re)open the diff window, e.g. after it was closed or replaced by gf
        execute winnr('l') != winnr() ? 'wincmd l | enew' : 'rightbelow vnew'
        setlocal buftype=nofile bufhidden=wipe noswapfile syntax=git
        " fold each file by text, not by syntax (git.vim syncs only 50 lines back)
        setlocal foldmethod=expr foldtext=s:git_log_foldtext()
        let &l:foldexpr = "getline(v:lnum) =~# '^diff ' ? '>1' : '='"
        " gf on a/{file} or b/{file} opens {file} in the work tree
        let &l:includeexpr = "substitute(v:fname, '^[ab]/', '', '')"
        let &l:path = escape(show.dir, ' ,')
        let show.buf = bufnr()
        wincmd p
    endif
    let show.hash = hash
    let paths = empty(show.path) ? [] : ['--'] + get(show.paths, hash, [show.path])
    let cmd = ['git', '-C', show.dir, '-c', 'core.quotePath=false', 'show', '--no-color', hash] + paths
    call deletebufline(show.buf, 1, '$')
    call setbufline(show.buf, 1, systemlist(join(map(cmd, 'shellescape(v:val)'))))
    call win_execute(bufwinid(show.buf), 'normal! gg')
endfunction
function! s:git_log_foldtext() abort
    let lines = getline(v:foldstart, v:foldend)
    let file = lines[0]->matchstr(' b/\zs.*$')
    if match(lines, '^Binary files ') >= 0
        return 'Binary: ' . file
    endif
    " count only after the first hunk header to skip the ---/+++ lines
    let start = match(lines, '^@@')
    let body = start < 0 ? [] : lines[start :]
    let add = len(filter(copy(body), 'v:val =~# "^+"'))
    let del = len(filter(copy(body), 'v:val =~# "^-"'))
    return printf('+-- %3d+ %3d- %s', add, del, file)
endfunction
command! -bang -nargs=* GitLog call s:git_log(<bang>0, [<f-args>])
"}}}
" GoHiCover"{{{
function! s:go_hi_cover(profile) abort
    let profile = empty(a:profile) ? 'cover.out' : a:profile
    let gomod = findfile('go.mod', expand('%:p:h') . ';')
    if !filereadable(profile) || empty(gomod)
        echohl ErrorMsg | echomsg 'GoHiCover: ' . profile . ' or go.mod not found' | echohl None
        return
    endif
    let module = readfile(gomod)->filter({_, l -> l =~# '^module\s'})->get(0, '')->matchstr('^module\s\+\zs\S\+')
    " the current file as written in the profile: {module}/{path from go.mod}
    let target = module . '/' . expand('%:p')[len(fnamemodify(gomod, ':p:h')) + 1 :]
    " a block can appear more than once (e.g. -coverpkg), so keep the max count
    let blocks = {}
    for line in readfile(profile)[1:]
        " {file}:{startline}.{startcol},{endline}.{endcol} {numstmt} {count}
        let m = matchlist(line, '^\(.\+\):\(\d\+\.\d\+,\d\+\.\d\+\) \d\+ \(\d\+\)$')
        if !empty(m) && m[1] ==# target
            let blocks[m[2]] = max([get(blocks, m[2], 0), str2nr(m[3])])
        endif
    endfor
    let pos = {'goCoverageCovered': [], 'goCoverageUncover': []}
    for [block, cnt] in items(blocks)
        let [sl, sc, el, ec] = split(block, '[.,]')->map('str2nr(v:val)')
        let p = pos[cnt > 0 ? 'goCoverageCovered' : 'goCoverageUncover']
        if sl == el
            call add(p, [sl, sc, ec - sc])
            continue
        endif
        call extend(p, [[sl, sc, strlen(getline(sl)) - sc + 1]] + range(sl + 1, el - 1))
        if ec > 1
            call add(p, [el, 1, ec - 1])
        endif
    endfor
    call s:go_hi_cover_clear()
    highlight default link goCoverageNormalText Comment
    highlight default goCoverageCovered ctermfg=green guifg=#A6E22E
    highlight default goCoverageUncover ctermfg=red guifg=#F92672
    let w:go_hi_cover = [matchadd('goCoverageNormalText', '.\+', 1)]
    for [group, p] in items(pos)->filter({_, v -> !empty(v[1])})
        call add(w:go_hi_cover, matchaddpos(group, p, 2))
    endfor
    autocmd! MyVimrcCmd BufWinLeave <buffer>
    autocmd MyVimrcCmd BufWinLeave <buffer> ++once call s:go_hi_cover_clear()
endfunction

function! s:go_hi_cover_clear() abort
    for id in get(w:, 'go_hi_cover', [])
        silent! call matchdelete(id)
    endfor
    let w:go_hi_cover = []
endfunction
command! -nargs=? -complete=file GoHiCover call s:go_hi_cover(<q-args>)
command! -bar GoHiCoverClear call s:go_hi_cover_clear()
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
" vim-fugitive:"{{{
"
nnoremap <Space>gd :<C-u>Gdiffsplit<CR>
nnoremap <Space>gs :<C-u>Git<CR>
nnoremap <Space>ga :<C-u>Gwrite<CR>
nnoremap <Space>gc :<C-u>Git commit -v<CR>
nnoremap <Space>gC :<C-u>Git commit --amend -v<CR>
nnoremap <Space>gb :<C-u>Git blame<CR>
nnoremap <Space>gv :<C-u>GitLog<CR>
nnoremap <Space>gV :<C-u>GitLog!<CR>

if s:MSWindows
    autocmd MyVimrcCmd FileType gitcommit setlocal encoding=utf-8
    autocmd MyVimrcCmd FileType gitcommit setlocal fileencoding=utf-8
    autocmd MyVimrcCmd FileType gitcommit setlocal fileencodings=utf-8
endif
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
xmap + <Plug>(expand_region_expand)
xmap - <Plug>(expand_region_shrink)
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
nmap _ <Plug>(operator-replace)
xmap _ <Plug>(operator-replace)
omap _ <Plug>(operator-replace)
xmap p <Plug>(operator-replace)
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
" vim-indent-guides:"{{{
"
" let g:indent_guides_indent_levels = 30
let g:indent_guides_auto_colors = 0
" let g:indent_guides_color_change_percent = 10
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
" let g:indent_guides_space_guides = 0
let g:indent_guides_enable_on_vim_startup = 1
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
            \     'type': 'rst/pandoc'
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
"}}}
"---------------------------------------------------------------------------
" tree.vim:"{{{
"
set isfname+=@-@

function! TreeResize()
    augroup TreeCmd
        autocmd!
        autocmd BufEnter <buffer> vertical resize 32
        autocmd BufLeave <buffer> vertical resize 32
    augroup END
    doautocmd TreeCmd BufEnter
endfunction

" https://github.com/daisuzu/go-tree
if executable('go-tree')
    nnoremap <silent> <Space>vf :<C-u>execute 'vertical '. v:count .'ATree' <Bar> call TreeResize()<CR>
else
    nnoremap <silent> <Space>vf :<C-u>execute 'vertical '. v:count .'Tree' <Bar> call TreeResize()<CR>
endif

command! -nargs=? -complete=dir -count -bang -bar ATree call s:async_tree(<q-args>, <count>, <bang>0, <q-mods>)

function! s:async_tree(dir, depth, bang, mods) abort
    let cmd = 'go-tree -V ' . g:tree_options
    if a:bang
        let cmd .= ' -a'
    endif
    if a:depth > 0
        let cmd .= ' -L ' . a:depth
    endif
    let cmd .= ' ' . fnamemodify(a:dir !=# '' ? a:dir : '.', ':p:h')

    execute a:mods . ' new'
    setfiletype tree

    let bufnr = bufnr('%')
    call job_start(cmd, {
                \   'out_io': 'buffer',
                \   'out_buf': bufnr,
                \   'exit_cb': {channel, msg -> s:goto_first(bufnr)},
                \ })
endfunction

function! s:goto_first(bufnr)
    if bufnr('%') != a:bufnr
        return
    endif
    if line('.') != line('$')
        return
    endif
    goto
endfunction

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
" use only :Template command (don't define <C-y> mappings)
let g:sonictemplate_key = ''
let g:sonictemplate_intelligent_key = ''
let g:sonictemplate_postfix_key = ''
"}}}
"---------------------------------------------------------------------------
" vim-choosewin:"{{{
"
nmap <Leader>- <Plug>(choosewin)
let g:choosewin_overlay_enable = 1
let g:choosewin_overlay_clear_multibyte = 1
"}}}
"---------------------------------------------------------------------------
" vim-lsp:"{{{
"
let g:lsp_fold_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_tagfunc_source_methods = ['definition']

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal tagfunc=lsp#tagfunc
    nnoremap <buffer> <silent> g] :<C-u>execute 'tselect ' . expand('<cword>') <CR>
    if index(['go', 'proto'], &filetype) >= 0
        augroup lsp_format_on_save
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> LspDocumentFormatSync
            autocmd BufWritePre <buffer> LspCodeActionSync source.organizeImports
        augroup END
    endif
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:lsp_settings = {
      \  'gopls': {
      \    'initialization_options': {
      \      'matcher': 'fuzzy',
      \      'completeUnimported': v:false,
      \      'deepCompletion': v:false,
      \      'usePlaceholders': v:false,
      \      'symbolMatcher': 'fuzzy',
      \      'symbolStyle': 'full',
      \      'gofumpt': v:true,
      \      'staticcheck': v:false,
      \      'analyses': {'fillstruct': v:true, 'unusedwrite': v:true},
      \      'codelenses': {'gc_details': v:true, 'test': v:true},
      \    },
      \  }
      \}

command! OrganizeImports LspCodeActionSync source.organizeImports

command! AppendCallTree call s:append_tree(':LspCallHierarchyIncoming')
command! AppendRefTree call s:append_tree(':LspReferences')
command! AppendImplTree call s:append_tree(':LspImplementation')
command! AppendCallTreeR call s:append_tree(':LspCallHierarchyOutgoing')

augroup AppendTree
    autocmd!
augroup END

function! s:append_tree(cmd) abort
    autocmd AppendTree BufWinEnter quickfix let s:lsp_done = 1

    copen
    let l:pos = line('.')
    let l:parent_tree = getqflist()
    call setqflist([])
    let l:level = count(l:parent_tree[l:pos-1].text, '⬅️  ')
    wincmd p

    let s:lsp_done = 0
    execute a:cmd

    let l:cnt = 0
    while !s:lsp_done && l:cnt < 100
        sleep 10m
        let l:cnt += 1
    endwhile

    let l:child = getqflist()
    if len(l:child) != 0
        call extend(l:parent_tree, map(l:child, 'extend(v:val, {"text": repeat("⬅️  ", l:level+1) . v:val.text})'), l:pos)
    endif

    call setqflist(l:parent_tree)
    execute 'cc ' . string(l:pos + 1)

    autocmd! AppendTree
endfunction

function! SortCallHierarchy(i1, i2)
    if a:i1.bufnr == a:i2.bufnr
        return a:i1.lnum - a:i2.lnum
    endif
    return a:i1.bufnr - a:i2.bufnr
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

" improve replacement of twice the width of characters in linewise
xnoremap <expr> r mode() ==# 'V' ? "\<C-v>0o$r" : "r"

" Tabpage related mappings
nnoremap <Space>tn :<C-u>tabnew<CR>
nnoremap <Space>tc :<C-u>tabclose<CR>
nnoremap <Space>tC :<C-u>tabclose!<CR>
nnoremap <Space>ts :<C-u>tabs<CR>

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
