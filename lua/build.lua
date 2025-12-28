local strutils = require("cluautils.string_utils")

---@class build.EngineConfig
---@field keymap string
---@field type "telescope"|"minipick"|"none"

---@return "telescope"|"minipick"|"none"
local function getAvailableEngineType()
   local isMinipick = pcall(require, "mini.pick")

   if isMinipick then
      return "minipick"
   end

   local isTelescope = pcall(require, "telescope")

   if isTelescope then
      return "telescope"
   end

   return "none"
end

---@class build.BuildOptions
---@field buildFileName string?
---@field engineConfig build.EngineConfig

---@class build.BuildModule
---@field engine build.Engine
---@field opts build.BuildOptions
local M = {
   opts = {
      buildFileName = "build.lua",
      engineConfig = {
         keymap = "<leader>B",
         type = getAvailableEngineType(),
      },
   },
}

local function initEngine()
   local type = M.opts.engineConfig.type

   if type == "minipick" then
      M.engine = require("minipick_engine"):new(
         M.opts.buildFileName
      )
   elseif type == "telescope" then
      M.engine = require("telescope_engine"):new(
         M.opts.buildFileName
      )
   else
      M.engine = require("engine"):new(
         type,
         M.opts.buildFileName
      )
   end
end

local function setKeymaps()
   vim.keymap.set(
      "n",
      M.opts.engineConfig.keymap,
      function() M.engine:searchBuild() end,
      { noremap = true, silent = true }
   )
end

---@param opts build.BuildOptions?
function M.setup(opts)
   if opts then
      if strutils.isNilOrEmpty(opts.buildFileName) then
         M.opts.buildFileName = M.opts.buildFileName
      else
         M.opts.buildFileName = opts.buildFileName
      end

      local t = opts.engineConfig

      if t then
         M.opts.engineConfig.keymap = t.keymap or M.opts.engineConfig.keymap
         M.opts.engineConfig.type = t.type or M.opts.engineConfig.type
      end
   end

   initEngine()

   vim.api.nvim_create_user_command("Build", function() M.engine:buildCommand() end, {
      desc = "build.nvim plugin. More here: https://github.com/castlele/build.nvim",
      complete = function(completion) M.engine:completion(completion) end,
      nargs = 1,
   })

   setKeymaps()
end

return M
