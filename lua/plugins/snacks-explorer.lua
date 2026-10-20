local function find_files()
  vim.cmd("FzfLua files")
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          win = {
            -- Keep global shortcuts available when the explorer has focus.
            input = {
              keys = {
                ["<c-n>"] = { "close", mode = { "n", "i" } },
                ["<c-p>"] = { find_files, mode = { "n", "i" }, desc = "Fuzzy find files" },
              },
            },
            list = {
              keys = {
                ["<c-n>"] = "close",
                ["<c-p>"] = { find_files, desc = "Fuzzy find files" },
              },
            },
          },
        },
      },
    },
  },
}
