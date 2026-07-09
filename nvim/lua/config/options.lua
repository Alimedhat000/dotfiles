-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Enable animations (some plugins check these globals)
vim.g.snacks_animate = true
vim.g.minianimate_disable = false

-- Enable line wrapping by default
vim.opt.wrap = true
