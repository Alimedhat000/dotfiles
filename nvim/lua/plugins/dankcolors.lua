return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#0f1417',
				base01 = '#0f1417',
				base02 = '#92999d',
				base03 = '#92999d',
				base04 = '#eff9ff',
				base05 = '#f8fcff',
				base06 = '#f8fcff',
				base07 = '#f8fcff',
				base08 = '#ff9fbd',
				base09 = '#ff9fbd',
				base0A = '#a5deff',
				base0B = '#a5ffb0',
				base0C = '#cfeeff',
				base0D = '#a5deff',
				base0E = '#b5e4ff',
				base0F = '#b5e4ff',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#92999d',
				fg = '#f8fcff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#a5deff',
				fg = '#0f1417',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#92999d' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#cfeeff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#b5e4ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#a5deff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#a5deff',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#cfeeff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#a5ffb0',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#eff9ff' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#eff9ff' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#92999d',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
