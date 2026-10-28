vim.g.mapleader = " "
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })

vim.keymap.set("n", "<C-p>", "<C-b>") -- page up (C-b is vim's default)

vim.keymap.set({ "n", "t" }, "<leader>tt", function()
	vim.cmd("split term://zsh")
end, { silent = true, desc = "Toggle Terminal" })

vim.keymap.set({ "n", "t" }, "<leader>tv", function()
	vim.cmd("vsplit term://zsh")
end, { silent = true, desc = "Toggle Terminal" })

vim.keymap.set("v", "y", '"+y', {})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = { eob = " " }

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.exrc = true
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
vim.keymap.set("n", "gk", vim.lsp.buf.hover, { desc = "Hover" })
vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

vim.keymap.set("i", "jj", "<ESC>")

-- wraps with ', ", (, [, {
vim.keymap.set("v", '"', 'c""<ESC>P')
vim.keymap.set("v", "'", "c''<ESC>P")
vim.keymap.set("v", "(", "c()<ESC>P")
vim.keymap.set("v", "[", "c[]<ESC>P")
vim.keymap.set("v", "[", "c{}<ESC>P")
vim.keymap.set("v", "`", "c``<ESC>P")

-- resize
vim.keymap.set("n", "L", [[<cmd>vertical resize +5<cr>]]) -- make the window biger vertically
vim.keymap.set("n", "H", [[<cmd>vertical resize -5<cr>]]) -- make the window smaller vertically
vim.keymap.set("n", "J", [[<cmd>horizontal resize +2<cr>]]) -- make the window bigger horizontally by pressing shift and =
vim.keymap.set("n", "K", [[<cmd>horizontal resize -2<cr>]]) -- make the window smaller horizontally by pressing shift and -

vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")

-- markdown live preview
vim.keymap.set("n", "<leader>mp", "<cmd>LivePreview start<cr>", { desc = "Start LivePreview" })
