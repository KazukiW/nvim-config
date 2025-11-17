-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      ------------------------------------------------------------------------
      -- 1. 安全に lspconfig を取得
      ------------------------------------------------------------------------
      local ok_lsp, lspconfig = pcall(require, "lspconfig")
      if not ok_lsp then
        return
      end
      local util = require("lspconfig.util")

      ------------------------------------------------------------------------
      -- 2. 共通 on_attach / capabilities（後で好きに埋めていい）
      ------------------------------------------------------------------------
      local on_attach = function(client, bufnr)
        -- 必要ならここにキーマップなどを書く
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- cmp_nvim_lsp を使っているなら後でここに統合でOK

      ------------------------------------------------------------------------
      -- 3. mason-lspconfig の自動ハンドラを止める（あれば）
      ------------------------------------------------------------------------
      pcall(function()
        require("mason-lspconfig").setup {
          automatic_installation = false,
          handlers = {}, -- 既定ハンドラ無効化
        }
      end)

      ------------------------------------------------------------------------
      -- 4. clangd の設定（クロスコンパイラ対応）
      ------------------------------------------------------------------------
      local query = vim.fn.exepath("arm-none-eabi-gcc")
      if query == "" then
        -- 見つからないときのフォールバック（必要ならパスを調整）
        query = "/usr/bin/arm-none-eabi-*"
      else
        query = query:gsub("gcc$", "*")
      end

      lspconfig.clangd.setup {
        cmd = {
          "clangd",
          "--background-index",
          "--header-insertion=never",
          "--compile-commands-dir=.",
          "--query-driver=" .. query,
        },
        root_dir = function(fname)
          return util.root_pattern(
            "compile_commands.json",
            ".clangd",
            "CMakeLists.txt",
            ".git"
          )(fname) or util.path.dirname(fname)
        end,
        single_file_support = true,
        on_attach = on_attach,
        capabilities = capabilities,
      }

      ------------------------------------------------------------------------
      -- 5. ログレベル（調整用。安定したら WARN に落としてOK）
      ------------------------------------------------------------------------
      vim.lsp.set_log_level("WARN")
    end,
  },
}

