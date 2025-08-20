-- Neovim configuration
-- Reviced : 2025/08/20
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("config") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.clipboard = "unnamedplus"

-- basic setting
vim.opt.path:append({ ".", "**" })
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.g.mapleader = " "
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Load lazy.nvim
require("lazy").setup({
    -- Add plugins here
    -- status line
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
    -- fuzzy finder
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    -- fzf-native
    { 
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
       require('telescope').load_extension('fzf')
      end
    },
    -- treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      --build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup {
          ensure_installed = {
            "markdown",
            "markdown_inline",
            "latex",
            "lua",
            "python",
            "cpp"
          }, -- よく使う言語
          highlight = { enable = true },
          indent = { enable = true },
        }
      end
    },
    -- Git operation: fugitive
    {
        "tpope/vim-fugitive",
        config = function()
            --define custom mappings here
            vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git Status" })
            vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git Commit" })
            vim.keymap.set("n", "<leader>gh", "<cmd>Git push<CR>", { desc = "Git Push" })
            vim.keymap.set("n", "<leader>gl", "<cmd>Git pull<CR>", { desc = "Git Pull" })
        end
    },
})

-- keymap setting
require('keymaps')

-- lualine setting
require('lualine').setup {
    options = {
        theme = 'auto',
        section_separators = '',
        component_separators = ''
    }
}
