-- Debugger: breakpoints, stepping, variables (VS Code's Run and Debug).
-- C/C++ uses codelldb, Python uses debugpy; Mason installs both.
-- Compile C with -g (Space r r and the Codam Makefiles usually do).
return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		"theHamsta/nvim-dap-virtual-text",
		"jay-babu/mason-nvim-dap.nvim",
	},
	keys = {
		{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint (toggle)" },
		{ "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint (toggle)" },
		{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Stop when: ")) end,
			desc = "Breakpoint with condition" },
		{ "<leader>dc", function() require("dap").continue() end, desc = "Start / continue" },
		{ "<F6>", function() require("dap").continue() end, desc = "Start / continue" },
		{ "<leader>dn", function() require("dap").step_over() end, desc = "Step over (next line)" },
		{ "<F10>", function() require("dap").step_over() end, desc = "Step over" },
		{ "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
		{ "<leader>do", function() require("dap").step_out() end, desc = "Step out" },
		{ "<leader>dr", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
		{ "<leader>dq", function() require("dap").terminate() end, desc = "Stop debugging" },
		{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug panels (toggle)" },
		{ "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Value of this" },
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		require("mason-nvim-dap").setup({
			ensure_installed = { "codelldb", "python" },
			handlers = {}, -- default launch setups for each debugger
		})
		dapui.setup()
		require("nvim-dap-virtual-text").setup({})

		-- C/C++: ask which program to debug, defaulting to the last one
		local last_program
		dap.configurations.c = {
			{
				name = "Debug a program",
				type = "codelldb",
				request = "launch",
				program = function()
					last_program = vim.fn.input("Program: ", last_program or (vim.fn.getcwd() .. "/"), "file")
					return last_program
				end,
				args = function()
					local args = vim.fn.input("Arguments: ")
					return vim.split(args, " ", { trimempty = true })
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
		}
		dap.configurations.cpp = dap.configurations.c

		-- Panels open when debugging starts and close when it ends
		dap.listeners.after.event_initialized.dapui = dapui.open
		dap.listeners.before.event_terminated.dapui = dapui.close
		dap.listeners.before.event_exited.dapui = dapui.close

		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint" })
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "CursorLine" })
	end,
}
