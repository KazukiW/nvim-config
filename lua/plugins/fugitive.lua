return {
  "tpope/vim-fugitive",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "Git", "G" }, -- :Git / :G 実行で遅延ロード
  keys = {
    { "<leader>gs", "<cmd>Git<CR>", desc = "Fugitive: status" },
    { "<leader>gb", "<cmd>Git blame<CR>", desc = "Fugitive: blame line" },
    { "<leader>gd", "<cmd>Gvdiffsplit!<CR>", desc = "Fugitive: diff vs HEAD (vsplit)" },

    { "<leader>gl", "<cmd>0Gclog<CR>", desc = "Fugitive: file log" },
    { "<leader>gc", "<cmd>Gedit HEAD~1:%<CR>", desc = "Fugitive: open prev commit of current file" },
  },
  config = function()
    -- 必要ならここに追記（今は最小でOK）
  end,
}

