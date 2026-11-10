return {
	"RRethy/base16-nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local p = require("kik.theme")
		require("base16-colorscheme").setup(p)

		-- LSP diagnostics get their own colors so they don't follow base08/base0E
		-- (base08 is purple in the active palette). Code syntax colors are untouched.
		local diag = {
			Error = "#fb4934",
			Warn = p.base0A,
			Info = p.base0D,
			Hint = p.base0C,
			Ok = p.base0B,
		}
		for name, fg in pairs(diag) do
			vim.api.nvim_set_hl(0, "Diagnostic" .. name, { fg = fg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. name, { fg = fg })
			vim.api.nvim_set_hl(0, "DiagnosticFloating" .. name, { fg = fg })
			vim.api.nvim_set_hl(0, "DiagnosticSign" .. name, { fg = fg, bg = p.base01 })
			vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. name, { undercurl = true, sp = fg })
		end
	end,
}
