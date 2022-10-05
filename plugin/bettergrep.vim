" vim-bettergrep
" Maintainer: Qusai Al Shidi
" Email:      me@qalshidi.science
" Website:    https://github.com/qalshidi/vim-bettergrep
" License:    MIT License (c) 2020

if exists('g:loaded_bettergrep') || &cp
  finish
endif
let g:loaded_bettergrep = 1

" Commands
command! -nargs=+ -complete=file_in_path -bar Grep     call bettergrep#Grep('cgetexpr', escape(<q-args>, '\'))
command! -nargs=+ -complete=file_in_path -bar LGrep    call bettergrep#Grep('lgetexpr', escape(<q-args>, '\'))
command! -nargs=+ -complete=file_in_path -bar Grepadd  call bettergrep#Grep('caddexpr', escape(<q-args>, '\'))
command! -nargs=+ -complete=file_in_path -bar LGrepadd call bettergrep#Grep('laddexpr', escape(<q-args>, '\'))

" Mappings
if !get(g:, 'bettergrep_no_mappings', 0)
  nnoremap <C-g> :Grep 
  nnoremap <M-g> :Grepadd 
endif

" Abbreviations
if !get(g:, 'bettergrep_no_abbrev', 0)
  cnoreabbrev <expr> gr        (getcmdtype() ==# ':' && getcmdline() ==# 'gr')  ? 'Grep'  : 'gr'
  cnoreabbrev <expr> lgr       (getcmdtype() ==# ':' && getcmdline() ==# 'lgr') ? 'LGrep' : 'lgr'
  cnoreabbrev <expr> gre       (getcmdtype() ==# ':' && getcmdline() ==# 'gre')  ? 'Grep'  : 'gre'
  cnoreabbrev <expr> lgre      (getcmdtype() ==# ':' && getcmdline() ==# 'lgre') ? 'LGrep' : 'lgre'
  cnoreabbrev <expr> grep      (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
  cnoreabbrev <expr> lgrep     (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'
  cnoreabbrev <expr> grepa     (getcmdtype() ==# ':' && getcmdline() ==# 'grepa')  ? 'Grepadd'  : 'grepa'
  cnoreabbrev <expr> lgrepa    (getcmdtype() ==# ':' && getcmdline() ==# 'lgrepa') ? 'LGrepadd' : 'lgrepa'
  cnoreabbrev <expr> grepad    (getcmdtype() ==# ':' && getcmdline() ==# 'grepad')  ? 'Grepadd'  : 'grepad'
  cnoreabbrev <expr> lgrepad   (getcmdtype() ==# ':' && getcmdline() ==# 'lgrepad') ? 'LGrepadd' : 'lgrepad'
  cnoreabbrev <expr> grepadd   (getcmdtype() ==# ':' && getcmdline() ==# 'grepadd')  ? 'Grepadd'  : 'grepadd'
  cnoreabbrev <expr> lgrepadd  (getcmdtype() ==# ':' && getcmdline() ==# 'lgrepadd') ? 'LGrepadd' : 'lgrepadd'
endif

" vim: et sts=2 sw=2 foldmethod=marker
