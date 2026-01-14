local FM = require("cluautils.file_manager")
local strutils = require("cluautils.string_utils")

---@class build.Engine
---@field type "minipick"|"telescope"|"none"
---@field buildFile string
---@field defaultCommandsAsStr table[string, string]
---@field defaultCommands table[string, fun()]
---@field imports table
local M = {}

---@param type "minipick"|"telescope"|"none"
---@param buildFile string
---@return build.Engine
function M:new(type, buildFile)
   local this = {}

   this.type = type
   this.buildFile = buildFile

   if this.type ~= "none" then
      this.defaultCommandsAsStr = {
         edit = [[
vim.cmd("vsplit")
vim.cmd("edit " .. M.getBuildFile())
   ]],
         generate = "Generating build.lua in the root folder :)",
      }

      this.defaultCommands = {
         edit = function()
            this:editBuildFile()
         end,
         generate = function()
            if FM.is_file_exists(buildFile) then
               vim.notify(
                  "Your build.lua file is already generated. You can edit it with `:Build edit` command",
                  vim.log.levels.WARN
               )
               return
            end

            FM.create_file(buildFile)
            FM.write_to_file(buildFile, "w", function()
               return [[
conf = {
}]]
            end)

            this:editBuildFile()
         end,
      }
   end

   setmetatable(this, self)

   self.__index = self

   return this
end

function M:buildCommand(args)
   local commandName = args.args

   if not commandName or #commandName == 0 then
      return
   end

   local command = self:getCommand(commandName)

   if not command then
      return
   end

   local commandToRun = command()

   if type(commandToRun) == "string" then
      self:buildInTerm(commandToRun)
      return
   end

   if type(commandToRun) == "function" then
      self:runCommand(commandName, commandToRun)
      return
   end
end

---@param completion string|nil
---@return table[string]
function M:completion(completion)
   local configurations = self:getAvailableConfigurations()

   if
      not completion
      or type(completion) ~= "string"
      or strutils.isEmpty(completion)
   then
      return configurations
   end

   local filteredConf = {}

   for _, configuration in ipairs(configurations) do
      local s = string.find(configuration, completion)

      if s then
         table.insert(filteredConf, configuration)
      end
   end

   return filteredConf
end

function M:searchBuild()
   if self.type == "none" then
      vim.notify(
         "Can't determine availabe search engine type! Make sure build.nvim plugin depends on minipick or telescope",
         vim.log.levels.WARN
      )
      return
   end
end

---@protected
---@return boolean
function M:reloadConfigurationFile()
   local fun, _ = loadfile(self.buildFile)

   if fun then
      pcall(fun)
   end

   ---@diagnostic disable-next-line
   return conf ~= nil
end

---@protected
---@return table
function M:getAvailableConfigurations()
   self:reloadConfigurationFile()

   local configurations = {}

   ---@diagnostic disable-next-line
   if conf then
      ---@diagnostic disable-next-line
      for name, _ in pairs(conf) do
         table.insert(configurations, name)
      end
   end

   for name, _ in pairs(self.defaultCommands) do
      table.insert(configurations, name)
   end

   return configurations
end

---@protected
function M:editBuildFile()
   vim.cmd("vsplit")
   vim.cmd("edit " .. self.buildFile)
end

---@protected
---@param commandName string
---@return (fun(): string|fun())?
function M:getCommand(commandName)
   self:reloadConfigurationFile()

   local cmd = strutils.trim(commandName)

   ---@diagnostic disable-next-line
   local fun = self:getCodeAsFunction(conf, cmd) or self.defaultCommands[cmd]

   if not fun then
      vim.notify("Can't find command '" .. cmd .. "'", vim.log.levels.WARN)
      return nil
   end

   return fun
end

---@protected
---@param command string
---@return string?
function M:asString(command)
   if not self.defaultCommandsAsStr[command] then
      local commandRes = self:getCommand(command)()

      if type(commandRes) == "string" then
         return commandRes
      end

      if type(commandRes) == "function" then
         return "Your custom function to run"
      end

      return nil
   end

   return self.defaultCommandsAsStr[command]
end

---@protected
---@param terminalCommand string
function M:buildInTerm(terminalCommand)
   local term = require("toggleterm.terminal").Terminal

   term
      :new({
         direction = "horizontal",
         cmd = terminalCommand,
         display_name = terminalCommand,
         hidden = false,
         close_on_exit = false,
      })
      :toggle()
end

---@protected
---@param commandName string
---@param command fun()
function M:runCommand(commandName, command)
   local success, result = pcall(command)

   if success then
      local message = "Command {%s} finished successfully!"

      if result and type(result) == "string" then
         message = message .. " Result is " .. result
      end

      vim.notify(string.format(message, commandName))
   else
      vim.notify(
         string.format(
            "Command {%s} finished with error: %s",
            commandName,
            result
         ),
         vim.log.levels.ERROR
      )
   end
end

---@protected
---@param configurations table?
---@param command string
---@return (fun(): string)?
function M:getCodeAsFunction(configurations, command)
   if not configurations or not configurations[command] then
      return nil
   end

   return function()
      return configurations[command]
   end
end

return M
