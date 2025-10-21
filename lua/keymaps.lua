local map = vim.keymap.set

map('i', 'jj', '<Esc>', {noremap = true, silent = true})
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', 'gl', vim.diagnostic.open_float, {silent = true})
