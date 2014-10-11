ctrlp-cdnjs
===========

CtrlP extension for `cdnjs.com`.
Select and insert the library URL/tag.

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

`<C-v>` opens the library's page on the cdnjs.com.
This function requires open-browser.vim
(see: https://github.com/tyru/open-browser.vim)

`<C-s>`, `<C-x>`, `<C-CR>` rotate URL's scheme.

    http -> https -> scheme-less -> http -> ...

Variables
---------

`g:ctrlp_cdnjs_scheme` is current scheme. (default=1)

    0 = scheme-less (protocol relative)
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

`g:ctrlp_cdnjs_indent_tag` is auto indent flag. (default=1)
If this value is 1, the inserted tag is indented automatically.

Requirements
------------

- [webapi-vim](https://github.com/mattn/webapi-vim)
- [open-browser.vim](https://github.com/tyru/open-browser.vim) (optional)

ToDo
----

- Select version
- Multiple asset files
- Multiple select

Thanks
------

- [kien](https://github.com/kien) - the author of ctrlp.vim
- [mattn](https://github.com/mattn) - the author of webapi-vim
- [tyru](https://github.com/tyru) - the author of open-browser.vim

License
-------

MIT

Author
------

Yuki (a.k.a pasela)
