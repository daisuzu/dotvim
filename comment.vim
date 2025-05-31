vim9script

# comment.vimのautoloadだけ使う
set runtimepath+=$VIMRUNTIME/pack/dist/opt/comment
import autoload 'comment.vim'
nnoremap <silent> <expr> ,c comment.Toggle()
xnoremap <silent> <expr> ,c comment.Toggle()
nnoremap <silent> <expr> ,cc comment.Toggle() .. '_'
