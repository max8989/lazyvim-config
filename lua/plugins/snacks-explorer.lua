return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          win = {
            -- Keep Ctrl+N as the toggle when the explorer has focus.
            input = {
              keys = {
                ["<c-n>"] = { "close", mode = { "n", "i" } },
              },
            },
            list = {
              keys = {
                ["<c-n>"] = "close",
              },
            },
          },
        },
      },
    },
  },
}
