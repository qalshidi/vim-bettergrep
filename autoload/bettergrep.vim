" vim-bettergrep
" Maintainer: Qusai Al Shidi

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

  function! bettergrep#Grep(listing, ...)
    
    function! s:on_out_c(job_id, data, event) dict
      cgetexpr join(a:data, "\n")
    endfunction

    function! s:on_out_ca(job_id, data, event) dict
      caddexpr join(a:data, "\n")
    endfunction

    function! s:on_out_la(job_id, data, event) dict
      laddexpr join(a:data, "\n")
    endfunction

    function! s:on_out_l(job_id, data, event) dict
      lgetexpr join(a:data, "\n")
    endfunction

    function! s:on_error(job_id, data, event) dict
      echo 'bettergrep E: ' . join(a:data, "\n")
    endfunction

    let s:callbacks = {
    \ 'stdout_buffered': 1,
    \ 'on_stderr': function('s:on_error'),
    \ }

    " Decide on qf list or location list
    if a:listing == 'c'
      let s:callbacks.on_stdout = function('s:on_out_c')
    elseif a:listing == 'l'
      let s:callbacks.on_stdout = function('s:on_out_l')
    elseif a:listing == 'la'
      let s:callbacks.on_stdout = function('s:on_out_la')
    elseif a:listing == 'ca'
      let s:callbacks.on_stdout = function('s:on_out_ca')
    else
      echo "bettergrep E: Grep() first arg must be 'c', 'l', 'ca', or 'la'"
    endif

    let s:grep_cmd = split(g:bettergrepprg) + [expandcmd(join(a:000, ' '))]
    let grep_job = jobstart(s:grep_cmd, s:callbacks)
  endfunction

else                                  " regular blocking method

  " Thanks to RomainL's gist
  " https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3

  function! bettergrep#Grep(listing, ...)
    if a:listing == 'c'
      cgetexpr system(join([g:bettergrepprg] + [expandcmd(join(a:000, ' '))], ' '))
    elseif a:listing == 'l'
      lgetexpr system(join([g:bettergrepprg] + [expandcmd(join(a:000, ' '))], ' '))
    elseif a:listing == 'la'
      laddexpr system(join([g:bettergrepprg] + [expandcmd(join(a:000, ' '))], ' '))
    elseif a:listing == 'ca'
      caddexpr system(join([g:bettergrepprg] + [expandcmd(join(a:000, ' '))], ' '))
    else
      echo "bettergrep E: Grep() first arg must be 'c', 'l', 'ca', or 'la'"
    endif
  endfunction

endif

" vim: et sts=2 sw=2 foldmethod=marker
