return {
  "hrsh7th/nvim-cmp",
  -- override nvim-cmp setup
  opts = function(_, opts)
    -- opts parameter is the default lazyvim config
    -- change the mapping of the completion key
    opts.mapping["<Tab>"] = opts.mapping["<CR>"]
    opts.mapping["<CR>"] = nil
    return opts
  end,
}
