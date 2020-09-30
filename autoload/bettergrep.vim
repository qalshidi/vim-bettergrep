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

if exists("*jobstart")                " NeoVim async method

  function! bettergrep#Grep(cmd, ...) abort
    
    if exists('s:grep_job')
      call jobstop(s:grep_job)
      unlet! s:grep_job
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

    let grep_cmd = split(g:bettergrepprg) + [expandcmd(join(a:000, ' '))]
    let s:grep_job = jobstart(grep_cmd, s:callbacks)
  endfunction

elseif !exists('*expandcmd')          " Vim 7 support - regular blocking

  function! bettergrep#Grep(cmd, ...) abort
    let expandedcmd = map(copy(a:000), 'expand(v:val)')     " Substitute wildcards
    execute a:cmd . " " . "system(join([g:bettergrepprg] + [join(expandedcmd, ' ')], ' '))"
  endfunction

else                                  " regular blocking method

  " Thanks to RomainL's gist
  " https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3

  function! bettergrep#Grep(cmd, ...) abort
    execute a:cmd . " " . "system(join([g:bettergrepprg] + [expandcmd(join(a:000, ' '))], ' '))"
  endfunction

endif

" vim: et sts=2 sw=2 foldmethod=marker
