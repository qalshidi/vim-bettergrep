" vim-bettergrep
" Maintainer: Qusai Al Shidi
" Email:      me@qalshidi.science
" Website:    https://github.com/qalshidi/vim-bettergrep

" decide on grep program
if !exists('g:bettergrepprg')
  if executable('rg')
    let g:bettergrepprg = "rg --vimgrep"
  elseif executable('ag')
    let g:bettergrepprg = "ag --vimgrep"
  elseif executable('ack')
    let g:bettergrepprg = "ack -s -H --nopager --nocolor --nogroup --column"
  else
    let g:bettergrepprg = &grepprg
  endif
endif

if exists('*expandcmd')                 " Vim 7 and NeoVim 0.3.3 support

  function! s:makecmd(args) abort
    let grep_cmd  = [g:bettergrepprg]
    let grep_cmd += [expandcmd(join(a:args, ' '))]
    return join(grep_cmd, ' ')
  endfunction

else

  function! s:makecmd(args) abort
    let grep_cmd  = [g:bettergrepprg]
    let grep_cmd += map(copy(a:args), 'expand(v:val)')  " Substitute wildcards
    return join(grep_cmd, ' ')
  endfunction

endif

if exists("*jobstart")                " NeoVim async method

  function! bettergrep#Grep(cmd, ...) abort
    
    if exists('s:grep_job')
      let job_to_kill = s:grep_job
      unlet! s:grep_job  " unlet first just incase
      call jobstop(job_to_kill)
    endif

    let s:cmd = a:cmd

    function! s:on_out(job_id, data, event) dict
      execute s:cmd . ' join(a:data, "\n")'
    endfunction

    function! s:on_error(job_id, data, event) dict
      if len(a:data) > 1
        echo 'bettergrep E: ' . join(a:data, "\n")
      endif
    endfunction

    function! s:on_exit(job_id, data, event) dict
      unlet! s:grep_job
    endfunction

    let s:callbacks = {
    \ 'stdout_buffered': 1,
    \ 'on_stdout': function('s:on_out'),
    \ 'on_stderr': function('s:on_error'),
    \ 'on_exit':   function('s:on_exit')
    \ }

    let s:grep_job = jobstart(s:makecmd(a:000), s:callbacks)

  endfunction

else                                  " regular blocking method

  " Thanks to RomainL's gist
  " https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3

  function! bettergrep#Grep(cmd, ...) abort
    execute a:cmd . " " . "system(s:makecmd(a:000))"
  endfunction

endif

" vim: et sts=2 sw=2 foldmethod=marker
