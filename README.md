# build.nvim

`build` allows you to run your build commands from neovim like with default `make`.

WIP: Add here gif usage example

## Usage

To start using `build` plugin use command `:Build generate` and in newely created build file add your configuration. In `conf` object use keys as commands' names and values as commands to run:

```lua
---@param cmd string
---@return string
local function runTestsCommand(cmd)
   local runner = "./run_tests.sh \"%s\""
   return string.format(runner, cmd)
end

---@return string
local function getCurrentFileName()
   local filePath = vim.fn.expand("%")
   local pathComponents = vim.fn.split(filePath, "/")
   local file = pathComponents[#pathComponents]
   local fileName = vim.fn.split(file, "%.")

   return fileName[#fileName]
end

conf = {
   install = "sudo luarocks make",
   remove = "sudo luarocks remove cluautils",
   currentTest = runTestsCommand(getCurrentFileName()),
   allTest = runTestsCommand("*"),
   threadTest = [[
      bear -- make build
      make test_thread
   ]] .. runTestsCommand("cthread*"),
   memoryTest = [[
      bear -- make build
   ]] .. runTestsCommand("cmemory*"),
   oopTest = runTestsCommand("oop"),
   stringTest = runTestsCommand("string_utils*"),
   jsonTest = runTestsCommand("json*"),
   fmTest = runTestsCommand("file_manager*"),
   tableTest = runTestsCommand("table_utils*"),
   hashmapTest = runTestsCommand("*hashmap*"),
   linkedlistTest = runTestsCommand("linkedlist*"),
}
```
As you can see, your commands can return either string representation of terminal command or a function to run! Strings will run in `toggleterm` while functions will just run.

After saving build file you can use all your declared commands like this: `:Build <your_command_name>`.

You can edit your configuration file with `:Build edit` command.

## Installation

**Prerequisites:**

1. [`cluautils`](https://github.com/castlele/cluautils) library. Library with different lua tools.

    Can be installed with `luarocks`: `luarocks install cluautils`

2. [`akinsho/toggleterm`](https://github.com/akinsho/toggleterm.nvim) plugin. Manages running commands.

3. One of the search engines:

    - [`mini.pick`](https://github.com/nvim-mini/mini.pick)
    - [`telescope`](https://github.com/nvim-telescope/telescope.nvim)

---

Install plugin with your favourite plugin manager like this:

```lua
require("lazy").setup {
    {
        "castlele/build.nvim",
        opts = true,
    },
}
```

## Configuration

To **enable** plugin you have to run `setup` method:

```lua
require("build").setup()
```

With no arguments provided `build` plugin will use default settings:

```lua
require("build").setup {
    buildFileName = "build.lua",
    engineConfig = {
        type = "minipick", -- can fallback to telescope
        keymap = "<leader>B",
    },
}
```
