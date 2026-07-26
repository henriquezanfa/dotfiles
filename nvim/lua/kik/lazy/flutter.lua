return {
	"akinsho/flutter-tools.nvim",
	lazy = false,
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		require("flutter-tools").setup({
			fvm = true,
			lsp = {
				capabilities = capabilities,
				document_color = {
					enabled = true,
					virtual_text = true,
				},
			},
		})
	end,
}
