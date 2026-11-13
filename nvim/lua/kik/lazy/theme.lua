return {
	"RRethy/base16-nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local p = require("kik.theme")
		require("base16-colorscheme").setup(p)

		-- LSP diagnostics get their own colors so they don't follow base08/base0E
		-- (base08 is purple in the active palette). Code syntax colors are untouched.
		-- Floating pickers: visible pink borders like sesh, raised bg to separate from the editor.
		local function float_hl()
			local border = { fg = p.base0E, bg = p.base01 }
			local set = vim.api.nvim_set_hl
			set(0, "NormalFloat", { fg = p.base05, bg = p.base01 })
			set(0, "FloatBorder", border)
			set(0, "FloatTitle", { fg = p.base0E, bg = p.base01, bold = true })
			set(0, "TelescopeNormal", { fg = p.base05, bg = p.base01 })
			set(0, "TelescopeBorder", border)
			set(0, "TelescopePromptNormal", { fg = p.base05, bg = p.base01 })
			set(0, "TelescopePromptBorder", border)
			set(0, "TelescopePromptTitle", { fg = p.base0E, bg = p.base01, bold = true })
			set(0, "TelescopeResultsNormal", { fg = p.base05, bg = p.base01 })
			set(0, "TelescopeResultsBorder", border)
			set(0, "TelescopeResultsTitle", { fg = p.base0E, bg = p.base01, bold = true })
			set(0, "TelescopePreviewNormal", { fg = p.base05, bg = p.base01 })
			set(0, "TelescopePreviewBorder", border)
			set(0, "TelescopePreviewTitle", { fg = p.base0E, bg = p.base01, bold = true })
			set(0, "TelescopeSelection", { fg = p.base07, bg = p.base02, bold = true })
			set(0, "TelescopeMatching", { fg = p.base0A, bold = true })
		end
		float_hl()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = float_hl })

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
