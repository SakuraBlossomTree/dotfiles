-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
  return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
  return
end

local keymap = vim.keymap -- for conciseness

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
  -- keybind options
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- typescript specific keymaps (e.g. rename file and update imports)
  if client.name == "tsserver" then
    keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
    keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports (not in youtube nvim video)
    keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables (not in youtube nvim video)
  end
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- configure html server
lspconfig["html"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure css server
lspconfig["cssls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig["pyright"].setup({

    cmd = { "pyright-langserver", "--stdio" },
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { "python" },
    root_dir = function(fname)
        return require("lspconfig.util").find_git_ancestor(fname) or vim.fn.getcwd()
    end,
})

lspconfig["jdtls"].setup({
    cmd = { 'jdtls' },
    root_dir = function(fname)
        return require("lspconfig.util").find_git_ancestor(fname) or vim.fn.getcwd()
    end,
    settings = {
        java = {
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-21",
                        path = "/usr/lib/jvm/java-21-openjdk",
                    },
                },
            },
        },
    },
})


local pid = vim.fn.getpid()

lspconfig["omnisharp"].setup({
    cmd = { "/usr/bin/OmniSharp", "--languageserver", "--hostPID", tostring(pid) },
    capabilities = capabilities,
    on_attach = on_attach,
    enable_roslyn_analyzers = true,  -- Enables advanced analysis
    organize_imports_on_format = true,  -- Automatically organizes imports
    enable_import_completion = true,  -- Enables auto-imports
    root_dir = function(fname)
        return require("lspconfig.util").find_git_ancestor(fname) or vim.fn.getcwd()
    end,
    filetypes = { "cs", "vb" },  -- Ensures it attaches to C# and VB files
})
