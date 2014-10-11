if get(g:, 'loaded_ctrlp_cdnjs', 0)
  finish
endif
let g:loaded_ctrlp_cdnjs = 1

if !exists('g:ctrlp_cdnjs_protocol')
  let g:ctrlp_cdnjs_protocol = 1
endif

let s:protocol = [
\   ['protocol-less', ''      ],
\   ['http',          'http:' ],
\   ['https',         'https:'],
\]

let s:cdnjs_var = {
\  'init':   'ctrlp#cdnjs#init()',
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

  let reg_x = getreg('x', 1, 1)
  let reg_x_type = getregtype('x')

  if a:mode == 't'
    let url = printf('<script type="text/javascript" src="%s"></script>', url)
    call setreg('x', url, 'l')
    execute 'normal! "xp'
  else
    call setreg('x', url, 'c')
    execute 'normal! "x' . (col('$') - col('.') <= 1 ? 'p' : 'P')
  endif

  call setreg('x', reg_x, reg_x_type)
endfunction

function! ctrlp#cdnjs#exit()
  if exists('s:list')
    unlet! s:list
  endif
endfunction

let s:id = ctrlp#getvar('g:ctrlp_builtins') + len(g:ctrlp_ext_vars)
function! ctrlp#cdnjs#id()
  return s:id
endfunction
