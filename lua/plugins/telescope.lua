-- ~/.config/nvim/lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },

  config = function()
    local telescope = require("telescope")
    local actions   = require("telescope.actions")
    local builtin   = require("telescope.builtin")

    -- 外部コマンド存在チェック（has()ではなく executable() を使う）
    local function is_exec(cmd) return vim.fn.executable(cmd) == 1 end

    -- ---- ファイル列挙エンジン（fd 優先 → rg --files → OS の find）----
    local find_cmd
    if is_exec("fdfind") then
      -- Debian/Ubuntu ではパッケージ名が fdfind
      find_cmd = { "fdfind", "--type", "f", "--hidden", "--follow", "--exclude", ".git" }
    elseif is_exec("fd") then
      find_cmd = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" }
    elseif is_exec("rg") then
      find_cmd = { "rg", "--files", "--hidden", "--glob", "!.git/*" }
    else
      find_cmd = nil -- Telescope が OS の find にフォールバック
    end
--     print("find_cmd: ", vim.inspect(find_cmd))

    -- ---- 全文検索エンジン（rg があれば最適化。無ければ既定に委譲）----
    local vimgrep_args
    if is_exec("rg") then
      vimgrep_args = {
        "rg",
        "--color=never", "--no-heading", "--with-filename",
        "--line-number", "--column", "--smart-case",
        "--hidden", "--glob", "!.git/*",
      }
    else
      vimgrep_args = nil
    end
--     print("vimgrep_args: ", vim.inspect(vimgrep_args))

    telescope.setup({
      defaults = {
        vimgrep_arguments = vimgrep_args,
        file_ignore_patterns = { ".git/", "node_modules/", "dist/" },
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        mappings = {
          i = {
            ["<Esc>"] = actions.close,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = find_cmd,  -- fd / fdfind / rg / 既定 の順で自動切替
          follow = true,
          hidden = (find_cmd == nil), -- 既定 find へ落ちた時の保険（任意）
        },
        buffers    = { sort_mru = true, ignore_current_buffer = true },
        live_grep  = {}, -- defaults.vimgrep_arguments を参照
      },
    })

    -- よく使うキーマップ（パッケージ固有なのでここに寄せる）
    local map = vim.keymap.set
    map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    map("n", "<leader>fg", builtin.live_grep,  { desc = "Live grep" })
    map("n", "<leader>fb", builtin.buffers,    { desc = "Buffers" })
    map("n", "<leader>fh", builtin.help_tags,  { desc = "Help tags" })
    map("n", "<leader>fr", builtin.resume,     { desc = "Resume last picker" })
    map("n", "<leader>fo", builtin.oldfiles,   { desc = "Recent files" })

    -- 任意ディレクトリを起点に find_files（あなたの <leader>fp）
    map("n", "<leader>fp", function()
      local input = vim.fn.input("Search path: ", vim.fn.getcwd(), "dir")
      if input == "" then return end
      builtin.find_files({ cwd = vim.fn.expand(input) })
    end, { desc = "Find files in specified path" })
  end,
}
