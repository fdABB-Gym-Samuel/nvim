-- Tokyonight's default gutter (#3b4261) is too low-contrast against the background.
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      on_highlights = function(hl, c)
        hl.LineNr = { fg = c.dark5 } -- #737aa2, clearly readable
        hl.LineNrAbove = { fg = c.dark5 }
        hl.LineNrBelow = { fg = c.dark5 }
        hl.CursorLineNr = { fg = c.orange, bold = true }
      end,
    },
  },
}
