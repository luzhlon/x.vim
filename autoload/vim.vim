" =============================================================================
" Filename:    autoload\vim.vim
" Author:      luzhlon
" Date:        2018-04-02
" Description: Some enhanced utilities for vim
" =============================================================================

" Split current window with correct direction intelligently
fun! vim#split(...)
    let width = winwidth(0) * 1.0 / &columns
    let height = winheight(0) * 1.0 / &lines
    let vert = width > height
    exe a:0 ? (vert ? 'vert ' : '') . a:1 : (vert ? 'winc v': 'winc s')
endf

" Goto the buf's window if it is exists and return 1
fun! vim#gotowin(buf, ...)
    let nr = bufnr(a:buf)
    for tnr in range(1, tabpagenr('$'))
        if index(tabpagebuflist(tnr), nr) >= 0
            exe tnr 'tabn'
            return win_gotoid(bufwinid(a:buf))
        endif
    endfor
    " a:1 = edit | tabedit
    if a:0 | exe a:1 a:buf | endif
endf

" Close current buffer and window
fun! vim#close()
    setl bh=wipe | close
endf

" Close file in current buffer without close the window
fun! vim#closefile()
    try
        if &bt=='nofile' && 2 == confirm(
                    \ 'Not a file, continue quit?',
                    \ "&Yes\ n&No", 2, "Warning")
            return
        elseif &bt == 'terminal' && has('nvim')
            set bh=wipe
            call jobclose(b:terminal_job_id)
        endif
        let curbuf = bufnr('%')
        let lastbuf = bufnr('#')
        exe bufexists(lastbuf) && empty(getbufvar(lastbuf, '&bt')) ? 'b!#': 'bnext'
        exe 'confirm' curbuf 'bw'
    catch
        " echoe v:errmsg
    endt
endf

" Start a scrath
fun! vim#scratch()
    ene!
    setl bt=nofile bh=wipe
endf

" Add a quickfix expression with correct encoding
fun! vim#cadde(expr) abort
    caddexpr has('win32') ? iconv(a:expr, 'gbk', 'utf-8'): a:expr
endf

" Add quickfix file with correct encoding
fun! vim#cfile(file) abort
    call vim#cadde(join(readfile(a:file), "\n"))
endf

" Record log by echom
fun! vim#log(...)
    echom join(a:000)
endf

fun! s:filter(pat)
    let text = strpart(getcmdline(), 0, getcmdpos()-1)
    let text = substitute(text, a:pat, '', 'g')
    call feedkeys("\<c-u>", 'n')
    call feedkeys(text, 'n')
endf

fun! vim#inputfilter(prom, pat)
    let t = timer_start(10, {_->s:filter(a:pat)}, {'repeat':-1})
    let str = input(a:prom)
    call timer_stop(t)
    return str
endf
