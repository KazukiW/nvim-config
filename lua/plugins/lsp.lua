-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  { "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
    build = ":MasonUpdate",
    config = true
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      -- ガード：re-source時の二重初期化を防止
      if vim.g.__my_lsp_setup_done then return end
      vim.g.__my_lsp_setup_done = true

      local lsp  = require("lspconfig")
      local util = require("lspconfig.util")

      -- capabilities / on_attach
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = ok_cmp and cmp_lsp.default_capabilities()
        or vim.lsp.protocol.make_client_capabilities()
      local on_attach = function(_, bufnr)
        local map = function(m,l,r) vim.keymap.set(m,l,r,{buffer=bufnr}) end
        map("n","gd",vim.lsp.buf.definition); map("n","gr",vim.lsp.buf.references)
        map("n","K",vim.lsp.buf.hover); map("n","<leader>rn",vim.lsp.buf.rename)
        map("n","<leader>ca",vim.lsp.buf.code_action)
        map("n","[d",vim.diagnostic.goto_prev); map("n","]d",vim.diagnostic.goto_next)
        map("n","<leader>f",function() vim.lsp.buf.format({async=true}) end)
      end

      -- ルート検出（見つからなければ CWD）
      local py_root = util.root_pattern("pyproject.toml","setup.cfg","setup.py",
                                        "requirements.txt",".git")
      local root_or_cwd = function(fname)
        return py_root(fname) or util.find_git_ancestor(fname) or vim.loop.cwd()
      end

      -- ★ 自動セットアップは実行しない（ensure だけ）
      require("mason-lspconfig").setup({
        ensure_installed = { "basedpyright", "ruff", "lua_ls", "clangd" },
      })

      -- ★ ここで“1回だけ”明示セットアップ
      lsp.basedpyright.setup({
        root_dir = root_or_cwd,
        capabilities = capabilities,
        on_attach = on_attach,
        basedpyright = {
          analysis = {
            typeCheckingMode = "standard",
            diagnosticMode = "openFilesOnly",
            autoImportCompletions = true,
          },
        },
      })

      lsp.ruff.setup({
        root_dir = root_or_cwd,
        capabilities = capabilities,
        on_attach = on_attach,
        -- 「invalid client settings」を避ける最小値
        init_options = { settings = { args = {} } },
      })

      lsp.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = { Lua = { diagnostics = { globals = { "vim" } },
                             workspace = { checkThirdParty = false } } },
      })

      lsp.clangd.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = { "clangd", "--background-index", "--clang-tidy" },
      })
      local grp = vim.api.nvim_create_augroup("DedupLSP", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = grp,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          if client.name ~= "basedpyright" and client.name ~= "ruff" then return end

          local bufnr = args.buf
          local same = {}
          for _, c in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
            if c.name == client.name then table.insert(same, c) end
          end
          if #same <= 1 then return end

          table.sort(same, function(a, b)
            local ar = a.config and a.config.root_dir and 1 or 0
            local br = b.config and b.config.root_dir and 1 or 0
            if ar ~= br then return ar > br end   -- root_dir ありを優先
            return a.id > b.id                    -- 新しい方を優先
          end)
          for i = 2, #same do
            vim.lsp.stop_client(same[i].id)
          end
        end,
      })
    end,
  },
}

