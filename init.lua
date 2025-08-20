-- Initialization for Neovim
-- Reviced: 2025/08/21

-- Block for Debug
-- Logging keymap settings
--local orig_keymap_set = vim.keymap.set
--vim.keymap.set = function(mode, lhs, rhs, opts)
--  local info = debug.getinfo(2, "Sl")
--  print(string.format("[keymap] %s -> %s (from %s:%d)",
--    lhs, tostring(rhs), info.short_src, info.currentline))
--  return orig_keymap_set(mode, lhs, rhs, opts)
--end

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
    spec = {
      { import = "plugins" }, -- auto loads every file in lua/plugins/
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
