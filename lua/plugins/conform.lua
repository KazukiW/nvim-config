-- lua/plugins/conform.lua
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" }, -- 保存時フォーマットにするなら
	cmd = { "ConformInfo", "Conform" },
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" }, -- or "black"
			cpp = { "clang-format" },
			c = { "clang-format" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			json = { "prettier" },
			toml = { "taplo" },
			sh = { "shfmt" },
			markdown = { "prettier" },
		},
		-- LSP が format もっている場合の扱い
		-- ひとまず "fallback" にしておくと安全
		format_on_save = {
			lsp_fallback = true,
			timeout_ms = 5000,
		},
	},

	keys = {
		{
			"<leader>f",
			"<cmd>Format<CR>",
			mode = "n",
			desc = "Format buffer (conform)",
		},
	},

	config = function(_, opts)
		local conform = require("conform")

		-- "opts"セットアップ
		conform.setup(opts)

		-- コマンドセットアップ :Format
		vim.api.nvim_create_user_command("Format", function()
			conform.format({ async = true, lsp_fallback = false })
		end, {})
	end,
}
