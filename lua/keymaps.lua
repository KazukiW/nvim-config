local map = vim.keymap.set
local builtin = require('telescope.builtin')

map('i', 'jj', '<ESC>', {noremap = true, silent = true})
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Fine buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
