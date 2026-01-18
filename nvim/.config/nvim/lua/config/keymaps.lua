-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
-- Select All
keymap.set("n", "<Leader>a", "gg<S-v>G", { noremap = true, silent = true, desc = "Select All" })

-- Move between tabs
keymap.set("n", "<tab>", ":bnext<Return>", opts)
keymap.set("n", "<s-tab>", ":bprevious<Return>", opts)

-- splitting windows
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

--move between splits
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")

--Better Esc
keymap.set("i", "jj", "<Esc>", opts)
keymap.set("i", "jk", "<Esc>", opts)

--IncRename
keymap.set("n", "<Leader>rn", ":IncRename ")

--CommentSegment
keymap.set("n", "<Leader>c/", "gcc", { remap = true, desc = "Toggle comment line" })
keymap.set("v", "<Leader>c/", "gc", { remap = true, desc = "Toggle comment selection" })

--Move down and Up cneter page
keymap.set("n", "<C-d>", "<C-d>zz", opts)
keymap.set("n", "<C-u>", "<C-u>zz", opts)
keymap.set("n", "n", "nzzzv", opts)
keymap.set("n", "N", "Nzzzv", opts)

keymap.set("n", "q:", "<Nop>", opts)

keymap.set("n", "<C-z>", "<Nop>", opts)

-- Make Ctrl Backspace delete one word in insert mode
keymap.set("i", "<C-h>", "<C-w>", { noremap = true, silent = true })
keymap.set("i", "<C-BS>", "<C-w>", { noremap = true, silent = true })
