vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.clipboard = "unnamedplus" -- fix copy paste

vim.g.mapleader = " "
vim.keymap.set("n", "<Leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- install lazy plugin manager
local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(path) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", path })
end
vim.opt.rtp:prepend(path)

-- language servers
local servers = {
  ["typescript-language-server"] = { -- name in mason package
    pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" }, -- where to start server
    cmd = { "typescript-language-server", "--stdio" }, -- command to start server
  },
  ["lua-language-server"] = {
    pattern = { "lua" },
    cmd = { "lua-language-server" },
    settings = { Lua = { diagnostics = { globals = { "vim" } } } },
  },
}

-- plugins
require("lazy").setup({
  { "nvim-tree/nvim-tree.lua", config = true}, -- file explorer
  { "christoomey/vim-tmux-navigator"}, -- tmux navigation integration
  { -- Mason - downloads binary deps for servers
    "williamboman/mason.nvim",
    config = true,
    opts = { ensure_installed = vim.tbl_keys(servers)} -- install servers
  },
  { -- autocomplete
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
	mapping = {
	  ["<C-Space>"] = cmp.mapping.complete(), -- show autocomplete
	  ["<CR>"] = cmp.mapping.confirm({ select = true }), -- auto-select first item
	},
	sources = { { name = "nvim_lsp" } }, -- only show lsp suggestins, no snippets, buffer path
      })
    end,
  }
})

-- LSP setup
local capabilities = require("cmp_nvim_lsp").default_capabilities()

for pkg, cfg in pairs(servers) do -- register all LSPs
  vim.api.nvim_create_autocmd("FileType", {
    pattern = cfg.pattern,
    callback = function()
      vim.lsp.start({
        name = pkg,           -- LSP name = mason package name (OK)
        cmd = cfg.cmd,
        settings = cfg.settings,
        capabilities = capabilities,
      })
    end,
  })
end
