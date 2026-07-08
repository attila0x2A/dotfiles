" TODO: Migrate to lua

" TODO: Configure cwindow population with fzf and multi file selection on
" :Files.
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <Leader>ff :Files<CR>
nnoremap <silent> <Leader>fb :Buffers<CR>
nnoremap <silent> <Leader>fl :Lines<CR>
nnoremap <silent> <Leader>fw :Windows<CR>
nnoremap <silent> <Leader>fj :Jumps<CR>
nnoremap <silent> <Leader>fh :History<CR>

command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, '--ignore=node_modules', fzf#vim#with_preview(), <bang>0)

autocmd CursorHold  <buffer> silent! lua vim.lsp.buf.document_highlight()
autocmd CursorHoldI <buffer> silent! lua vim.lsp.buf.document_highlight()
autocmd CursorMoved <buffer> silent! lua vim.lsp.buf.clear_references()


nnoremap <silent><Leader><Leader> :nohls \| CloseFloatingWindows<CR>:LTClearJumpHL<CR>
nnoremap Y y$
nnoremap <Leader>y% :let @+=@% \| echo getreg('+') <CR>
nnoremap <silent><Leader>q :ToggleQuickFix<CR>

nnoremap <Leader>ve :tab split $MYVIMRC<CR>
nnoremap <Leader>vs :source $MYVIMRC<CR>

nnoremap <Leader>gs :Git<CR>
nnoremap <Leader>gh :.GBrowse<CR>
vnoremap <Leader>gh :'<,'>GBrowse<CR>
nnoremap <Leader>gy :.GBrowse!<CR>
vnoremap <Leader>gy :'<,'>GBrowse!<CR>
nnoremap <Leader>gb :Git blame<CR>

nnoremap <Leader>rt :RustTest<CR>

" nnoremap <Leader>db :DapToggleBreakpoint<CR>
" nnoremap <Leader>do :DapStepOver<CR>
" nnoremap <Leader>di :DapStepInto<CR>
" nnoremap <Leader>dt :DapStepOut<CR>

nnoremap <Leader>dc :TContinue<CR>
nnoremap <Leader>dn :TNext<CR>
nnoremap <Leader>ds :TStep<CR>
nnoremap <Leader>df :TSendCommand finish<CR>

nnoremap <Leader>dp :TPrint <C-R>=expand('<cword>')<CR><CR>
nnoremap <Leader>db :TToggleBreak<CR>
nnoremap <Leader>dd :TDebug<CR>
nnoremap <Leader>dr :TRunFile<CR>
nnoremap <Leader>dt :TRun <C-R>=expand('%:t:r')<CR>::<C-R>=expand('<cword>')<CR><CR>

nnoremap <F5> :TContinue<CR>
nnoremap <F10> :TNext<CR>
nnoremap <F11> :TStep<CR>
nnoremap <F12> :TSendCommand finish<CR>

nnoremap <silent> <Leader>o :AerialToggle<CR>


nnoremap <Leader>sfi :setl foldmethod=indent<CR>
nnoremap <Leader>sfm :setl foldmethod=manual<CR>

cnoremap <C-A> <C-B>

nnoremap <silent> <leader>h :lua require('hop').hint_words()<CR>
nnoremap <silent> <leader>/ :HopPattern<CR>
" vnoremap <silent> <leader>h :lua require('hop').hint_words()<CR>
omap     <silent> h :HopWord<CR>


"    " COC setup
"    nmap <silent> gd <Plug>(coc-definition)
"    nmap <silent> gy <Plug>(coc-type-definition)
"    nmap <silent> gi <Plug>(coc-implementation)
"    nmap <silent> gr <Plug>(coc-references)
"    
"    vmap <leader>f  <Plug>(coc-format-selected)
"    
"    nmap <leader>r  <Plug>(coc-rename)
"    
"    nmap <silent> ge <Plug>(coc-diagnostic-next)
"    nmap <silent> gp <Plug>(coc-diagnostic-prev)
"    " Jump between diagnostics
"    " nmap <silent> <Leader>dn <Plug>(coc-diagnostic-next)
"    " nmap <silent> <Leader>dp <Plug>(coc-diagnostic-prev)
"    
"    
"    autocmd FileType typescript,json,php setl formatexpr=CocAction('formatSelected')
"    command! -nargs=0 Format :call CocActionAsync('format')
"    
"    " Use K to show documentation in preview window.
"    nnoremap <silent> K :call ShowDocumentation()<CR>
"    function! ShowDocumentation()
"      if CocAction('hasProvider', 'hover')
"        call CocActionAsync('doHover')
"      else
"        call feedkeys('K', 'in')
"      endif
"    endfunction
"    
"    " Automatically close outline.
"    autocmd BufEnter * call CheckOutline()
"    function! CheckOutline() abort
"      if &filetype ==# 'coctree' && winnr('$') == 1
"        if tabpagenr('$') != 1
"          close
"        else
"          bdelete
"        endif
"      endif
"    endfunction
"    
"    nnoremap <silent><nowait> <leader>o  :call ToggleOutline()<CR>
"    function! ToggleOutline() abort
"      let winid = coc#window#find('cocViewId', 'OUTLINE')
"      if winid == -1
"        call CocActionAsync('showOutline', 1)
"      else
"        call coc#window#close(winid)
"      endif
"    endfunction
