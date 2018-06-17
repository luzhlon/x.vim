" =============================================================================
" Filename:    autoload\viml.vim
" Author:      luzhlon
" Date:        2018-04-02
" Description: Some utilities for VimL
" =============================================================================

" Set list index with auto fill the gap
fun! viml#set(l, i, v)
    let off = a:i + 1 - len(l)
    if off > 0
        let a:l += repeat([v:null], off)
    else
        let a:l[i] = a:v
    endif
endf

" Get string before the cursor, [or and after the cursor]
fun! viml#curstr(...)
    let c = col('.')
    let n = c - 1
    let l = getline('.')
    let f = strpart(l, 0, n)
    return a:0 ? [f, strpart(l, n)] : f
endf

" Get the process's path of current GUI window
fun! viml#guipath()
    if has('nvim')
        " TODO:
        return 'nvim-qt'
    else
        return v:progpath
    endif
endf

fun! viml#echo(...)
    for x in a:000
        echon x ''
    endfor
    echo ''
endf

fun! viml#echohl(hl, ...)
    exe 'echoh' a:hl
    for x in a:000
        echon x ''
    endfor
    echohl
endf

fun! viml#wildfilter(l, p)
    let ret = filter(copy(a:l), {->v:val =~ a:p})
    call sort(ret, {a,b->match(a, a:p) - match(b, a:p)})
    return ret
endf

fun! viml#getchar()
    let ch = getchar()
    return type(ch) == v:t_number ? nr2char(ch): ch
endf

if has('nvim') " {{{
    fun! viml#bufline(nr, l, t)
        if type(a:t) == v:t_list
            return nvim_buf_set_lines(
                        \ a:nr,
                        \ a:l - 1,
                        \ a:l + len(a:t) - 1,
                        \ 0, a:t)
        else
            return nvim_buf_set_lines(
                        \ a:nr, a:l - 1,
                        \ a:l, 0, [a:t])
        endif
    endf

    fun! viml#buflines(nr, lines)
        let lncnt = nvim_buf_line_count(a:nr)
        call nvim_buf_set_lines(a:nr, 0, lncnt, 0, a:lines)
    endf

    fun! viml#hlline(bnr, id, ln, hl)
        call nvim_buf_add_highlight(
                    \ a:bnr, a:id,
                    \ a:hl, a:ln - 1, 0, -1)
    endf

    fun! viml#hlclear(bnr, id, ...)
        let b = a:0 > 0 ? a:1 : 0
        let e = a:0 > 1 ? a:2 : -1
        return nvim_buf_clear_highlight(a:bnr, a:id, b, e)
    endf
" }}}
else " {{{
    fun! viml#bufline(nr, l, t)
        return setbufline(a:nr, a:l, a:t)
    endf
endif
" }}}

" Get buffer options(list) or set options(dict)
fun! viml#bufvars(nr, opts)
    let arg = a:opts
    if type(arg) == v:t_list
        return map(copy(arg), {i,v->getbufvar(a:nr, v)})
    elseif type(arg) == v:t_dict
        for [k, v] in items(arg)
            call setbufvar(a:nr, k, v)
        endfor
    else
        throw 'Error argument'
    endif
endf

" cexpr ...
fun! viml#cexpr(expr)
    cexpr a:expr
endf

fun! viml#hex(val)
    return printf('%08X', a:val)
endf
