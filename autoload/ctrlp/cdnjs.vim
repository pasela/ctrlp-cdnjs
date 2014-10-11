if get(g:, 'loaded_ctrlp_cdnjs', 0)
  finish
endif
let g:loaded_ctrlp_cdnjs = 1

if !exists('g:ctrlp_cdnjs_protocol')
  let g:ctrlp_cdnjs_protocol = 1
endif
if !exists('g:ctrlp_cdnjs_script_tag')
  let g:ctrlp_cdnjs_script_tag = '<script type="text/javascript" src="${url}"></script>'
endif
if !exists('g:ctrlp_cdnjs_css_link_tag')
  let g:ctrlp_cdnjs_css_link_tag = '<link rel="stylesheet" type="text/css" href="${url}">'
endif
if !exists('g:ctrlp_cdnjs_indent_tag')
  let g:ctrlp_cdnjs_indent_tag = 1
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

function! s:create_script_tag(url)
  return substitute(g:ctrlp_cdnjs_script_tag, '\${url}', a:url, 'g')
endfunction

function! s:create_css_link_tag(url)
  return substitute(g:ctrlp_cdnjs_css_link_tag, '\${url}', a:url, 'g')
endfunction

function! s:get_ext(url)
  return fnamemodify(a:url, ':e')
endfunction

function! s:insert_url(url)
  let line       = getline('.')
  let pos        = s:curpos[2] - 1
  let line       = line[: pos-1] . a:url . line[pos :]
  call setline('.', line)

  let curpos     = copy(s:curpos)
  let curpos[2] += len(a:url)
  call setpos('.', curpos)
endfunction

function! s:insert_tag(url)
  let ext = s:get_ext(a:url)
  if ext ==? 'js'
    let tag = s:create_script_tag(a:url)
  elseif ext ==? 'css'
    let tag = s:create_css_link_tag(a:url)
  endif

  call append(line('.'), tag)
  let curpos     = copy(s:curpos)
  let curpos[1] += 1
  call setpos('.', curpos)
  if g:ctrlp_cdnjs_indent_tag
    normal ==
  endif
endfunction

function! s:open_library_page(library)
  try
    let url = 'https://cdnjs.com/libraries/' . a:library.name
    call openbrowser#open(url)
  catch
    echohl ErrorMsg
    echo "openbrowser not found"
    echo "See: https://github.com/tyru/open-browser.vim"
    echohl None
  endtry
endfunction

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
    call s:insert_tag(url)
  elseif a:mode == 'v'
    call s:open_library_page(library)
  else
    call s:insert_url(url)
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
