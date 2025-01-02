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

---@diagnostic disable-next-line
conf = {
   install = "sudo luarocks make",
   remove = "sudo luarocks remove cluautils",
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
}
```

After saving build file you can use all your declared commands like this: `:Build <your_command_name>`.


You can edit your configuration file with `:Build edit` command.

## Installation

**Prerequisites:**

1. [`cluautils`](https://github.com/castlele/cluautils) library. Library with different lua tools.

    Can be installed with `luarocks`: `luarocks install cluautils`

2. [`akinsho/toggleterm`](https://github.com/akinsho/toggleterm.nvim) plugin. Manages running commands.

---

Install plugin with your favourite plugin manager like this:

```lua
require("lazy").setup {
    { "castlele/build.nvim" },
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
    telescope = {
        enabled = pcall(require, "telescope"),
        keymap = "<leader>B",
    },
}
```

## Telescope integration

By default if you have a [`telescope`](https://github.com/nvim-telescope/telescope.nvim) plugin installed you will be able to navigate over your builds with telescope search. Default key combination is `<leader>B`, but you can change it with:

```lua
require("build").setup {
    telescope = {
        keymap = "your key combination here",
    },
}
```
