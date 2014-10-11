if get(g:, 'loaded_ctrlp_cdnjs', 0)
  finish
endif
let g:loaded_ctrlp_cdnjs = 1

if !exists('g:ctrlp_cdnjs_protocol')
  let g:ctrlp_cdnjs_protocol = 1
endif
if !exists('g:ctrlp_cdnjs_script_type')
  let g:ctrlp_cdnjs_script_type = 1
endif

let s:protocol = [
\   ['protocol-less', ''      ],
\   ['http',          'http:' ],
\   ['https',         'https:'],
\]

let s:cdnjs_var = {
\  'init':   'ctrlp#cdnjs#init()',
\  'enter':  'ctrlp#cdnjs#enter()',
\  'exit':   'ctrlp#cdnjs#exit()',
\  'accept': 'ctrlp#cdnjs#accept',
\  'lname':  'cdnjs',
\  'sname':  'cdnjs',
\  'type':   'line',
\  'sort':   0,
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:cdnjs_var)
else
  let g:ctrlp_ext_vars = [s:cdnjs_var]
endif

function! s:compare_libname(lib1, lib2)
  return a:lib1.name ==? a:lib2.name ? 0 : a:lib1.name >? a:lib2.name ? 1 : -1
endfunction

function! ctrlp#cdnjs#init()
  let res = webapi#http#get('http://api.cdnjs.com/libraries', {'fields': 'version'})
  let libraries = webapi#json#decode(res.content)

  let s:list = sort(copy(libraries.results), 's:compare_libname')
  return map(copy(s:list), 'printf("%s (v%s)", v:val.name, v:val.version)')
endfunc

function! ctrlp#cdnjs#accept(mode, str)
  if a:mode == 'h'
    let g:ctrlp_cdnjs_protocol = (g:ctrlp_cdnjs_protocol + 1) % len(s:protocol)
    echo s:protocol[g:ctrlp_cdnjs_protocol][0]
    return
  endif

  let library = filter(copy(s:list), 'v:val.name == split(a:str)[0]')[0]
  call ctrlp#exit()

  let url = substitute(library.latest, '^http:', s:protocol[g:ctrlp_cdnjs_protocol][1], '')
  if a:mode == 't'
    if g:ctrlp_cdnjs_script_type
      let attr = printf('type="text/javascript" src="%s"', url)
    else
      let attr = printf('src="%s"', url)
    endif
    let url = printf('<script %s></script>', attr)

    call append(line('.'), url)
    let curpos     = copy(s:curpos)
    let curpos[1] += 1
    call setpos('.', curpos)
  else
    let line       = getline('.')
    let pos        = s:curpos[2] - 1
    let line       = line[: pos-1] . url . line[pos :]
    call setline('.', line)

    let curpos     = copy(s:curpos)
    let curpos[2] += len(url)
    call setpos('.', curpos)
  endif
endfunction

function! ctrlp#cdnjs#exit()
  if exists('s:list')
    unlet! s:list
  endif
endfunction

function! ctrlp#cdnjs#enter()
  let s:curpos = getpos('.')
endfunction

let s:id = ctrlp#getvar('g:ctrlp_builtins') + len(g:ctrlp_ext_vars)
function! ctrlp#cdnjs#id()
  return s:id
endfunction
