-- plugins/lsp.lua (pure start-table: no lspconfig, no vim.lsp.config)
-- - uses vim.lsp.start({ name = ..., cmd = ... }) directly
-- - uses vim.fs / vim.uv helpers
-- - avoids lua_ls warnings (---@cast uv table)

vim.notify("[plugins/lsp.lua] pure start-table loaded", vim.log.levels.INFO)

return {
  { "williamboman/mason.nvim", build = ":MasonUpdate", opts = { PATH = "append" } },
  { "folke/neodev.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      -- ---------- common helpers ----------
      local uv = vim.uv or vim.loop ---@cast uv table
      local function cwd() return (uv and uv.cwd and uv.cwd()) or vim.fn.getcwd() end
      local function dirname(p) return (type(p) == "string" and #p > 0) and vim.fs.dirname(p) or nil end
      local function find_up(markers, startpath)

        local hit = vim.fs.find(markers, { path = startpath, upward = true })[1]
        return hit and dirname(hit) or nil
      end
      local function default_root(fname)
        local start = (type(fname) == "string" and #fname > 0) and fname or cwd()
        return find_up({ ".git", ".hg", ".svn" }, start) or dirname(start) or cwd()
      end
      local function root_with(markers)
        return function(fname)
          local start = (type(fname) == "string" and #fname > 0) and fname or cwd()

          return find_up(markers, start) or default_root(fname)

        end
      end
      local function make_caps()

        local caps = vim.lsp.protocol.make_client_capabilities()

        caps.textDocument = caps.textDocument or {}
        caps.textDocument.diagnostic = { dynamicRegistration = false }
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok then caps = vim.tbl_deep_extend("force", caps, cmp_lsp.default_capabilities()) end
        return caps
      end

      -- ---------- utility: autostart per filetype, dedupe ----------
      local function autostart(name, filetypes, cfg)
        assert(type(name) == "string", "LSP server name must be a string")
        assert(type(filetypes) == "table", "filetypes must be a list")
        assert(type(cfg) == "table", "cfg must be a table")

        local function ensure(buf)
          if not vim.api.nvim_buf_is_valid(buf) then return end
          if not vim.tbl_contains(filetypes, vim.bo[buf].filetype) then return end
          if #vim.lsp.get_clients({ bufnr = buf, name = name }) > 0 then return end
          vim.lsp.start(cfg, { bufnr = buf })
        end

        for _, c in ipairs(vim.lsp.get_clients({ name = name })) do pcall(function() c:stop() end) end

        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("lsp_once_" .. name, { clear = true }),
          pattern = filetypes,
          callback = function(a) ensure(a.buf) end,
        })
        ensure(0)

        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("lsp_dedupe_" .. name, { clear = true }),
          callback = function(a)

            local new = vim.lsp.get_client_by_id(a.data.client_id)
            if not new or new.name ~= name then return end
            local olds = {}
            for _, c in ipairs(vim.lsp.get_clients({ bufnr = a.buf })) do
              if c.name == name and c.id ~= new.id then table.insert(olds, c) end
            end
            table.sort(olds, function(x, y) return x.id < y.id end)

            for _, c in ipairs(olds) do pcall(function() c:stop() end) end
          end,
        })
      end

      -- 共有capabilities
      local caps = make_caps()

      -- ---------- lua_ls ----------

      local lua_cfg = {
        name = "lua_ls",
        cmd = { "lua-language-server" },
        root_dir = default_root,
        single_file_support = true,
        capabilities = caps,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
          },
        },
        on_init = function(client)
          pcall(function() require("neodev").setup({}) end)
          client:notify("workspace/didChangeConfiguration", { settings = client.config.settings or {} })
        end,
        on_attach = function(client, _)
          client:notify("workspace/didChangeConfiguration", { settings = client.config.settings or {} })
        end,
      }
      autostart("lua_ls", { "lua" }, lua_cfg)

      -- ---------- pyright ----------
      local py_cfg = {
        name = "pyright",
        cmd = { "pyright-langserver", "--stdio" },
        root_dir = root_with({ "pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", ".git" }),
        single_file_support = true,
        capabilities = caps,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
            },
          },
        },
        on_init = function(client)
          client:notify("workspace/didChangeConfiguration", { settings = client.config.settings or {} })

        end,
        on_attach = function(client, _)
          client:notify("workspace/didChangeConfiguration", { settings = client.config.settings or {} })
        end,
      }
      autostart("pyright", { "python" }, py_cfg)

      -- ---------- clangd ----------
      local clangd_cfg = {
        name = "clangd",
        cmd = { "clangd" },
        root_dir = root_with({ "compile_commands.json", ".clangd", ".git" }),
        single_file_support = true,
        capabilities = caps,
        on_init = function(client)
          client:notify("workspace/didChangeConfiguration", { settings = client.config.settings or {} })
        end,
        on_attach = function(client, _)
          client:notify("workspace/didChangeConfiguration", { settings = client.config.settings or {} })

        end,
      }
      autostart("clangd", { "c", "cpp", "objc", "objcpp", "cuda" }, clangd_cfg)


      -- ---------- html ----------
      local html_cfg = {
        name = "html",

        cmd = { "vscode-html-language-server", "--stdio" },
        root_dir = default_root,
        single_file_support = true,
        capabilities = caps,
      }
      autostart("html", { "html" }, html_cfg)


      -- ---------- cssls ----------
      local css_cfg = {
        name = "cssls",
        cmd = { "vscode-css-language-server", "--stdio" },

        root_dir = default_root,
        single_file_support = true,
        capabilities = caps,
      }
      autostart("cssls", { "css", "scss", "less" }, css_cfg)

      -- ---------- emmet ----------

      local emmet_cfg = {
        name = "emmet_ls",

        cmd = { "emmet-language-server", "--stdio" },
        root_dir = default_root,
        single_file_support = true,
        capabilities = caps,
      }
      autostart("emmet_ls", { "html", "css", "scss", "less", "javascriptreact", "typescriptreact" }, emmet_cfg)

      -- ---------- ts_ls ----------
      local ts_cfg = {
        name = "ts_ls",
        cmd = { "typescript-language-server", "--stdio" },

        root_dir = root_with({ "tsconfig.json", "jsconfig.json", "package.json", ".git" }),
        single_file_support = true,
        capabilities = caps,
      }
      autostart("ts_ls", { "typescript", "typescriptreact", "javascript", "javascriptreact" }, ts_cfg)
    end,
  },


  -- formatter (optional)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { lua = { "stylua" } },
      notify_on_error = false,
    },
  },
}

