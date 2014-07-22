function! s:BetterJump()
  let orig_shortmess = &shm
  let &shm=orig_shortmess.'s'
  let orig_cmdheight = &cmdheight
  let &cmdheight = 10
  let orig_scrolloff = &scrolloff
  " jumps should be centered
  let &scrolloff = 999 

python << EOF

import vim, urllib2

cur_word = vim.eval("expand('<cword>')")
cb = vim.current.buffer
cw = vim.current.window
pos = cw.cursor
cur_file = cb.name
row = pos[0]
col = pos[1]

URL_STR = "http://localhost:8081/jump?file=%s&symbol=%s&row=%s&col=%s"

URL = URL_STR % (cur_file, cur_word, row, col)

response = urllib2.urlopen(URL, None, 1000).read()
parts = response.split(':')
f = parts[0]
r = parts[1]
c = parts[2]

vim.command("edit %s" % (f))
vim.command("normal %sG%s|" % (r, c))

EOF

  let &shm=orig_shortmess
  let &cmdheight = orig_cmdheight
  let &scrolloff = orig_scrolloff
endfunc


command! BetterScalaJump2 :call s:BetterJump()
