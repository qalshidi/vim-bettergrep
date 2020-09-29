" vim-bettergrep
" Maintainer: Qusai Al Shidi
" Email:      me@qalshidi.science
" Website:    https://github.com/qalshidi/vim-bettergrep

if exists('g:bettergrep_loaded')
  finish
endif
let g:bettergrep_loaded = 1

" Options
if !exists('g:bettergrep_no_mappings')
  let g:bettergrep_no_mappings = 0
endif
if !exists('g:bettergrep_no_abbrev')
  let g:bettergrep_no_abbrev = 0
endif

" Commands
command! -nargs=+ -complete=file_in_path -bar Grep     call bettergrep#Grep('c', <f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep    call bettergrep#Grep('l', <f-args>)
command! -nargs=+ -complete=file_in_path -bar Grepadd  call bettergrep#Grep('ca', <f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrepadd call bettergrep#Grep('la', <f-args>)

" Mappings
if !g:bettergrep_no_mappings
  nnoremap <C-g> :Grep 
endif

if !g:bettergrep_no_abbrev
  cnoreabbrev <expr> grep     (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
  cnoreabbrev <expr> lgrep    (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'
  cnoreabbrev <expr> grepadd  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grepadd'  : 'grepadd'
  cnoreabbrev <expr> lgrepadd (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrepadd' : 'lgrepadd'
endif

" vim: et sts=2 sw=2 foldmethod=marker
