" =============================================================================
" Filename:    autoload\term.vim
" Author:      luzhlon
" Date:        2018-04-07
" Description: Wrap of terminal's function for neovim and vim8
" =============================================================================

call assert_true(has('terminal'))

if has('nvim')      " {{{
fun! term#open(argv, ...) abort
    ene
    let job = call('termopen', [a:argv] + a:000)
    norm! G
    return job
endf

fun! term#alive(...)
    let jobid = a:0 ? a:1 : b:terminal_job_id
    return jobpid(jobid) ? 1: 0
endf
" }}}
else                " {{{
fun! term#open(argv, ...) abort
    let opts = extend(a:0 ? a:1 : {}, {'curwin': 1})
    if has_key(opts, 'on_stdout')
        fun! opts.out_cb(jid, data) dict
            call self.on_stdout(a:jid, [a:data], 'stdout')
        endf
    endif
    if has_key(opts, 'on_stderr')
        fun! opts.err_cb(jid, data) dict
            call self.on_stderr(a:jid, [a:data], 'stderr')
        endf
    endif
    if has_key(opts, 'on_exit')
        fun! opts.exit_cb(jid, data) dict
            call self.on_exit(a:jid, [a:data], 'exit')
        endf
    endif
    let job = term_start(a:argv, opts)
    norm! G
    return job
endf

fun! term#alive(...)
    return &modified
endf
endif
" }}}
