return {
  "nvim-mini/mini.surround",
  opts = {
    -- Define custom surround behaviors
    custom_surrounds = {
      ["`"] = { output = { left = "```", right = "```" } },
      ["'"] = { output = { left = "'", right = "'" } },
      ["("] = { output = { left = "(", right = ")" } },
      ["["] = { output = { left = "[", right = "]" } },
      ["{"] = { output = { left = "{", right = "}" } },
      ["<"] = { output = { left = "<", right = ">" } },

      -- Surround with HTML tag
      ["t"] = {
        -- Ask user for a tag name and build dynamic pair
        output = function()
          local tag = vim.fn.input("Tag name: ")
          if tag == "" then
            return nil
          end
          return { left = "<" .. tag .. ">", right = "</" .. tag .. ">" }
        end,
        -- Optional: detection pattern for existing tags (used in delete/replace)
        input = { "<([%w-]+)[^>]->.-</%1>", "^<.->().*()</[^/]->$" },
      },
    },

    mappings = {
      add = "gsa", -- Add surrounding in Normal and Visual modes
      delete = "gsd", -- Delete surrounding
      find = "gsf", -- Find surrounding (to the right)
      find_left = "gsF", -- Find surrounding (to the left)
      highlight = "gsh", -- Highlight surrounding
      replace = "gsr", -- Replace surrounding
      update_n_lines = "gsn", -- Update `n_lines`
    },
  },

  keys = function(_, keys)
    local opts = LazyVim.opts("mini.surround")
    local mappings = {
      { opts.mappings.add, desc = "Add Surrounding", mode = { "n", "x" } },
      { opts.mappings.delete, desc = "Delete Surrounding" },
      { opts.mappings.find, desc = "Find Right Surrounding" },
      { opts.mappings.find_left, desc = "Find Left Surrounding" },
      { opts.mappings.highlight, desc = "Highlight Surrounding" },
      { opts.mappings.replace, desc = "Replace Surrounding" },
      { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
    }
    mappings = vim.tbl_filter(function(m)
      return m[1] and #m[1] > 0
    end, mappings)
    return vim.list_extend(mappings, keys)
  end,
}
