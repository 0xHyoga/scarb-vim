"IMPORTANT - Autosaves on every file update
autocmd TextChanged,TextChangedI * update

if exists("current_compiler")
  finish
endif

let current_compiler = "scarb build"

setlocal makeprg=scarb\ build

setlocal errorformat=%f\|%l\ col\ %c\|%m

augroup quickfix
  autocmd!
  autocmd QuickFixCmdPost make nested vertical botright copen 77
augroup END

set formatprg=scarb\ fmt

" Map Ctrl-y to run the 'scarb fmt' command without displaying the warning
nnoremap <C-y> :silent! %!scarb fmt<CR>


