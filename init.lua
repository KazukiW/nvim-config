-- ===== Core options =====
vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- vim.g.path:append({ ".", "**" })
-- vim.opt.rtp:prepend(lazypath)
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.foldmethod = "expr"

-- WSL clipboard (win32yank)
if vim.fn.has("wsl") == 1 and vim.fn.executable("win32yank.exe") == 1 then
	vim.g.clipboard = {
		name = "win32yank-wsl",
		copy = { ["+"] = { "win32yank.exe", "-i", "--crlf" }, ["*"] = { "win32yank.exe", "-i", "--crlf" } },
		paste = { ["+"] = { "win32yank.exe", "-o", "--lf" }, ["*"] = { "win32yank.exe", "-o", "--lf" } },
		cache_enabled = 0,
	}
end

-- SSH中は勝手にOSクリップボードへ同期しない（"+y のときだけ）
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

local function b64_encode(text)
  -- できればNeovim内蔵を使う（0.11なら大抵ある）
  if vim.base64 and vim.base64.encode then
    return vim.base64.encode(text)
  end
  -- 最後の保険：外部 base64（改行は潰す）
  local out = vim.fn.system("base64", text)
  return (out:gsub("\n", ""))
end

local function osc52_write(payload)
  io.stdout:write(payload)
  io.stdout:flush()
end

local function osc52_copy(lines, _)
  local text = table.concat(lines, "\n")
  local b64 = b64_encode(text)

  -- 生OSC52
  local osc = "\027]52;c;" .. b64 .. "\007"

  -- 外側がtmux(WSL)なら、tmux用DCSラップで“通過”させる
  if vim.env.NVIM_OSC52_TMUX == "1" then
    -- tmuxはDCSの中ではESCを二重化して渡す必要がある
    local inner = osc:gsub("\027", "\027\027")
    osc = "\027Ptmux;" .. inner .. "\027\\"
  end

  osc52_write(osc)
end

if vim.env.SSH_TTY then
  vim.g.clipboard = {
    name = "OSC52 (tmux wrapped)",
    copy = { ["+"] = osc52_copy, ["*"] = osc52_copy },
    -- 低リスク：pasteは無効（ローカルreadbackを開けない）
    paste = {
      ["+"] = function() return {} end,
      ["*"] = function() return {} end,
    },
  }
end


-- Neovim用 Python ホスト（専用venv）
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- ===== lazy.nvim bootstrap =====
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@type any
local uv = vim.uv or vim.loop
if uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ===== Plugins (import all under lua/plugins) =====
require("lazy").setup({
	spec = { { import = "plugins" } },
	ui = { border = "rounded" },
	rocks = { enabled = false },

	pcall(function()
		vim.keymap.del("n", "gc") -- 短い方だけ削除
	end),
})

-- ----- LuaSnip jsregexp: C拡張の検索パスを追加 -----
do
	local base = vim.fn.stdpath("data") .. "/lazy/LuaSnip"
	-- .so が置かれる deps ディレクトリを追加
	package.cpath = package.cpath .. ";" .. base .. "/deps/?.so"
end

-- ----- LuaSnip jsregexp: 旧名 → 新名の互換レイヤ -----
-- do
-- 	local ok = pcall(require, "luasnip-jsregexp")
-- 	if ok then
-- 		-- "luasnip.extras._jsregexp" を要求されたら "luasnip-jsregexp" を返す
-- 		package.preload["luasnip.extras._jsregexp"] = function()
-- 			return require("luasnip-jsregexp")
-- 		end
-- 	end
-- end

-- ===== Common LSP keymaps =====
-- local function on_attach(_, bufnr)
-- 	local map = function(m, l, r, d)
-- 		vim.keymap.set(m, l, r, { buffer = bufnr, desc = d })
-- 	end
-- 	map("n", "gd", vim.lsp.buf.definition, "LSP: Definition")
-- 	map("n", "gr", vim.lsp.buf.references, "LSP: References")
--
-- 	map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
-- 	map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
-- 	map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
-- 	map("n", "[d", vim.diagnostic.goto_prev, "Diag: Prev")
-- 	map("n", "]d", vim.diagnostic.goto_next, "Diag: Next")
-- end

-- ===== LSP Clients 多重起動防止 =====
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(args)
-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
--
-- 		if client then
-- 			on_attach(client, args.buf)
-- 		end
-- 	end,
-- })

-- ===== keymapセッティング読み込み =====
require("keymaps")
