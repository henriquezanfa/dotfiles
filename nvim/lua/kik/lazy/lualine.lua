return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    local colors = {
      green  = '#a6e3a1',
      blue   = "#89b4fa",
      pink   = "#cba6f7",
      black  = '#11111b',
      white  = '#c6c6c6',
      red    = '#f38ba8',
      violet = '#d183e8',
      grey   = '#303030',
    }

    local bubbles_theme = {
      normal = {
        a = { fg = colors.black, bg = colors.blue },
        b = { fg = colors.white, bg = colors.grey },
        c = { fg = colors.white, bg = nil },
      },

      insert = { a = { fg = colors.black, bg = colors.green } },
      visual = { a = { fg = colors.black, bg = colors.pink } },
      replace = { a = { fg = colors.black, bg = colors.red } },
      command = { a = { fg = colors.black, bg = colors.red } },
      inactive = {
        a = { fg = colors.white, bg = colors.black },
        b = { fg = colors.white, bg = colors.black },
        c = { fg = colors.white, bg = nil },
      },
    }

    local function winbar_path()
      return ' '
    end

    return {
      options = {
        theme = bubbles_theme,
        component_separators = '',
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
        lualine_b = {
          'branch',
          'diagnostics'
        },
        lualine_x = {},
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {
          { 'location', separator = { right = '' }, left_padding = 2 },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      winbar = {
        lualine_c = { { winbar_path } },
      },
      inactive_winbar = {
        lualine_c = { { winbar_path } },
      },
      tabline = {},
      extensions = {},
    }
    end,
}
