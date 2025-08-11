-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate", -- プラグイン更新時にパーサも更新
  event = { "BufReadPost", "BufNewFile" }, -- ファイル読み込み時に遅延ロード

  config = function()
    require("nvim-treesitter.configs").setup({
      -- インストールする言語
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        "bash", "python", "javascript", "typescript", "html", "css",
        "c", "cpp", "json", "markdown", "markdown_inline",
      },

      sync_install = false, -- 同期的インストール（falseで非同期）
      auto_install = true,  -- 未インストール言語を自動インストール

      highlight = {
        enable = true,              -- ハイライト有効
        additional_vim_regex_highlighting = false, -- 従来のregexハイライト無効
      },
      indent = { enable = true },   -- インデント機能
      incremental_selection = {     -- 構文ツリーを使った選択拡張
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
    })
  end,
}
