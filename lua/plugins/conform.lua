-- lua/plugins/conform.lua
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" }, -- 保存時フォーマットにするなら
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" }, -- or "black"
			cpp = { "clang_format" },
			c = { "clang_format" },
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
			timeout_ms = 500,
		},
	},
}
