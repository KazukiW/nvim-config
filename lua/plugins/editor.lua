-- lua/plugins/editor.lua
return {
	{ "nvim-lua/plenary.nvim" },

	-- Telescope + fzf
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local t = require("telescope")
			t.setup({ defaults = { mappings = { i = { ["<C-u>"] = false, ["<C-d>"] = false } } } })
			pcall(t.load_extension, "fzf")
			local map = vim.keymap.set
			local builtin = require("telescope.builtin")

			map("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
			map("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
			map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
			map("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
			map("n", "<leader>R", "<cmd>Telescope registers<CR>", { desc = "Help" })

			map("n", "<leader>fz", function()
				builtin.find_files({
					cwd = vim.fn.expand("~"),
					hidden = true,
				})
			end, { desc = "Fine dotfiles in $HOME" })
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"bash",
					"python",
					"cpp",
					"json",
					"yaml",
					"markdown",
					"markdown_inline",
					"html",
					"css",
					"javascript",
					"query",
				},
				highlight = { enable = true },
				indent = { enable = true },

				modules = {},
				sync_install = false,
				ignore_install = {},
				auto_install = false,
			})
		end,
	},

	-- Git signs
	{ "lewis6991/gitsigns.nvim", config = true },

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({ options = { theme = "auto", globalstatus = true } })
		end,
	},

	-- which-key
	{ "folke/which-key.nvim", config = true },

	-- Diagnostics panel

	{ "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },

	-- TODO highlighting
	{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, config = true },
}
