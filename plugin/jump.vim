function! s:MarkDirty()

python << EOF
import vim, urllib2
cur_file = vim.current.buffer.name
URL_STR = "http://localhost:8081/dirty?file=%s"
URL = URL_STR % (cur_file)
try:
  response = urllib2.urlopen(URL, None, 1000).read()
except:
  print "failed to inform server about dirty file"
#print response
#print URL
EOF

endfunction

augroup sjump_save_hook
autocmd!
autocmd BufWritePost *.java,*.scala call s:MarkDirty()
augroup end

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
# column has to be one based
col = pos[1] + 1

URL_STR = "http://localhost:8081/jump?file=%s&symbol=%s&row=%s&col=%s"

URL = URL_STR % (cur_file, cur_word, row, col)

print URL

response = urllib2.urlopen(URL, None, 1000).read()
print response
results = response.split(',')
if len(results) == 1:
  parts = response.split(':')
  f = parts[0]
  r = parts[1]
  c = parts[2]
  vim.command("edit %s" % (f))
  vim.command("call cursor(%s,%s)" % (r, c))
elif len(results) > 1:
  matches = []
  for match in results:
    parts = match.split(':')
    f = parts[0]
    r = parts[1]
    c = parts[2]
    match_str = "{ 'filename' : '%s', 'lnum' : '%s', 'col' : '%s' }" % (f, r, c)
    print match_str
    matches.append(match_str)
  vim.command('call setqflist([' + ', '.join(matches) + '])')
  vim.command('copen %d' % (len(matches) + 1))
  vim.command("execute \"nnoremap <buffer> <silent> <CR> <CR>:cclose<CR>\"")
  vim.command("execute \"nnoremap <buffer> <silent> q :cclose<CR>\"")
  
else:
  print 'no matches found'

EOF

  let &shm=orig_shortmess
  let &cmdheight = orig_cmdheight
  let &scrolloff = orig_scrolloff
endfunc

command! ScalaJump :call s:BetterJump()
