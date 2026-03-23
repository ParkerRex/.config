local M = {}

M.setup = function()
  -- Simple, standard nvim-treesitter setup
  require("nvim-treesitter.configs").setup {
    ensure_installed = {
      "typescript",
      "tsx",
      "javascript",
      "html",
      "css",
      "json",
      "markdown",
      "markdown_inline",
      "elixir",
      "heex",
      "lua",
      "vim",
      "vimdoc",
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  }
end

return M
