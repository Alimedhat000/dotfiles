return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--compile-commands-dir=.",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
          },
        },
      },
    },
  },
}
