local map = vim.keymap.set

map('i', 'jj', '<ESC>', {noremap = true, silent = true})
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- -- <leader>fp でパス入力プロンプトを出して、そのディレクトリを起点にファイル検索
-- vim.keymap.set("n", "<leader>fp", function()
--   -- ユーザーにパスを入力させる（空ならカレントディレクトリ）
--   local input_path = vim.fn.input("Search path: ", vim.fn.getcwd(), "dir")
-- 
--   -- 空入力ならキャンセル
--   if input_path == "" then
--     print("Canceled.")
--     return
--   end
-- 
--   -- Telescope をそのパスで起動
--   require("telescope.builtin").find_files({
--     cwd = vim.fn.expand(input_path) -- ~ や相対パスも解決
--   })
-- end, { desc = "Find files in specified path" })
