" Reformat on save.
autocmd! BufWritePost *.rs silent! execute "!timeout 5 rustfmt <afile> 2>&1 >/dev/null" | redraw!
