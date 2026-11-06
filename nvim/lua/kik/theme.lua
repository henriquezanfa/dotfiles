local M = {}

local path = vim.fn.expand("~/.config/theme/palette.conf")

for line in io.lines(path) do
  local key, hex = line:match('@(base%x%x)%s+"(#%x+)"')
  if key then
    M[key] = hex
  end
end

return M
