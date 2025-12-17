local config = vim.fn.stdpath("config")
local codex = "~/.codex/sessions/"
local map = vim.keymap.set

map("i", "jj", "<Esc>", { noremap = true, silent = true })
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "gl", vim.diagnostic.open_float, { silent = true })

map("n", "<leader>vc", function()
	vim.cmd.edit(config .. "/init.lua")
end, { desc = "Edit init.lua" })

map("n", "<leader>vp", function()
	vim.cmd.edit(config .. "/lua/plugins/")
end, { desc = "Edit plugin specs" })

-- codex CLI用のconfigディレクトリを開く
map("n", "<leader>vx", function()
	vim.cmd.edit(codex)
end, { desc = "Jump to codex session" })

-- utils.lua or keymaps.lua 等に配置
-- 依存: jq が PATH 上にあること
vim.api.nvim_create_user_command("CodexFormat", function(opts)
	local buf = 0
	local src = vim.api.nvim_buf_get_name(buf)
	if src == "" then
		vim.notify(
			"CodexFormat: バッファがファイルに紐づいていません（:w してから）",
			vim.log.levels.ERROR
		)
		return
	end

	-- 1) 変換前バックアップ（デフォルト: 元ファイルと同ディレクトリ/.codex_backup/）
	local backup_dir = opts.args ~= "" and opts.args or (vim.fn.fnamemodify(src, ":h") .. "/.codex_backup")

	vim.fn.mkdir(backup_dir, "p")

	local ts = os.date("%Y%m%d-%H%M%S") -- ローカル時刻
	local base = vim.fn.fnamemodify(src, ":t")
	local backup_path = string.format("%s/%s.%s.bak", backup_dir, base, ts)

	-- バッファ内容をそのまま退避（元ログ保全の最後の砦）
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	vim.fn.writefile(lines, backup_path)
	local ok_write = pcall(vim.fn.writefile, lines, backup_path)
	if not ok_write then
		vim.notify("CodexFormat: バックアップ書き込みに失敗: " .. backup_path, vim.log.levels.ERROR)
		return
	end

	-- 2) jq で JSONL -> Q/A テキストへ変換（会話区切り + timestamp）
	local jq_prog = [[
def to_msg:
  if .type=="response_item"
     and .payload.type=="message"
     and (.payload.role=="user" or .payload.role=="assistant")
  then
    { t:(.timestamp//"")
    , role:(.payload.role)
    , text:(.payload.content | map(.text? // "") | join(""))
    }
  elif .type=="event_msg"
       and (.payload.type=="user_message" or .payload.type=="agent_message")
  then
    { t:(.timestamp//"")
    , role:(if .payload.type=="user_message" then "user" else "assistant" end)
    , text:(.payload.message // "")
    }
  else empty end;

def to_ri:
  select(.type=="response_item"
         and .payload.type=="message"
         and (.payload.role=="user" or .payload.role=="assistant"))
  | { t:(.timestamp//"")
    , role:(.payload.role)
    , text:(.payload.content | map(.text? // "") | join(""))
    };

def to_ev:
  select(.type=="event_msg"
         and (.payload.type=="user_message" or .payload.type=="agent_message"))
  | { t:(.timestamp//"")
    , role:(if .payload.type=="user_message" then "user" else "assistant" end)
    , text:(.payload.message // "")
    };

def skip_env:
  select(
  (
    .role=="user"
    and ((.text//"") | startswith("<environment_context>"))
    )
    | not
  );

def skip_empty:
  select((.text // "") | gsub("\\s+";"") | length > 0);

def norm:
  (. // "")
  | gsub("\r\n"; "\n")
  | gsub("\r"; "\n");

def ts_to_epoch:
  . as $in
  | ($in | tostring) as $s
  | if ($s | length) == 0 then
      null
    else
      # まずは ISO8601 を直接（ミリ秒付きも想定）
      (try ($s | fromdateiso8601)
       # ダメならミリ秒を削って strptime+mktime
       catch (try ($s
                   | sub("\\.[0-9]+Z$"; "Z")
                   | strptime("%Y-%m-%dT%H:%M:%SZ")
                   | mktime)
             catch null))
    end;
def fmt_ts_jst:
  . as $in
  | (ts_to_epoch) as $e
  | if $e == null then
      "(bad timestamp: " + ($in | tostring) + ")"
    else
      (($e + 9*3600) | strftime("%Y-%m-%d %H:%M:%S JST"))
    end;
def fmt:
  "---- " + ((.t // "") | fmt_ts_jst) + " ----\n"
  + (if .role=="user" then "Q:" else "A:" end) + "\n"
  + "    " + ((.text|norm) | gsub("\n"; "\n    "))
  + "\n";

def dedup($ri_pairs):
  select( ((.t + "\u0000" + .role) as $k | ($ri_pairs | index($k)) ) | not );

(
  [ .[] | to_ri ] as $ri
  | ($ri | map(.t + "\u0000" + .role)) as $ri_pairs
  | ( $ri
      + ([ .[] | to_ev | dedup($ri_pairs) ])
    )
  | map(skip_env)
)
| reduce .[] as $m
    ({ prev:null, out:"" };
      .out += (if ($m.role=="user" and .prev!=null and .prev!="user") then
                 "\n==============================\n\n"
               else "" end)
            + ($m|fmt)
      | .prev = $m.role
    )
| .out
]]

	vim.notify("lines type=" .. type(lines), vim.log.levels.WARN)
	-- もし in_lines を使っているなら、それも確認
	vim.notify("in_lines type=" .. type(in_lines), vim.log.levels.WARN)
	-- 3) バッファを stdin にして jq 実行（stderr を必ず取る）
	local input = table.concat(lines, "\n") .. "\n"

	local proc = vim.system({ "jq", "-r", "-s", jq_prog }, { text = true, stdin = input })
	local res = proc:wait()

	if res.code ~= 0 then
		-- 失敗時：バッファは一切触らず、jq の stderr を出す
		local msg = ("CodexFormat: jq が失敗しました (exit=%d)\nbackup: %s\n\nstderr:\n%s"):format(
			res.code,
			backup_path,
			(res.stderr ~= "" and res.stderr or "(no stderr)")
		)
		vim.notify(msg, vim.log.levels.ERROR)
		return
	end

	-- 4) 成功時：stdout でバッファを置換
	local out = res.stdout or ""
	local out_lines = vim.split(out, "\n", { plain = true })

	-- 末尾の空行を 1 個だけ残す/不要なら消す（好み）
	if #out_lines > 0 and out_lines[#out_lines] == "" then
		table.remove(out_lines, #out_lines)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, out_lines)

	vim.notify("CodexFormat: 変換完了（backup: " .. backup_path .. "）", vim.log.levels.INFO)
end, {
	desc = "Format Codex session JSONL into Q/A text (timestamp+delimiter+backup, robust errors)",
	nargs = "?", -- :CodexFormat {backup_dir}
})
