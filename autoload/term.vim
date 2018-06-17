" =============================================================================
" Filename:    autoload\term.vim
" Author:      luzhlon
" Date:        2018-04-07
" Description: Wrap of terminal's function for neovim and vim8
" =============================================================================

call assert_true(has('terminal'))

if has('nvim')      " {{{
fun! term#open(argv, ...) abort
    ene             " In new buffer start a terminal
    try
        let job = call('termopen', [a:argv] + a:000)
        norm! G
    catch
    endt
    return job
endf

fun! term#alive(...)
    let jobid = a:0 ? a:1 : b:terminal_job_id
    return jobpid(jobid) ? 1: 0
endf
" }}}
else                " {{{
fun! term#open(argv, ...) abort
    let cb = a:0 ? a:1 : {}
    let opts = {'curwin': 1}

    if has_key(cb, 'detach')
        let opts.stoponexit = ''
    endif
    if has_key(cb, 'on_stdout')
        let opts.out_cb = {jid, data->
            \ call(cb.on_stdout, [jid, [data], 'stdout'], cb)
        \ }
    endif
    if has_key(cb, 'on_stderr')
        let opts.err_cb = {jid, data->
            \ call(cb.on_stderr, [jid, [data], 'stderr'], cb)
        \ }
    endif
    if has_key(cb, 'on_exit')
        let opts.exit_cb = {jid, data->
            \ call(cb.on_exit, [jid, data, 'exit'], cb)
        \ }
    endif
    try
        let job = term_start(a:argv, opts)
        norm! G
    catch
    endt
    return job
endf

fun! term#alive(...)
    let job = term_getjob(a:0 ? a:1 : bufname('%'))
    return type(job) == v:t_job && job#status(job) == 'run'
endf
endif
" }}}
