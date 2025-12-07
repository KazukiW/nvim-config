-- ~/.config/nvim/lua/snippets/cpp.lua

local ls = require("luasnip")

-- CのスニペットをC++に継承する
ls.filetype_extend("cpp", { "c" })

return {}
