return {
	"RRethy/base16-nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("base16-colorscheme").setup(require("kik.theme"))
	end,
}
