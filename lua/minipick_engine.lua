local strutils = require("cluautils.string_utils")
local engine = require("engine")

---@class build.MinipickEngine : build.Engine
---@field picker table
local M = {}

setmetatable(M, { __index = engine })

---@param buildFile string
---@return build.MinipickEngine
function M:new(buildFile)
   ---@type build.MinipickEngine
   ---@diagnostic disable-next-line: assign-type-mismatch
   local this = engine:new("minipick", buildFile)

   this.picker = require("mini.pick")

   setmetatable(this, self)

   self.__index = self

   return this
end

function M:searchBuild()
   engine.searchBuild(self)

   local result = self.picker.start {
      source = {
         items = self:completion(),
         preview = function(buf, item)
            local command = self:asString(item)

            if not command then
               return
            end

            local formattedCommand = strutils.split(command, "\n")
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, formattedCommand)
         end,
         choose = function()
            self.picker.stop()
         end,
      },
   }

   self:buildCommand { args = result }
end

return M
