local strutils = require("cluautils.string_utils")
local engine = require("engine")

---@class build.TelescopeEngine : build.Engine
---@field actions table
---@field previewers table
---@field pickers table
---@field finders table
---@field makeEntry table
---@field actionState table
---@field config table
local M = {}

setmetatable(M, { __index = engine})

---@param buildFile string
---@return build.TelescopeEngine
function M:new(buildFile)
   ---@type build.TelescopeEngine
   ---@diagnostic disable-next-line: assign-type-mismatch
   local this = engine:new("telescope", buildFile)

   this.actions = require("telescope.actions")
   this.previewers = require("telescope.previewers")
   this.pickers = require("telescope.pickers")
   this.finders = require("telescope.finders")
   this.makeEntry = require("telescope.make_entry")
   this.actionState = require("telescope.actions.state")
   this.config = require("telescope.config").values

   setmetatable(this, self)

   self.__index = self

   return this
end

function M:searchBuild()
   engine.searchBuild(self)

   local opts = {
      cwd = vim.uv.cwd(),
   }

   local finder = self.finders.new_table {
      results = self:completion(),
      entry_maker = self.makeEntry.gen_from_string(opts),
      cwd = opts.cwd,
   }

   self.pickers
      .new(opts, {
         debounce = 100,
         prompt_title = "Build Commands",
         finder = finder,
         previewer = self.previewers.new_buffer_previewer {
            define_preview = function(preview_self, entry)
               local command = self:asString(entry[1])

               if not command then
                  return
               end

               local formattedCommand = strutils.split(command, "\n")

               vim.api.nvim_buf_set_lines(
                  preview_self.state.bufnr,
                  0,
                  -1,
                  false,
                  formattedCommand
               )
            end,
         },
         sorter = self.config.generic_sorter(opts),
         attach_mappings = function(prompt_bufnr, _)
            self.actions.select_default:replace(function()
               self.actions.close(prompt_bufnr)
               local selection = self.actionState.get_selected_entry()
               self:buildCommand { args = selection[1] }
            end)
            return true
         end,
      })
      :find()
end

return M
