-- The Codam/42 file header: Space c h (or :Stdheader) adds it, and saving
-- refreshes its "Updated" line. Login and email come from $USER42 / $MAIL42
-- (set them in your shell), falling back to $USER.
local M = {}

local LENGTH, MARGIN = 80, 5
local ART = {
	"        :::      ::::::::",
	"      :+:      :+:    :+:",
	"    +:+ +:+         +:+  ",
	"  +#+  +:+       +#+     ",
	"+#+#+#+#+#+   +#+        ",
	"     #+#    #+#          ",
	"    ###   ########.fr    ",
}

-- Comment start / end for each filetype
local DELIMS = {
	c = { "/*", "*/" }, cpp = { "/*", "*/" }, css = { "/*", "*/" }, javascript = { "/*", "*/" },
	typescript = { "/*", "*/" }, lua = { "--", "--" }, make = { "#", "#" }, python = { "#", "#" },
	sh = { "#", "#" }, bash = { "#", "#" }, zsh = { "#", "#" }, fish = { "#", "#" },
}

local function user() return vim.env.USER42 or vim.env.USER or "marvin" end
local function mail() return vim.env.MAIL42 or (user() .. "@student.codam.nl") end
local function now() return os.date("%Y/%m/%d %H:%M:%S") end

local function delims()
	local d = DELIMS[vim.bo.filetype] or { "#", "#" }
	return d[1], d[2]
end

local function line(left, right)
	local s, e = delims()
	left = left:sub(1, LENGTH - MARGIN * 2 - #right)
	return s .. (" "):rep(MARGIN - #s) .. left
		.. (" "):rep(LENGTH - MARGIN * 2 - #left - #right) .. right
		.. (" "):rep(MARGIN - #e) .. e
end

local function border()
	local s, e = delims()
	return s .. " " .. ("*"):rep(LENGTH - #s - #e - 2) .. " " .. e
end

local function build(created, author)
	local name = vim.fn.expand("%:t")
	return {
		border(),
		line("", ""),
		line("", ART[1]),
		line(name, ART[2]),
		line("", ART[3]),
		line("By: " .. user() .. " <" .. mail() .. ">", ART[4]),
		line("", ART[5]),
		line("Created: " .. created .. " by " .. author, ART[6]),
		line("Updated: " .. now() .. " by " .. user(), ART[7]),
		line("", ""),
		border(),
	}
end

local function has_header(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, 11, false)
	return #lines == 11 and lines[9]:find("Updated: ") ~= nil and lines[1]:find("%*%*%*%*") ~= nil
end

function M.insert()
	local buf = vim.api.nvim_get_current_buf()
	if has_header(buf) then
		-- Already there: just refresh the file name and Updated line
		return M.update(buf, true)
	end
	vim.api.nvim_buf_set_lines(buf, 0, 0, false, vim.list_extend(build(now(), user()), { "" }))
end

function M.update(buf, force)
	if not has_header(buf) or not (force or vim.bo[buf].modified) then
		return
	end
	local lines = vim.api.nvim_buf_get_lines(buf, 0, 11, false)
	local created, author = lines[8]:match("Created: (%S+ %S+) by (%S+)")
	local fresh = build(created or now(), author or user())
	-- Only rewrite the two lines that change, so undo stays tidy
	vim.api.nvim_buf_set_lines(buf, 3, 4, false, { fresh[4] })
	vim.api.nvim_buf_set_lines(buf, 8, 9, false, { fresh[9] })
end

function M.setup()
	vim.api.nvim_create_user_command("Stdheader", M.insert, { desc = "Insert the 42 header" })
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("header42", { clear = true }),
		callback = function(args) M.update(args.buf) end,
	})
end

return M
