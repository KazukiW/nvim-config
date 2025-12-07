-- ~/.config/nvim/lua/snippets/c.lua

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep

-- C言語用スニペット群
local M = {}

-- fori: インデックス付きforループ
table.insert(
	M,
	s({ trig = "fori", dscr = "C-style indexed for loop" }, {
		t("for (int "),
		i(1, "i"),
		t(" = 0; "),
		rep(1),
		t(" < "),
		i(2, "n"),
		t("; "),
		rep(1),
		t("++"),
		t(") {"),
		t({ "", "    " }),
		i(3, "// TODO"),
		t({ "", "}" }),
	})
)

return M
