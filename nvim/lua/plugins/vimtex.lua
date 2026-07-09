return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_view_method = "zathura"

    vim.g.vimtex_compiler_latexmk = {
      executable = "latexmk",
      out_dir = "build", -- ← tell VimTeX where the PDF lands
      options = {
        "-xelatex",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-file-line-error",
      },
    }

    vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<cr>")
  end,
}
