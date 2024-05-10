return {
	'mfussenegger/nvim-dap',
	dependencies = {
		'mfussenegger/nvim-dap-python',
		'rcarriga/nvim-dap-ui',
		'folke/neodev.nvim',
		'nvim-neotest/nvim-nio'
	},
	config = function()
		-- Setup debug adapters and related stuff.
		require('dap-python').setup('~/.virtualenvs/arivo/bin/python')
		local configurations = require('dap').configurations.python

		for _, configuration in pairs(configurations) do
			configuration.justMyCode = false
		end

		-- dap.configurations = {
		-- javascript = {
		-- {
		-- name = 'Debug with Firefox',
		-- type = 'firefox',
		-- request = 'launch',
		-- reAttach = true,
		-- url = 'http://localhost:3000',
		-- webRoot = '${workspaceFolder}',
		-- firefoxExecutable = '/usr/bin/librewolf'
		-- }
		-- },
		-- typescript = {
		-- {
		-- name = 'Debug with Firefox',
		-- type = 'firefox',
		-- request = 'launch',
		-- reAttach = true,
		-- url = 'http://localhost:3000',
		-- webRoot = '${workspaceFolder}',
		-- firefoxExecutable = '/usr/bin/librewolf'
		-- }
		-- }
		-- }


		-- Setup Neodev
		require('neodev').setup({
			library = {
				plugins = { 'nvim-dap-ui' },
				types = true
			},
		})

		-- Setup DAP-UI
		require('dapui').setup()
		local dap, dapui = require('dap'), require('dapui')

		dap.listeners.after.event_initialized['dapui_config'] = function()
			dapui.open()
		end

		dap.listeners.before.event_terminated['dapui_config'] = function()
			dapui.close()
		end

		dap.listeners.before.event_exited['dapui_config'] = function()
			dapui.close()
		end
	end
}
