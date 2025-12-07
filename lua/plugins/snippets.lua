-- 例: lua/plugins/snippets.lua
return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*", -- v2系を固定しておくと無難
		build = "make install_jsregexp", -- 高機能な正規表現サポート（必須ではないが推奨）
		event = "InsertEnter", -- 挿入モードに入るまで遅延ロード
		dependencies = {
			"rafamadriz/friendly-snippets", -- VSCode形式の大量スニペット集（おまけ）
		},
		config = function()
			local ls = require("luasnip")

			-- VSCode形式のスニペット（friendly-snippets等）を読み込む
			require("luasnip.loaders.from_vscode").lazy_load()

			-- 自前Luaスニペットを読み込む (このあと作る)
			require("luasnip.loaders.from_lua").lazy_load({
				paths = vim.fn.stdpath("config") .. "/lua/snippets",
			})

			ls.config.set_config({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				enable_autosnippets = false,
			})
		end,
	},
}
