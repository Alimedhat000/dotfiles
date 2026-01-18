return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "L3MON4D3/LuaSnip" },
  opts = function(_, opts)
    -- keep existing opts
    opts.extensions = opts.extensions or {}
    opts.extensions.luasnip = {}
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension("luasnip")
  end,
}
