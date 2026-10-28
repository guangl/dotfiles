return {
  {
    "saghen/blink.cmp",
    opts = {
      cmdline = {
        keymap = {
          preset = "cmdline",

          ["<Tab>"] = {
            "show_and_insert_or_accept_single",
            "select_next",
          },

          ["<S-Tab>"] = {
            "show_and_insert_or_accept_single",
            "select_prev",
          },
        },

        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },

          menu = {
            auto_show = function() return vim.fn.getcmdtype() == ":" end,
          },
        },
      },
    },
  },
}
