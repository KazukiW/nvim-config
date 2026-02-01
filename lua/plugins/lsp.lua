-- ~/.config/nvim/lua/plugins/lsp.lua
return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },

		--補完機能プラグイン
		dependencies = {
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},

		config = function()
			local lsp = vim.lsp
			-----------------------------------------------------------------------
			-- 1. 共通 on_attach / capabilities
			-----------------------------------------------------------------------
			local capabilities = lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_lsp.default_capabilities(capabilities)
			end

			-- 			local function on_attach(client, bufnr)
			-- 				local map = function(mode, lhs, rhs, desc)
			-- 					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			-- 				end
			--
			-- 				map("n", "gd", lsp.buf.definition, "LSP: goto definition")
			-- 				map("n", "K", lsp.buf.hover, "LSP: hover")
			-- 				map("n", "gr", lsp.buf.references, "LSP: references")
			-- 				map("n", "gi", lsp.buf.implementation, "LSP: implementation")
			-- 				map("n", "<leader>rn", lsp.buf.rename, "LSP: rename")
			-- 				map("n", "<leader>ca", lsp.buf.code_action, "LSP: code action")
			-- 				map("n", "<leader>e", vim.diagnostic.open_float, "Diag: Float")
			-- 			end
			--
			-- 			local function with_defaults(opts)
			-- 				opts = opts or {}
			-- 				opts.capabilities = capabilities
			-- 				opts.on_attach = on_attach
			-- 				return opts
			-- 			end

			-- すべての LSP に共通で capabilities を注入
			lsp.config("*", {
				capabilities = capabilities,
			})

			-- LspAttach発生時にキーマップをアタッチ
			local aug = vim.api.nvim_create_augroup("my-lsp-on-attach", { clear = true })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = aug,
				callback = function(ev)
					local bufnr = ev.buf

					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if not client then
						return
					end

					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
					end

					map("n", "gd", lsp.buf.definition, "LSP: goto definition")
					map("n", "K", lsp.buf.hover, "LSP: hover")
					map("n", "gr", lsp.buf.references, "LSP: references")
					map("n", "gi", lsp.buf.implementation, "LSP: implementation")
					map("n", "<leader>rn", lsp.buf.rename, "LSP: rename")
					map("n", "<leader>ca", lsp.buf.code_action, "LSP: code action")
					map("n", "<leader>e", vim.diagnostic.open_float, "Diag: Float")
				end,
			})

			-----------------------------------------------------------------------
			-- 2. mason-lspconfig 側の自動 handler を止めておく（任意）
			-----------------------------------------------------------------------
			-- 2025.11.30 mason-lspconfigの仕様変更に合わせて、setup無効の手続きを変更
			-- -> このセクションは無効化
			-- 			pcall(function()
			-- 				require("mason-lspconfig").setup({
			-- 					automatic_installation = false,
			-- 					handlers = {}, -- 既定ハンドラ無効化（旧 lspconfig.setup を防ぐ）
			-- 				})
			-- 			end)

			-----------------------------------------------------------------------
			-- 3. clangd の v0.11 / v3 用設定
			--    （旧 lsp_old.lua のロジックを vim.lsp.config 版に移植）
			-----------------------------------------------------------------------

			-- 3-1. query-driver を組み立てる（Pico 用クロスコンパイラ優先）
			local query = vim.fn.exepath("arm-none-eabi-gcc")
			if query == "" then
				-- 見つからないときのフォールバック
				query = "/usr/bin/arm-none-eabi-*"
			else
				query = query:gsub("gcc$", "*")
			end

			-- clangd
			lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--header-insertion=never",
					"--compile-commands-dir=.",
					"--query-driver=" .. query,
				},
				-- 旧 root_dir の条件を root_markers にマッピング
				root_markers = {
					"compile_commands.json",
					".clangd",
					"CMakeLists.txt",
					".git",
				},
				single_file_support = true,
			})

			-- lua_ls
			lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = {
					".luarc.json",
					".luarc.jsonc",
					".luacheckrc",
					".stylua.toml",
					".git",
				},
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							checkThirdParty = false,
							library = vim.api.nvim_get_runtime_file("", true),
						},
						telemetry = { enable = false },
					},
				},
			})

			-- taplo
			lsp.config("taplo", {
				root_markers = {
					"pyproject.toml",
					"Cargo.toml",
					".git",
				},
				single_file_support = true,
			})

			-- pyright (Python)
			lsp.config("pyright", {
				filetypes = { "python" },
				root_markers = {
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					".git",
				},
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic", -- 慣れたら "strict" も検討
							autoImportCompletions = true,
						},
					},
				},
			})

			-- HTML
			lsp.config("html", {
				filetypes = { "html" },
				root_markers = { "package.json", ".git" },
				settings = {
					html = {
						-- フォーマットは prettier / conform に任せる
						format = { enable = false },
					},
				},
			})

			-- CSS / SCSS / Less
			lsp.config("cssls", {
				filetypes = { "css", "scss", "less" },
				root_markers = { "package.json", ".git" },
				settings = {
					css = {
						validate = true,
						format = { enable = false },
					},
					scss = {
						validate = true,
						format = { enable = false },
					},
					less = {
						validate = true,
						format = { enable = false },
					},
				},
			})

			-- Emmet
			-- nvim-lspconfig のサーバ名は "emmet_ls"
			lsp.config("emmet_ls", {
				filetypes = {
					"html",
					"css",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"vue",
					"svelte",
				},
				root_markers = { ".git" },
			})

			-- TypeScript / JavaScript
			-- 0.11 世代では "ts_ls" が推奨 (旧 tsserver)
			lsp.config("ts_ls", {
				filetypes = {
					"typescript",
					"typescriptreact",
					"javascript",
					"javascriptreact",
				},
				root_markers = {
					"tsconfig.json",
					"jsconfig.json",
					"package.json",
					".git",
				},
				-- 必要になったら settings.typescript / settings.javascript を追加で詰める
			})

			-- Markdown
			lsp.config("marksman", {
				filetypes = { "markdown", "markdown.mdx" },
				root_markers = {
					".marksman.toml",
					".git",
				},
			})

			-- 各言語サーバの有効化
			local enable_list = {
				"lua_ls",
				"clangd",
                "pyright",
                "html",
                "cssls",
                "emmet_ls",
                "ts_ls",
                "marksman",
			}
			lsp.enable(enable_list)

			-----------------------------------------------------------------------
			-- 4. ログレベル（必要になったときだけ INFO/DEBUG に上げる）
			-----------------------------------------------------------------------
			lsp.set_log_level("WARN")
		end,
	},
}
