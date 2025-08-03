return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Tell tailwindcss server to also attach to HTML files
      tailwindcss = {
        filetypes = { "html", "css" },
      },
    },
  },
}
