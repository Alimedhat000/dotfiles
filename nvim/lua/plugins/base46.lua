local function load_dms_extras()
  local present, base46 = pcall(require, "base46")
  if not present then
    return
  end

  local theme_name = "dms"
  local t = base46.theme_tables[theme_name]
  if not t then
    return
  end

  local c = t.base_30
  local dim = "#aeaeae"

  vim.api.nvim_set_hl(0, "Normal", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalNC", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "Conceal", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "NonText", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SpecialKey", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "Comment", { fg = dim, bg = "NONE", italic = true })
  vim.api.nvim_set_hl(0, "SignColumn", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FoldColumn", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "LineNr", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.white, bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FloatTitle", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "FloatFooter", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "Pmenu", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "PmenuSel", { fg = c.white, bg = c.one_bg })
  vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "PmenuThumb", { fg = dim })
  vim.api.nvim_set_hl(0, "Visual", { fg = c.black, bg = c.teal })
  vim.api.nvim_set_hl(0, "VisualNOS", { fg = c.black, bg = c.teal })
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = c.grey, bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLine", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksNormal", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksNormalNC", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksNormalFloat", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksWinBar", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksWinBarNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksTitle", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksFooter", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksWinSeparator", { fg = c.grey, bg = "NONE" })

  vim.api.nvim_set_hl(0, "SnacksPickerNormal", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerNormalNC", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerNormalFloat", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerFloatBorder", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerTitle", { fg = c.white, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerFooter", { fg = dim, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerWinBar", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerWinBarNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerWinSeparator", { fg = c.grey, bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksPickerDirectory", { fg = c.folder_bg or c.teal or c.cyan, bold = true })
  vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = dim })
  vim.api.nvim_set_hl(0, "SnacksPickerTree", { fg = dim })
  vim.api.nvim_set_hl(0, "Directory", { fg = c.folder_bg or c.teal or c.cyan, bold = true })
  vim.api.nvim_set_hl(0, "SnacksPickerDimmed", { fg = dim })
  vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { fg = dim })
  vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = dim })
  vim.api.nvim_set_hl(0, "SnacksPickerUnselected", { fg = dim })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "dms",
  callback = load_dms_extras,
})

return {
  "AvengeMedia/base46",
  lazy = false,
  opts = {},
  config = function()
    vim.cmd.colorscheme("dms")
    load_dms_extras()
  end,
}
