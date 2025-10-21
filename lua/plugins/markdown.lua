return {
  -- インバッファ描画（見出し/表/チェックボックス等）
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- 編集支援（リスト/リンク/表/チェックボックス等）
  {
    "jakewvincent/mkdnflow.nvim",
    ft = { "markdown" },
    config = function()

      require("mkdnflow").setup({
        modules = { cmp=false, maps=true, tables=true, links=true, lists=true, folds=true },
        mappings = {
          MkdnEnter = { "i","<CR>" },
          MkdnToggleToDo = { "n","<leader>xc" },

          MkdnTableNextCell = { "i","<Tab>" },
          MkdnTablePrevCell = { "i","<S-Tab>" },
        },
      })
    end,
  },

  -- Glow プレビュー（フローティング）
  {
    "ellisonleao/glow.nvim",
    ft = { "markdown" },
    config = function()
      require("glow").setup({ border="rounded", width=140, height=48 })
      vim.keymap.set("n","<leader>md","<cmd>Glow<CR>",{ desc="Markdown Preview (glow)" })

    end,
  },
}
