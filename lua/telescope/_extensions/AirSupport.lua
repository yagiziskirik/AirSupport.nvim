local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"
local entry_display = require("telescope.pickers.entry_display")
local airSupportConfig = require("AirSupport.config").options

-- local conf = require("telescope.config").values

local style = {
  layout_strategy = "horizontal",
  layout_config = {
    height = 0.9,
    width = 0.8,
  },
}

vim.api.nvim_set_hl(0, "particleName", { link="String" })
vim.api.nvim_set_hl(0, "particleCommand", { link="Keyword" })
vim.api.nvim_set_hl(0, "particleShortcut", { link="Statement" })
vim.api.nvim_set_hl(0, "particleExplanation", { link="Include" })

local function enter(prompt_bufnr)
  local selected = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  if selected.command ~= "none" then
    if string.find(selected.command, "{input}") then
      vim.api.nvim_feedkeys(string.gsub(selected.command, "{input}", ""), "n", true)
    else
      vim.cmd(selected.command)
    end
  end
end

local function printTypeCommand(path)
  if vim.fn.has("win32") == 1 then
    return { "cmd.exe", "/c", "type", path }
  else
    if vim.fn.executable("bat") == 1 then
      return { "bat", "--style=plain", "--color=always", "--paging=always", path }
    else
      return { "cat", path }
    end
  end
end

local function getConfigPath()
  return vim.fn.stdpath("config")
end

local function checkCreateDirectory()
  local conf_path = getConfigPath()
  if vim.fn.isdirectory(conf_path .. "AirSupport") ~= 0 then
    return true
  else
    if vim.fn.has("win32") == 1 then
      os.execute("mkdir " .. conf_path .. "\\AirSupport")
    else
      os.execute("mkdir " .. conf_path .. "/AirSupport")
    end
  end
end

local function concatParticles()
  checkCreateDirectory()
  local conf_path = getConfigPath()
  return vim.split(vim.fn.glob(conf_path .. "/AirSupport/particle-*.md"), "\n", {plain = true})
end

local function createParticleDictionary()
  local particles = concatParticles()
  local returnVal = {}
  if particles[1] ~= "" then
    for _, particle in pairs(particles) do
      local shortExp = ""
      local name = ""
      local shortcut = "none"
      local command = "none"
      local file = io.open(particle, "r")
      if file ~= nil then
        local allValues = {}
        for value in file:lines() do
          table.insert(allValues, value)
        end
        for i, val in ipairs(allValues) do
          if string.find(val, "## Command") then
            if allValues[i+1] ~= "{nil}" then
              command = allValues[i+1]
            end
          end
          if string.find(val, "## Short Explanation") then
            shortExp = allValues[i+1]
          end
          if string.find(val, "## Shortcut") then
            if allValues[i+1] ~= "{nil}" then
              shortcut = allValues[i+1]
            end
          end
        end
        name = string.sub(allValues[1], 3)
      end
      table.insert(returnVal, { name, command, shortcut, shortExp, particle })
    end
  end
  return returnVal
end

local function newFile(prompt_bufnr)
  checkCreateDirectory()
  local conf_path = getConfigPath()
  local fname = vim.fn.input({ prompt = "Particle name: " })
  if fname ~= "" then
    actions.close(prompt_bufnr)
    local random_id = math.random(10000, 99999)
    local file = io.open(conf_path .. "/AirSupport/particle-" .. fname .. "-" .. random_id .. ".md", "a")
    if file ~= nil then
      file:write("# {name}", "\n", "\n", "## Short Explanation", "\n", "{shortExplanation}", "\n", "\n", "## Shortcut", "\n", "{nil}", "\n", "\n", "## Command", "\n", "{nil}", "\n", "\n", "## Usage", "\n", "{usage}")
      file:close()
      vim.api.nvim_command(":tabnew ".. conf_path .. "/AirSupport/particle-" .. fname .. "-" .. random_id .. ".md")
    end
  end
end

local function deleteFile(prompt_bufnr)
  local isConfirm = vim.fn.input({ prompt = "Are you sure you want do delete? (y/N) " })
  if isConfirm == "y" or isConfirm == "Y" then
    local selected = action_state.get_selected_entry()
    os.remove(selected.path)
    actions.close(prompt_bufnr)
  end
end

local function editFile(prompt_bufnr)
  local selected = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  vim.api.nvim_command(":tabnew " .. selected.path)
end


return require("telescope").register_extension {
  exports = {
    AirSupport = function(opts)
      local inner_opts = {
        prompt_title = "Air Support",
        results_title = "Particles",
        finder = finders.new_table {
          results = createParticleDictionary(),
          entry_maker = function(entry)
            local displayer = entry_display.create {
              separator = "|",
              items = {
                { width = 0.2 },
                { width = 0.25 },
                { width = 0.15 },
                { remaining = true }
              }
            }

            local function make_display(ent)
              return displayer {
                { ent.name, "particleName" },
                { ent.command, "particleCommand" },
                { ent.shortcut, "particleShortcut" },
                { ent.shortExp, "particleExplanation" },
              }
            end

            return {
              value = entry,
              display = make_display,
              ordinal = string.format("%s %s %s %s", entry[1], entry[2], entry[3], entry[4]),
              name = entry[1],
              command = entry[2],
              shortcut = entry[3],
              shortExp = entry[4],
              path = entry[5]
            }
          end
        },
        sorter = sorters.get_fzy_sorter({}),
        previewer = previewers.new_termopen_previewer({
          get_command = function(entry, _)
            return printTypeCommand(entry.path)
          end,
          title = "Definition"
        }),

        attach_mappings = function(_, map)
          map("i", "<CR>", enter)
          map("i", airSupportConfig.telescope_new_file_shortcut , newFile)
          map("i", airSupportConfig.telescope_delete_file_shortcut, deleteFile)
          map("i", airSupportConfig.telescope_edit_file_shortcut, editFile)
          map("n", "<CR>", enter)
          map("n", airSupportConfig.telescope_new_file_shortcut , newFile)
          map("n", airSupportConfig.telescope_delete_file_shortcut, deleteFile)
          map("n", airSupportConfig.telescope_edit_file_shortcut, editFile)
          return true
        end
      }

      pickers.new(style, inner_opts):find()
    end
  }
}
