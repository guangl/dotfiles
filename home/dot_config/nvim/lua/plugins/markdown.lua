return {
  {
    "OXY2DEV/markview.nvim",
    opts = {
      preview = {
        enable = false,
        splitview_winopts = {
          split = "right",
        },
      },
    },
    keys = {
      {
        "<leader>mp",
        "<cmd>Markview splitToggle<cr>",
        desc = "Markdown 实时分屏预览",
      },
    },
  },
}
