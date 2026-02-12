return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    enable_autosnippets = true,
  },
  config = function(_, opts)
    local ls = require("luasnip")
    if opts then
      ls.config.setup(opts)
    end

    -- Extend filetypes BEFORE loading snippets
    ls.filetype_extend("html", { "javascript", "css" })
    ls.filetype_extend("css", { "html" })
    ls.filetype_extend("javascriptreact", { "javascript" })
    ls.filetype_extend("typescriptreact", { "typescript", "javascript", "javascriptreact" })
    ls.filetype_extend("javascript", { "jsdoc" })
    ls.filetype_extend("typescript", { "tsdoc", "javascript" })
    ls.filetype_extend("python", { "pydoc" })
    ls.filetype_extend("c", { "cdoc" })
    ls.filetype_extend("cpp", { "cppdoc" })

    -- Load ALL friendly-snippets (remove the include parameter)

    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip").filetype_extend("markdown", { "tex" })

    -- Optional: load snipmate/lua snippets if you have local ones
    vim.tbl_map(function(type)
      require("luasnip.loaders.from_" .. type).lazy_load()
    end, { "snipmate", "lua" })
  end,
}
