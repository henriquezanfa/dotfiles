return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    fvm = true,
    lsp = {
      capabilities = capabilities,
      document_color = {
        enabled = true,
        virtual_text = true,
      },
    },
  }
}
