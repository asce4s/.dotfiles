return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	config = function()
		require("nvim-treesitter.config").setup({
			textobjects = {
				select = {
					enable = true,
					lookahead = true, -- Jump forward automatically to textobject

					keymaps = {
						-- Functions
						["af"] = { query = "@function.outer", desc = "Around function" },
						["if"] = { query = "@function.inner", desc = "Inside function" },

						-- Classes
						["ac"] = { query = "@class.outer", desc = "Around class" },
						["ic"] = { query = "@class.inner", desc = "Inside class" },

						-- Parameters / Arguments
						["aa"] = { query = "@parameter.outer", desc = "Around parameter" },
						["ia"] = { query = "@parameter.inner", desc = "Inside parameter" },

						-- Imports (ESM, CommonJS)
						["ai"] = { query = "@import.outer", desc = "Around import" },
						["ii"] = { query = "@import.inner", desc = "Inside import" },

						-- Loops
						["al"] = { query = "@loop.outer", desc = "Around loop" },
						["il"] = { query = "@loop.inner", desc = "Inside loop" },

						-- JSX / TSX Elements
						["at"] = { query = "@jsx_element.outer", desc = "Around JSX element" },
						["it"] = { query = "@jsx_element.inner", desc = "Inside JSX element" },
					},
				},

				move = {
					enable = true,
					set_jumps = true,

					goto_next_start = {
						["]f"] = { query = "@function.outer", desc = "Next function" },
						["]c"] = { query = "@class.outer", desc = "Next class" },
						["]i"] = { query = "@import.outer", desc = "Next import" },
						["]t"] = { query = "@jsx_element.outer", desc = "Next JSX tag" },
					},
					goto_previous_start = {
						["[f"] = { query = "@function.outer", desc = "Previous function" },
						["[c"] = { query = "@class.outer", desc = "Previous class" },
						["[i"] = { query = "@import.outer", desc = "Previous import" },
						["[t"] = { query = "@jsx_element.outer", desc = "Previous JSX tag" },
					},
				},

				swap = {
					enable = true,
					swap_next = {
						["<leader>sp"] = { query = "@parameter.inner", desc = "Swap parameter with next" },
					},
					swap_previous = {
						["<leader>sP"] = { query = "@parameter.inner", desc = "Swap parameter with previous" },
					},
				},
			},
		})
	end,
}
