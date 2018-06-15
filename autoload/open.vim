" =============================================================================
" Filename:    autoload\open.vim
" Author:      luzhlon
" Date:        2018-06-14 <
" Description: Open all things
" =============================================================================

if has('win32')
    let s:env = 'windows'
elseif executable('cmd.exe')
    let s:env = 'wsl'
else
    let s:env = 'unix'
endif

" Open a file as shell, or open URL in browser
fun! open#(f)
    " let f = a:f =~ '^\(https\?\)' ? a:f: s:shellescape(a:f)
    if s:env == 'windows' || s:env == 'wsl'
        call job#start(['cmd', '/c', 'rundll32.exe',
                  \ 'url.dll,FileProtocolHandler', a:f])
    else
        call job#start(['xdg-open', a:f])
    endif
endf

" Open current buffer's file in explorer
fun! open#cur_file()
    let file = expand('<cfile>')
    if file =~ '^\.'
        let file = expand('%:h') . '/' . file
        let file = simplify(file)
    endif
    call open#(file)
endf

" Open bash program
fun! open#bash()
    let t = executable('open-wsl') ? 'open-wsl': 'bash'
    if s:env == 'windows'
        sil exe '!start' t
    elseif s:env = 'wsl'
        sil exe '!cmd.exe /c start' t
    else
        sil !gnome-terminal -e bash
    endif
endf

" Open powershell program
fun! open#powershell()
    if s:env == 'windows'
        sil !start powershell
    elseif s:env = 'wsl'
        sil !cmd.exe /c start powershell
    endif
endf

" Open cmd program
fun! open#cmd()
    if s:env == 'windows'
        sil !start cmd
    elseif s:env = 'wsl'
        sil !cmd.exe /c start cmd
    endif
endf

" Open current directory in explorer
fun! open#curdir()
    if s:env ==  'windows'
        sil !start explorer "%:p:h"
    elseif s:env == 'wsl'
        sil !cmd.exe /c start explorer .
    else
    endif
endf

" fun! editor#reopen_file()
"     let file = expand('%:p')
"     confirm bw
"     exe 'edit' file
" endf
fun! open#reopen_curfile()
    if empty(&bt)
        call open#reopen(expand('%:p'))
    else
        echoerr 'Current buffer is not a file'
    endif
endf

" Reopen the (n)vim instance
fun! open#reopen(...)
    let path = viml#guipath()
    let cmd = [path] + copy(a:000)
    confirm wa
    call job#start(['cmd.exe', '/c'] + cmd)
    qall
endf

" Open URL in browser under the cursor
fun! open#url_under_cursor()
    let i = col('.')
    let line = getline('.')
    while i >= 0
        let url = matchstr(line, '^https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z0-9][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*', i)
        if len(url)
            call open#(url)
            return 1
        endif
        let i -= 1
    endw
endf

" Open files with administrator's privilige
fun! open#with_admin(files)
    let cmd = [v:progpath]
    if type(a:files) == v:t_list
        let cmd += a:files
    else
        call add(cmd, a:files)
    endif
    return call(function('sys#sh#admin'), cmd)
endf

" Show the position of a file in explorer
fun! open#explorer(file)
    let cmd = printf('!start explorer /select,"%s"', a:file)
    " echo cmd | call getchar()
    sil! exe cmd
endf
