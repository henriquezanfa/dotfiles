return {
	'nvim-telescope/telescope.nvim', version = '*',
	dependencies = {
		'nvim-lua/plenary.nvim',
		-- optional but recommended
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	},
	config = function()
		require('telescope').setup({
			defaults = {
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				prompt_prefix = "  ",
				selection_caret = "▌ ",
			},
		})

		local preview_utils = require("telescope.previewers.utils")
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
		vim.keymap.set('n', '<C-p>', builtin.git_files, {})
	end
}
