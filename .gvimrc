"---------------------------------------------------------------------------
" .gvimrc
"---------------------------------------------------------------------------
" Fonts:"{{{
"
if has('xfontset')
    set guifontset=a14,r14,k14
elseif has('unix')

elseif has('mac')
    set guifont=Osaka-mono:h14
elseif has('win32') || has('win64')
"    set guifont=MS_Gothic:h12:cSHIFTJIS
"    set guifontwide=MS_Gothic:h12:cSHIFTJIS
    set guifont=MS_Gothic:h10:cSHIFTJIS
    set linespace=1
endif

" For Printer :
if has('printer')
    if has('win32') || has('win64')
        set printfont=MS_Mincho:h12:cSHIFTJIS
"       set printfont=MS_Gothic:h12:cSHIFTJIS
    endif
endif
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
" Window:"{{{
"
try
    colorscheme motus
catch /E185/
    colorscheme torte
endtry

highlight Search        guifg=Black    guibg=Red        gui=bold
highlight Visual        guifg=#404040  gui=bold
highlight Cursor        guifg=Black    guibg=Green      gui=bold
highlight StatusLine    guifg=white    guibg=blue
highlight Folded        guifg=blue     guibg=darkgray

highlight TabLine ctermfg=0 ctermbg=8 guifg=Black guibg=#dcdcdc gui=underline 
highlight TabLineSel term=bold cterm=bold ctermfg=15 ctermbg=9 guifg=White guibg=Blue gui=bold 
highlight TabLineFill ctermfg=0 ctermbg=8 guifg=Black guibg=#dcdcdc gui=underline 


" Limit horizontal scrollbar size to the length of the cursor line
set guioptions+=h

" Toggle horizontal scrollbar
nnoremap  <silent> <Space>oh :if &guioptions =~# 'b' <Bar>
      \set guioptions-=b <Bar>
      \else <Bar>
      \set guioptions+=b <Bar>
      \endif <CR>

" Window width
set columns=160
" Window height
set lines=40
" Command-line height
set cmdheight=2
"}}}

"---------------------------------------------------------------------------
" IME:"{{{
"
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

"---------------------------------------------------------------------------
" Plugins:"{{{
"
"---------------------------------------------------------------------------
" unite.vim:"{{{
"
highlight UniteAbbr     guifg=#80a0ff    gui=underline
highlight UniteCursor   guifg=black     guibg=lightblue  gui=bold

let g:unite_cursor_line_highlight = 'UniteCursor'
let g:unite_abbr_highlight = 'UniteAbbr'
"}}}

"---------------------------------------------------------------------------
" vim-indent-guides:"{{{
"
let g:indent_guides_enable_on_vim_startup = 1
try
    IndentGuidesEnable
catch /E492/
    echo 
endtry
"}}}

"---------------------------------------------------------------------------
" MultipleSearch:"{{{
"
try
    Search
    SearchReinit
    SearchReset
catch /E492/

endtry
"}}}

"---------------------------------------------------------------------------
" vim-hier:"{{{
"
" To highlight with a undercurl in quickfix error
execute "highlight qf_error_ucurl gui=undercurl guisp=Red"
let g:hier_highlight_group_qf  = "qf_error_ucurl"

augroup Hier
    autocmd!
    autocmd QuickFixCmdPost,BufEnter,WinEnter QuickRun :HierUpdate
augroup END
"}}}
"}}}

"---------------------------------------------------------------------------
" External Settings:"{{{
"
let $MYLOCALGVIMRC = $DOTVIM.'/.local.gvimrc'

if 1 && filereadable($MYLOCALGVIMRC)
    source $MYLOCALGVIMRC
endif
"}}}

" vim: foldmethod=marker
