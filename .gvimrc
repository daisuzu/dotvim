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
"  set guifont=MS_Gothic:h12:cSHIFTJIS
"  set guifontwide=MS_Gothic:h12:cSHIFTJIS
  set guifont=MS_Gothic:h10:cSHIFTJIS
  set linespace=1
endif

" 印刷に関する設定:
"
" 注釈:
" 印刷はGUIでなくてもできるのでvimrcで設定したほうが良いかもしれない。この辺
" りはWindowsではかなり曖昧。一般的に印刷には明朝、と言われることがあるらし
" いのでデフォルトフォントは明朝にしておく。ゴシックを使いたい場合はコメント
" アウトしてあるprintfontを参考に。
"
" 参考:
"   :hardcopy
"   :help 'printfont'
"   :help printing
"印刷用フォント
if has('printer')
  if has('win32') || has('win64')
    set printfont=MS_Mincho:h12:cSHIFTJIS
"    set printfont=MS_Gothic:h12:cSHIFTJIS
  endif
endif
"}}}

"---------------------------------------------------------------------------
" Mouse:"{{{
"
" 解説:
" mousefocusは幾つか問題(一例:ウィンドウを分割しているラインにカーソルがあっ
" ている時の挙動)があるのでデフォルトでは設定しない。Windowsではmousehide
" が、マウスカーソルをVimのタイトルバーに置き日本語を入力するとチラチラする
" という問題を引き起す。
"
" どのモードでもマウスを使えるようにする
set mouse=a
" マウスの移動でフォーカスを自動的に切替えない (mousefocus:切替る)
set nomousefocus
" 入力時にマウスポインタを隠す (nomousehide:隠さない)
set nomousehide
" ビジュアル選択(D&D他)を自動的にクリップボードへ (:help guioptions_a)
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

" 水平スクロールバーのサイズをカーソル行の長さに制限する。
set guioptions&
set guioptions+=h

" 水平スクロールバーの表示切替
nnoremap  <silent> <Space>oh :if &guioptions =~# 'b' <Bar>
      \set guioptions-=b <Bar>
      \else <Bar>
      \set guioptions+=b <Bar>
      \endif <CR>

" ウインドウの幅
set columns=160
" ウインドウの高さ
set lines=40
" コマンドラインの高さ(GUI使用時)
set cmdheight=2
"}}}

"---------------------------------------------------------------------------
" IME:"{{{
"
if has('multi_byte_ime') || has('xim')
  " IME ON時のカーソルの色を設定(設定例:紫)
  highlight CursorIM guibg=Purple guifg=NONE
  " 挿入モード・検索モードでのデフォルトのIME状態設定
  set iminsert=0 imsearch=0
  if has('xim') && has('GUI_GTK')
    "set imactivatekey=C-Space
  endif
endif

if has('multi_byte_ime')
"  highlight Cursor guifg=NONE guibg=Green
  highlight CursorIM guifg=NONE guibg=Purple
endif
"}}}

"---------------------------------------------------------------------------
" Plugins:"{{{
"
"---------------------------------------------------------------------------
" Unite:"{{{
"
highlight UniteAbbr     guifg=#80a0ff    gui=underline
highlight UniteCursor   guifg=black     guibg=lightblue  gui=bold

let g:unite_cursor_line_highlight = 'UniteCursor'
let g:unite_abbr_highlight = 'UniteAbbr'
"}}}

"---------------------------------------------------------------------------
" IndentGuides:"{{{
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
" Hier:"{{{
"
" quickfix のエラー箇所を波線でハイライト
execute "highlight qf_error_ucurl gui=undercurl guisp=Red"
let g:hier_highlight_group_qf  = "qf_error_ucurl"

augroup Hier
    au!
    au QuickFixCmdPost,BufEnter,WinEnter QuickRun :HierUpdate
augroup END
"}}}
"}}}

" vim: foldmethod=marker
