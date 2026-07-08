local function smart_move(direction, tmux_cmd)
  local nr = vim.fn.winnr()
  vim.cmd('wincmd ' .. direction)
  if nr == vim.fn.winnr() then
    vim.fn.system('tmux select-pane ' .. tmux_cmd)
  end
end

vim.keymap.set('n', '<C-h>', function() smart_move('h', '-L') end, { silent = true })
vim.keymap.set('n', '<C-j>', function() smart_move('j', '-D') end, { silent = true })
vim.keymap.set('n', '<C-k>', function() smart_move('k', '-U') end, { silent = true })
vim.keymap.set('n', '<C-l>', function() smart_move('l', '-R') end, { silent = true })

-- netrw maps <C-l> buffer-locally (directory refresh), overriding the global binding above
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'netrw',
  callback = function()
    vim.keymap.set('n', '<C-l>', function() smart_move('l', '-R') end, { silent = true, buffer = true })
    vim.keymap.set('n', 'q', '<C-w>z', { silent = true, buffer = true })
  end,
})
