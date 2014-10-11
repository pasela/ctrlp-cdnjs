if get(g:, 'loaded_ctrlp_cdnjs', 0)
  finish
endif
let g:loaded_ctrlp_cdnjs = 1

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
  let library = filter(copy(s:list), 'v:val.name == split(a:str)[0]')[0]
  call ctrlp#exit()

  let url = library.latest
  if a:mode == 't'
    let url = printf('<script type="text/javascript" src="%s"></script>', url)
  endif

  let reg_x = getreg('x', 1, 1)
  let reg_x_type = getregtype('x')
  call setreg('x', url, a:mode == 't' ? 'l' : 'c')
  execute 'normal! "x' . (col('$') - col('.') <= 1 ? 'p' : 'P')
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
