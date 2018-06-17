" =============================================================================
" Filename:    autoload\job.vim
" Author:      luzhlon
" Date:        2018-06-16
" Description: Wrap of job's function for neovim and vim8
" =============================================================================

call assert_true(has('nvim') || has('job') && has('patch-7.4.1590'))

if has('nvim')      " {{{
" start a job, and return the job_id.
fun! job#start(argv, ...) abort
    if a:0
        let job = jobstart(a:argv, a:1)
    else
        let job = jobstart(a:argv)
    endi
    return job
endf

fun! job#stop(id) abort
    return jobstop(a:id)
endf

fun! job#send(id, data) abort
    return jobsend(a:id, a:data)
endf

fun! job#status(id) abort
    let n = jobwait([a:id], 0)[0]
    if n == -1
        return 'run'
    elseif n == -2
        return 'fail'
    " elseif n == -3
    "     return 'invalid'
    else
        return 'dead'
    endif
endf

fun! job#info(id) abort
    let info.status = job#status(a:id)
    let info.job_id = a:id
    return info
endf
" }}}
else                " {{{
" start a job, and return the job_id.
fun! job#start(argv, ...) abort
    let cb = a:0 ? a:1 : {}
    let opts = {'mode': 'nl'}

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
    return job_start(a:argv, opts)
endf

fun! job#stop(jid) abort
    return job_stop(a:jid)
endf

func! job#send(jid, data) abort
    let ch = job_getchannel(a:jid)
    call ch_sendraw(ch, a:data . "\n")
endf

fun! job#status(jid) abort
    return job_status(a:jid)
endf

fun! job#info(jid) abort
    return job_info(a:jid)
endf
endif
" }}}
