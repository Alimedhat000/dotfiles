return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  init = function()
    -- Use latexmk as the compiler
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_view_method = "zathura"
    -- Configure latexmk for XeLaTeX
    vim.g.vimtex_compiler_latexmk = {
      executable = "latexmk",
      options = {
        "-xelatex", -- use XeLaTeX
        "-synctex=1", -- enable synctex
        "-interaction=nonstopmode",
        "-file-line-error",
        "-outdir=build",
      },
    }

    vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<return>")
  end,
}
