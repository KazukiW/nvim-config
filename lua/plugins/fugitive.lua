-- Git の“瑞々しい正道”こと vim-fugitive の外部化設定
return {
  "tpope/vim-fugitive",
  event = { "BufReadPost", "BufNewFile" }, -- ふだんは遅延ロード
  -- すぐ使いたい時は keys で先行ロード用のトリガを持たせてもOK
  keys = {
    -- ステータス（インタラクティブUI）
    { "<leader>gs", "<cmd>Git<CR>", desc = "Fugitive: status" },
    -- ブレイム（現在行）
    { "<leader>gb", "<cmd>Gblame<CR>", desc = "Fugitive: blame line" },
    -- 差分（カレントバッファ vs HEAD）
    { "<leader>gd", "<cmd>Gvdiffsplit!<CR>", desc = "Fugitive: diff vs HEAD (vsplit)" },
    -- ログ（カレントファイル限定）
    { "<leader>gl", "<cmd>0Gclog<CR>", desc = "Fugitive: file log" },
    -- 直前コミットを開く（テキストオブジェクト操作に便利）
    { "<leader>gc", "<cmd>Gedit HEAD~1:%<CR>", desc = "Fugitive: open prev commit of current file" },
  },

  config = function()
    -- ここでは最小限。必要ならカスタムコマンド等を後で追加
    -- 例: :Gwrite, :Gread, :Gcommit, :Gpush, :Gpull などはプラグイン読み込みで使用可能に
  end,
}
