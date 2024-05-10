return {
	'neovim/nvim-lspconfig',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = {
		'hrsh7th/cmp-nvim-lsp',
		'williamboman/mason-lspconfig.nvim',
		'folke/neodev.nvim'
	},
	config = function()
		local lspconfig = require('lspconfig')
		local mason_lspconfig = require('mason-lspconfig')
		local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

		vim.api.nvim_create_autocmd('LspAttach', {
			group = vim.api.nvim_create_augroup('UserLspConfig', {}),
			callback = function(ev)
				vim.api.nvim_buf_set_option(ev.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

				local dap = require('dap')
				local widgets = require('dap.ui.widgets')
				local bufopts = { noremap = true, silent = true, buffer = ev.buf }

				vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
				vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
				vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
				vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
				vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, bufopts)
				vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
				vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
				vim.keymap.set('n', '<leader>wl', function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, bufopts)

				vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
				vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
				vim.keymap.set('n', '<leader>co', vim.lsp.buf.code_action, bufopts)
				vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
				vim.keymap.set('n', '<leader>fc', function() vim.lsp.buf.format { async = true } end, bufopts)

				vim.keymap.set('n', '<F2>', function() dap.step_out() end)
				vim.keymap.set('n', '<F3>', function() dap.step_over() end)
				vim.keymap.set('n', '<F4>', function() dap.step_into() end)
				vim.keymap.set('n', '<F5>', function() dap.continue() end)

				vim.keymap.set('n', '<F7>', function() dap.toggle_breakpoint() end)
				vim.keymap.set('n', '<F8>', function() dap.set_breakpoint() end)

				vim.keymap.set('n', '<F9>', function() dap.disconnect() end)
				vim.keymap.set('n', '<F10>', function() dap.close() end)
				vim.keymap.set('n', '<F11',
					function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
				-- vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
				vim.keymap.set('n', '<leader>dr', function() dap.run_last() end)
				vim.keymap.set('n', '<leader>db', function() dap.clear_breakpoints() end)
				vim.keymap.set('n', '<leader>dl', function() dap.list_breakpoints() end)

				vim.keymap.set({ 'n', 'v' }, '<leader>dh', function() widgets.hover() end)
				vim.keymap.set({ 'n', 'v' }, '<leader>dp', function() widgets.preview() end)
				vim.keymap.set('n', '<leader>df', function() widgets.centered_float(widgets.frames) end)
				vim.keymap.set('n', '<leader>ds', function() widgets.centered_float(widgets.scopes) end)
			end
		})

		-- Always install servers
		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				'bashls',
				'cssls',
				'docker_compose_language_service',
				'dockerls',
				'intelephense',
				'lua_ls',
				'pylsp',
				'tsserver',
				'vimls'
			},
		})
		-- Auto handled LSP from mason.
		mason_lspconfig.setup_handlers({
			function(server_name)
				local server_opts = {
					-- 	on_attach = on_attach,
					capabilities = capabilities
				}

				if server_name == 'lua_ls' then
					server_opts['settings'] = {
						Lua = {
							diagnostics = {
								globals = { 'vim' }
							},
							runtime = {
								version = 'LuaJIT',
							},
						}
					}
				end

				lspconfig[server_name].setup(server_opts)
			end
		})

		-- Setup Dart LSP
		lspconfig.dartls.setup({
			on_attach = on_attach,
		})

		-- Setup Null-Ls
		-- local null_ls = require('null-ls')
		-- null_ls.setup({
		-- 	sources = {
		-- 		null_ls.builtins.completion.luasnip,
		-- 		null_ls.builtins.diagnostics.codespell,
		-- 	},
		-- })

		-- Configure custom signs for diagnostics.
		local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end

		-- Set diagnostic keymaps.
		local diagnostic_opts = { noremap = true, silent = true }
		vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, diagnostic_opts)
		vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, diagnostic_opts)
		vim.keymap.set('n', ']d', vim.diagnostic.goto_next, diagnostic_opts)
		vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, diagnostic_opts)

		-- Configure LSP diagnostics behaviour
		vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			virtual_text = {
				enabled = true,
				prefix = ' ',
			},
			signs = true,
			underline = true,
			update_in_insert = false,
		})
	end
}
