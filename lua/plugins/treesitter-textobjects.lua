-- Treesitter のテキストオブジェクト／移動／スワップ拡張
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },

  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        -- 1) 選択：関数・クラス・引数などを“一発選択”
        select = {
          enable = true,
          lookahead = true, -- カーソルから先読みして最初の一致に飛ぶ
          keymaps = {
            ["af"] = "@function.outer", -- a function（関数全体）
            ["if"] = "@function.inner", -- inner function（関数の中身）

            ["ac"] = "@class.outer",    -- a class（クラス全体）
            ["ic"] = "@class.inner",    -- inner class（クラスの中身）

            ["aa"] = "@parameter.outer",-- a argument（引数1個）
            ["ia"] = "@parameter.inner",

            -- 必要に応じて条件式やブロックも
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
          },
        },

        -- 2) 移動：次/前の関数・クラスの開始/終了へジャンプ
        move = {
          enable = true,
          set_jumps = true, -- jumplist に積む
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },

        -- 3) スワップ：関数引数の入れ替え（隣と交換）
        swap = {
          enable = true,
          swap_next = { ["<leader>sa"] = "@parameter.inner" },
          swap_previous = { ["<leader>sA"] = "@parameter.inner" },
        },
      },
    })
  end,
}
