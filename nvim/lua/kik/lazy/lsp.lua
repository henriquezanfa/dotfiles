return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason.nvim",
    { "mason-org/mason-lspconfig.nvim", config = function() end },
    "saghen/blink.cmp",
  },
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    },
    inlay_hints = {
      enabled = true,
      exclude = { "vue" },
    },
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            completion = { callSnippet = "Replace" },
            doc = { privateName = { "^_" } },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      },
    },
  },
  config = function(_, opts)
    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

    local on_attach = function(_, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
      map("n", "gr", vim.lsp.buf.references, "References")
      map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
      map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")
      map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
      map("n", "gk", vim.lsp.buf.hover, "Hover")
      map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
      map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
      map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    end

    if opts.inlay_hints.enabled then
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end,
      })
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
          on_attach(client, args.buf)
        end
      end,
    })

    local capabilities = require("blink.cmp").get_lsp_capabilities()

    local servers = opts.servers or {}
    local ensure_installed = {}
    for server, server_opts in pairs(servers) do
      if server_opts then
        server_opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
        vim.lsp.config(server, server_opts)
        table.insert(ensure_installed, server)
      end
    end

    require("mason-lspconfig").setup({
      ensure_installed = ensure_installed,
      automatic_enable = true,
    })
  end,
}
