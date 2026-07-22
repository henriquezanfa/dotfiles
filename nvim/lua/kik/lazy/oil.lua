return {
  "stevearc/oil.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    -- Add Git status support for Oil
    {
      "malewicz1337/oil-git.nvim",
      dependencies = { "stevearc/oil.nvim" },
      opts = {
        show_file_highlights = true,
        show_directory_highlights = true,
      },
    },
  },
  opts = {
    columns = {
      "icon",
    },
    win_options = {
      signcolumn = "yes:2", -- Reserves window gutter space for Git status signs
    },
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["<C-h>"] = false, -- Disable Oil's horizontal split keymap
      ["<C-l>"] = false, -- Disable Oil's horizontal split keymap
      ["<C-a>"] = { "actions.select", opts = { vertical = true } },
      ["<C-u>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-t>"] = { "actions.select", opts = { tab = true } },
      ["<C-p>"] = "actions.preview",
    },
  },
}
