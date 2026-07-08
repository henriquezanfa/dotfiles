vim.g.mapleader = " "
vim.keymap.set("n", "-", vim.cmd.Ex)

vim.keymap.set("n", "<C-p>", "<C-b>")  -- page up (C-b is vim's default)

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.exrc = true
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

vim.keymap.set("i", "jj", "<ESC>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")


