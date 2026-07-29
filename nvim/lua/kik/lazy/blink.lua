return {
  "saghen/blink.cmp",
  version = "*",
  event = "InsertEnter",
  opts = {
    keymap = {
      preset = "super-tab",
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "accept", "fallback" },
    },
    appearance = { nerd_font_variant = "mono" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      list = { selection = { preselect = false, auto_insert = false } },
    },
    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}
