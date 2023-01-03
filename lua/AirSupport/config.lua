local M = {}

local defaults = {
    telescope_new_file_shortcut = "<C-n>",
    telescope_delete_file_shortcut = "<C-d>",
    telescope_edit_file_shortcut = "<C-e>"
}

M.options = {}

function M.setup(opts)
    opts = opts or {}
    M.options = vim.tbl_deep_extend("force", defaults, opts)
end

M.setup()

return M
