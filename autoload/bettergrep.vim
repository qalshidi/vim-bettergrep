" vim-bettergrep
" Maintainer: Qusai Al Shidi
" Email:      me@qalshidi.science
" Website:    https://github.com/qalshidi/vim-bettergrep

" decide on grep program {{{
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
" }}}

function! s:bettergrep_pre() abort
  " Side effects before grepping like quick fix autocmds {{{

  augroup s:qfopen
      autocmd!
      autocmd QuickFixCmdPost cgetexpr cwindow
      autocmd QuickFixCmdPost lgetexpr lwindow
  augroup end

  if exists('s:grep_job')

    if exists ('*jobstop')
      let job_to_kill = s:grep_job
      unlet! s:grep_job  " unlet first just incase
      call jobstop(job_to_kill)
    endif

    if exists('*job_stop')
      let job_to_kill = s:grep_job
      call job_stop(job_to_kill)
      unlet! s:grep_job
    endif

  endif

endfunction
" }}}

function! s:bettergrep_post() abort
  " Side effects after grepping like quick fix autocmd removal {{{

  augroup s:qfopen  " remove autocommands from user configuration after open
    autocmd!
  augroup end

  if exists('s:grep_job')
    unlet! s:grep_job
  endif

endfunction
" }}}

function! s:makecmd(args) abort
  " Make the command line to send to shell {{{
  let grep_cmd  = [g:bettergrepprg]
  let grep_cmd += map(copy(a:args), 'expand(v:val)')  " Substitute wildcards
  return join(grep_cmd, ' ')
endfunction
" }}}

" NeoVim async method {{{
if exists('*jobstart')

  function! bettergrep#Grep(cmd, ...) abort
    
    call s:bettergrep_pre()

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
      call s:bettergrep_post()
    endfunction

    let s:callbacks = {
    \ 'stdout_buffered': 1,
    \ 'on_stdout': function('s:on_out'),
    \ 'on_stderr': function('s:on_error'),
    \ 'on_exit':   function('s:on_exit')
    \ }

    let s:grep_job = jobstart(s:makecmd(a:000), s:callbacks)

  endfunction

" }}}
" Vim async method {{{
elseif exists('*job_start')

  function! bettergrep#Grep(cmd, ...) abort
    
    call s:bettergrep_post()

    let s:cmd = a:cmd
    let s:data = ''

    function! s:on_out(job_id, data) 
      let s:data .= a:data . "\n"
    endfunction

    function! s:on_error(job_id, data)
      if len(a:data) > 1
        echo 'bettergrep E: ' . join([a:data], "\n")
      endif
    endfunction

    function! s:on_exit(job_id, status)
      let job_to_kill = s:grep_job
      if len(s:data) > 1
        execute s:cmd . ' join([s:data], "\n")'
      endif
      call s:bettergrep_post()
      call job_stop(job_to_kill)
    endfunction

    let s:callbacks = {
    \ 'callback': function('s:on_out'),
    \ 'err_cb':   function('s:on_error'),
    \ 'exit_cb':  function('s:on_exit'),
    \ 'in_io':    'null'
    \ }

    let grep_cmd = s:makecmd(a:000)
    let cmd = split(&shell) + split(&shellcmdflag) + [grep_cmd]
    let s:grep_job = job_start(cmd, s:callbacks)

  endfunction

" }}}
" regular blocking method {{{
else

  " Thanks to RomainL's gist
  " https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3

  function! bettergrep#Grep(cmd, ...) abort
    call s:bettergrep_pre()
    execute a:cmd . " " . "system(s:makecmd(a:000))"
    call s:bettergrep_post()
  endfunction

endif
" }}}

" vim: et sts=2 sw=2 foldmethod=marker
