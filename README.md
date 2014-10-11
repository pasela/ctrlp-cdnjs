ctrlp-cdnjs
===========

CtrlP extension for `cdnjs.com`.
Select and insert the library URL/script tag.

Usage
-----

```vim
:CtrlPCdnJs
```

If may add map into your vimrc like below: >

```vim
noremap <leader>js :<c-u>CtrlPCdnJs<cr>
```

In CtrlP window,

`<CR>` inserts the URL.
`<C-t>` inserts the script tag.

`<C-s>`, `<C-x>`, `<C-CR>` rotate URL's protocol.

    http -> https -> protocol-less -> http -> ...

Variables
---------

`g:ctrlp_cdnjs_protocol` is current protocol. (default=1)

    0 = protocol-less
    1 = http
    2 = https

`g:ctrlp_cdnjs_script_tag` is a template of script tag.
`${url}` is replaced with the URL.

    default:
    <script type="text/javascript" src="${url}"></script>

`g:ctrlp_cdnjs_css_link_tag` is a template of link tag.
`${url}` is replaced with the URL.

    default:
    <link rel="stylesheet" type="text/css" href="${url}">

Requirements
------------

- [webapi](https://github.com/mattn/webapi-vim)

ToDo
----

- Select version
- Multiple files

License
-------

MIT

Author
------

Yuki (a.k.a pasela)
