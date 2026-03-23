-- ... this file is filled with pain

return {
  {
    "tiesen243/vercel.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local function apply_vercel_for_background()
        local theme = vim.o.background == "dark" and "dark" or "light"
        require("vercel").setup({
          theme = theme,
          transparent = false,
          italics = {
            comments = true,
            keywords = true,
            functions = true,
            strings = true,
            variables = true,
            bufferline = false,
          },
          overrides = {},
        })
        vim.cmd.colorscheme "vercel"
      end

      local function set_background_from_system()
        if vim.fn.has("mac") ~= 1 or vim.fn.executable("defaults") ~= 1 then
          apply_vercel_for_background()
          return
        end

        local output = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null")
        local next_bg = (type(output) == "string" and output:match("Dark")) and "dark" or "light"

        if vim.o.background ~= next_bg then
          vim.o.background = next_bg
          return
        end

        apply_vercel_for_background()
      end

      set_background_from_system()

      vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
        callback = set_background_from_system,
      })

      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = apply_vercel_for_background,
      })
    end,
  },
  "EdenEast/nightfox.nvim",
  {
    lazy = true,
    -- dir = "~/plugins/colorbuddy.nvim",
    "tjdevries/colorbuddy.nvim",
  },
  "rktjmp/lush.nvim",
  "tckmn/hotdog.vim",
  "dundargoc/fakedonalds.nvim",
  "craftzdog/solarized-osaka.nvim",
  { "rose-pine/neovim", name = "rose-pine" },
  "eldritch-theme/eldritch.nvim",
  "jesseleite/nvim-noirbuddy",
  "miikanissi/modus-themes.nvim",
  "rebelot/kanagawa.nvim",
  "gremble0/yellowbeans.nvim",
  "rockyzhang24/arctic.nvim",
  "folke/tokyonight.nvim",
  "Shatur/neovim-ayu",
  "RRethy/base16-nvim",
  "xero/miasma.nvim",
  "cocopon/iceberg.vim",
  "kepano/flexoki-neovim",
  "ntk148v/komau.vim",
  "uloco/bluloco.nvim",
  "LuRsT/austere.vim",
  "ricardoraposo/gruvbox-minor.nvim",
  "NTBBloodbath/sweetie.nvim",
  "vim-scripts/MountainDew.vim",
  {
    "maxmx03/fluoromachine.nvim",
    -- config = function()
    --   local fm = require "fluoromachine"
    --   fm.setup { glow = true, theme = "fluoromachine" }
    -- end,
  },
}
