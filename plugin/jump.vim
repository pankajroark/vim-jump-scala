let s:debug = 0

let s:scriptdirpy = expand("<sfile>:h") . '/'
exec 'pyfile ' . s:scriptdirpy . 'jump.py'

function! s:MarkDirty()
  py mark_dirty()
endfunction

augroup sjump_save_hook
autocmd!
autocmd BufWritePost *.java,*.scala call s:MarkDirty()
augroup end

function! s:RunCmd(cmd)
  let orig_shortmess = &shm
  let &shm=orig_shortmess.'s'
  let orig_cmdheight = &cmdheight
  let &cmdheight = 10
  let orig_scrolloff = &scrolloff
  " jumps should be centered
  let &scrolloff = 999 

  py run_cmd()

  let &shm=orig_shortmess
  let &cmdheight = orig_cmdheight
  let &scrolloff = orig_scrolloff
endfunc

function! s:Jump()
  call s:RunCmd("jump")
endfunc

function! s:Find()
  call s:RunCmd("find")
endfunc

command! ScalaJump :call s:Jump()
command! ScalaProjFind :call s:Find()
