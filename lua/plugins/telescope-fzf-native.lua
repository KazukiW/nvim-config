-- ~/.config/nvim/lua/plugins/telescope-fzf-native.lua
return {
  "nvim-telescope/telescope-fzf-native.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-telescope/telescope.nvim" },

  -- プラットフォーム別ビルド（make or cmake）
  build = function()
    local is_win = (vim.loop.os_uname().sysname or ""):match("Windows") ~= nil
    if vim.fn.executable("make") == 1 and not is_win then
      vim.fn.system({ "make" })
    elseif vim.fn.executable("cmake") == 1 then
      vim.fn.system({ "cmake", "-S.", "-Bbuild", "-DCMAKE_BUILD_TYPE=Release" })
      vim.fn.system({ "cmake", "--build", "build", "--config", "Release" })
      vim.fn.system({ "cmake", "--install", "build", "--prefix", "build" })
    else
      vim.notify("telescope-fzf-native: make か cmake が必要です。", vim.log.levels.WARN)
    end
  end,

  config = function()
    local telescope_ok, telescope = pcall(require, "telescope")
    if not telescope_ok then return end

    -- 既存の telescope.setup に追記する形で extensions 設定をマージ
    telescope.setup({
      extensions = {
        fzf = {
          -- ここが“速さ”の要
          fuzzy = true,                    -- あいまい検索オン
          override_generic_sorter = true,  -- generic sorter を置き換え
          override_file_sorter = true,     -- file sorter を置き換え
          case_mode = "smart_case",        -- 大文字を含めたら大小区別、含まなければ無視
        },
      },
    })

    -- 拡張をロード
    pcall(telescope.load_extension, "fzf")
  end,
}
