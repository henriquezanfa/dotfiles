return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    chunk = {
      enable = true,
      use_treesitter = true,
      chars = {
        horizontal_line = "-",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = "─",
      },
      style = "#403b61",
      duration = 30,
      delay = 50,
    },
    indent = {
      enable = false,
    },
    line_num = {
      enable = false,
    },
    blank = {
      enable = false,
    },
  },
}
