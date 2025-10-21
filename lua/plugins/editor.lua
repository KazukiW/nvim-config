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
      t.setup({ defaults = { mappings = { i = { ["<C-u>"]=false, ["<C-d>"]=false } } } })
      pcall(t.load_extension, "fzf")
      local kb = vim.keymap.set

      kb("n","<leader>ff", require("telescope.builtin").find_files, { desc="Find Files" })
      kb("n","<leader>fg", require("telescope.builtin").live_grep,  { desc="Live Grep" })
      kb("n","<leader>fb", require("telescope.builtin").buffers,    { desc="Buffers" })
      kb("n","<leader>fh", require("telescope.builtin").help_tags,  { desc="Help" })
    end,
  },

  -- Treesitter

  {
    "nvim-treesitter/nvim-treesitter",
    build=":TSUpdate",
    config=function()
      require("nvim-treesitter.configs").setup({
        ensure_installed={
          "lua","vim","vimdoc","bash","python","cpp","json","yaml",
          "markdown","markdown_inline","html","css","javascript","query",
        },
        highlight={ enable=true },
        indent={ enable=true },
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
