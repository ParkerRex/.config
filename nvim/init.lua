--[[
-- Setup initial configuration,
--
-- Primarily just download and execute lazy.nvim
--]]
vim.g.mapleader = ","

-- GUI font (used by Neovide/Gui clients)
vim.opt.guifont = "Berkeley Mono:h13"
-- Colorschemes expect truecolor; set early to avoid "termguicolors must be set".
vim.opt.termguicolors = true

-- Load dotenv, if it exists
require("custom.dotenv").eval(vim.fs.joinpath(vim.fn.stdpath "config", ".env")) ---@diagnostic disable-line: param-type-mismatch

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end

-- Add lazy to the `runtimepath`, this allows us to `require` it.
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Set up lazy, and load my `lua/custom/plugins/` folder
require("lazy").setup({ import = "custom/plugins" }, {
	change_detection = {
		notify = false,
	},
})
