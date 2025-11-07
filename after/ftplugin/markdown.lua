-- 1) まず、このバッファで mkdnflow の <Tab>/<S-Tab> を外す
pcall(function()
  vim.keymap.del("i", "<Tab>",   { buffer = true })
  vim.keymap.del("i", "<S-Tab>", { buffer = true })
  vim.keymap.del("n", "<Tab>",   { buffer = true })
  vim.keymap.del("n", "<S-Tab>", { buffer = true })
end)

-- ~/.config/nvim/after/ftplugin/markdown.lua
vim.opt_local.expandtab   = true
vim.opt_local.shiftwidth  = 3
vim.opt_local.tabstop     = 3
vim.opt_local.softtabstop = 3


local function is_list_line(line)

  -- 先頭空白 → 箇条書き記号（- * +）or 番号付き（n. ）の行？
  return line:match("^%s*[-+*]%s+") or line:match("^%s*%d+%.%s+")
end

-- <Tab>: 行頭では状況で挙動を分岐
vim.keymap.set("i", "<Tab>", function()
  local col   = vim.fn.col(".")
  local line  = vim.api.nvim_get_current_line()
  local lead  = (line:match("^%s*") or "")
  local atbol = (col <= #lead + 1)

  if not atbol then
    return "\t"  -- 行頭以外は通常（=3スペース）
  end

  if is_list_line(line) then
    -- リストの行: ネストを2刻みで増やしたい（4を跨いでもOK）
    return "  "  -- 2スペース
  else
    -- 段落の行: 4以上でコード化されるので最大3に抑える
    if #lead >= 3 then
      return ""    -- これ以上増やさない
    else
      return string.rep(" ", 3 - #lead)  -- 3まで埋める
    end
  end
end, { buffer = true, expr = true, desc = "Markdown smart Tab" })

-- <S-Tab>: 行頭では逆方向（アウトデント）
vim.keymap.set("i", "<S-Tab>", function()

  local col   = vim.fn.col(".")
  local line  = vim.api.nvim_get_current_line()
  local lead  = (line:match("^%s*") or "")
  local atbol = (col <= #lead + 1)

  if not atbol then
    return "" -- 何もしない（好みで <BS> などにしてもOK）

  end

  if is_list_line(line) then
    -- リストの行: 2スペース分戻す
    return "<C-d>" .. "<C-d>"  -- 2回デリート（softtabstop=3の影響受けないように）
  else
    -- 段落の行: 3以内で戻す
    if #lead == 0 then return "" end
    return "<BS>"
  end
end, { buffer = true, expr = true, desc = "Markdown smart Shift-Tab" })


