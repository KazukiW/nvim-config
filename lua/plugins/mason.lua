-- ~/.config/nvim/lua/plugins/mason.lua
return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		opts = {}, -- デフォルト設定でOK
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		-- ここでは handlers を空にして、
		-- 「自動で LSP を立ち上げない」ようにしておく
		--     config = function()
		--       require("mason-lspconfig").setup({
		--         automatic_installation = false,
		--         handlers = {}, -- ★ 自動 setup 無効
		--       })
		--     end,
		opts = {
			ensure_installed = {
				-- LSP
				"lua_ls",
				"clangd",
				"pyright",
				"html",
				"cssls",
				"emmet_language_server",
				"ts_ls",
				"bashls",
				"jsonls",
				"yamlls",
				"marksman",
			},
			automatic_installation = false,
			automatic_enable = false,
		},
	},
}
