import vim, os, urllib2, socket

# This actually sets the read timeout
socket.setdefaulttimeout(5)

def log(msg):
  if int(vim.eval("s:debug")) == 1:
    print msg

def read_nth_line_from_file(filename, line_number): 
  fp = open(filename)
  l = ""
  for i, line in enumerate(fp):
    if i == line_number - 1:
      l = line
  fp.close()
  return l

def gen_qf_entry(file, line, row, col):
  cur_cwd = os.getcwd()
  filepath = os.path.relpath(file, cur_cwd)
  pat = "{ 'filename' : '%s', 'text' : '%s', 'lnum' : '%s', 'col' : '%s' }"
  return pat % (filepath, line, row, col)

def run_cmd():
  cur_word = vim.eval("expand('<cword>')")
  pos = vim.current.window.cursor
  cur_file = vim.current.buffer.name
  row = pos[0]
  col = pos[1] + 1 # column has to be one based

  URL_STR = "http://localhost:8081/%s?file=%s&symbol=%s&row=%s&col=%s"
  URL = URL_STR % (vim.eval("a:cmd"), cur_file, cur_word, row, col)
  log(URL)


  try:
    response = urllib2.urlopen(URL, None, 1).read()
    #log(response)
    results = response.split(',')
    if len(results) == 1:
      f, r, c = response.split(':')
      vim.command("edit %s" % (f))
      vim.command("call cursor(%s,%s)" % (r, c))
    elif len(results) > 1:
      matches = []
      for match in results:
        f, r, c = match.split(':')
        line = read_nth_line_from_file(f, int(r))
        match_str =  gen_qf_entry(f, line, r, c)
        matches.append(match_str)
      window_height = min(len(matches) + 2, 10)
      vim.command('call setqflist([' + ', '.join(matches) + '])')
      vim.command('copen %d' % (window_height))
      vim.command("execute \"nnoremap <buffer> <silent> <CR> <CR>:cclose<CR>\"")
      vim.command("execute \"nnoremap <buffer> <silent> q :cclose<CR>\"")
      
    else:
      log('no matches found')
  except Exception as inst:
    log(inst)
    log("couldn't connect to scajump, make sure the server is running")

def mark_dirty():
  cur_file = vim.current.buffer.name
  URL_STR = "http://localhost:8081/dirty?file=%s"
  URL = URL_STR % (cur_file)
  try:
    response = urllib2.urlopen(URL, None, 1).read()
  except Exception:
    log("failed to inform server about dirty file")
