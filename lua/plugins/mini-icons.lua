-- lua/plugins/mini-icons.lua
return {
  "echasnovski/mini.icons",
  version = false,   -- 常に最新系（lockで固定されます）
  lazy = false,      -- 早めにロード（依存側より先に）
  priority = 1000,   -- devicons などより前に来やすくする
  config = function()
    -- 何も書かなくてOK。必要なら上書きマップを定義可。
    -- 例: require("mini.icons").setup({ style = "glyph" })
  end,
}

