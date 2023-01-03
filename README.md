# AirSupport.nvim

A NeoVim addon which helps you to write your own shortcut reminders and forget them. If you happened to have a lots of shortcuts and commands that you want to use and keep forgetting it, this would be a useful addon to you. AirSupport uses [Telescope](https://github.com/nvim-telescope/telescope.nvim) to show and execute the commands that you specify.

> Note: It is not an addon to _create_ shortcuts, it is used for creating shortcut _reminders_ for accessing them later.

![insert_gif_here]()

## Table of Contents

- [Features](#features)
- [Quickstart](#quickstart)
- [Installation](#installation)
  - [Using vim-plug](#using-vim-plug)
  - [Using dein](#using-dein)
  - [Using packer.nvim](#using-packernvim)
- [Usage](#usage)
  - [Create a new Particle](#create-a-new-particle)
- [Configuration](#configuration)
- [Acknowledgements](#acknowledgements)

## Features
- Telescope window with fuzzy finder for easier navigation.
- Easily configurable with telescope shortcuts.
- Uses markdown format to keep the commands that you specified (which are called _particles_).
- Configurable command format which reminds you the shortcuts.
- Particles can be shared easily across the computers due to the compact file structure.

## Quickstart
- Type `:AirSupport` or your configured shortcut to open up the interface.
- Add a shortcut with `<C-n>`.
- Type the file name of your particle (i.e. workspace)
- Edit the `{x}` fields in the opened file.
- Add `{input}` at the end of the line if you want to fill the rest of the command yourself in the command field (i.e. `:Telescope {input}`)
- Save the file.
- Next time you fire up the AirSupport, your particle will be shown up.

## Installation
Telescope is required for AirSupport to work, please bear in mind.

### Using vim-plug
```viml
Plug 'yagiziskirik/AirSupport.nvim'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
```

### Using dein
```viml
call dein#add('yagiziskirik/AirSupport.nvim')

call dein#add('nvim-lua/popup.nvim')
call dein#add('nvim-lua/plenary.nvim')
call dein#add('nvim-telescope/telescope.nvim')
```

### Using packer.nvim
```lua
use {
  'yagiziskirik/AirSupport.nvim',

  requires = {
    {'nvim-telescope/telescope.nvim'},
    {'nvim-lua/popup.nvim'},
    {'nvim-lua/plenary.nvim'},
  }
}
```

## Usage
Use the `:AirSupport` command to show the Telescope window. You can map the `:AirSupport` command to the any shortcut of your choosing (mine is `<leader>?`).

You can use the following command to manipulate the particles:

| Telescope Shortcuts   | Description                       |
| ---                   | ---                               |
| `<C-n>`               | Creates a new particle.           |
| `<C-e>`               | Edits the selected particle.      |
| `<C-d>`               | Deletes the selected particle.    |

Particles are stored in the `AirSupport` folder inside of your NeoVim config folder (`~/.config/nvim/AirSupport` or `~/AppData/Local/nvim/` for windows). You can copy this folder to any other computers for example if you are backing your config up. Particle format is markdown, but addon reads the file in a specific way (more details will be specified later on).

### Create a new Particle
When you create a new particle, you will be asked for the file name of the particle. This input will not be shown in the Telescope window, but will be used to save the file with a random id (i.e. `test` for `particle-test-12345.md`).

After you have entered the file name, you will be redirected to the particle edit screen. The new particle would be looking like this:

```md
# {name}

## Short Explanation
{shortExplanation}

## Shortcut
{nil}

## Command
{nil}

## Usage
{usage}
```

The `{name}` field will be shown in the user interface in the first line of the particle. `{shortExplanation}` will be the description of the particle. Shortcut and command will be shown in the Telescope interface as well. Bear in mind that when changing the Shortcut and Command fields, if you don't want to specify either of them, leave them as `{nil}`. When specifying the commands, include the `:` as well (i.e. `:Telescope diagnostics`). The `{usage}` field is for you to see what the command does and how it is been used.

> The shortcuts you specified are **not** applied to the command, it should be configured by _you_. It is there to remind you the shortcuts that you created for the action.

The end result should be looking like this:

```md
# Debugger

## Short Explanation
Shows debug information

## Shortcut
<leader>dd

## Command
:Telescope diagnostics

## Usage
Use this command to show diagnostics about the current codespace. Use `:Telescope diagnostics` or `<leader>dd` shortcut to open it up.
```

#### Specifying the Input in Commands
Add `{input}` at the end of the command: `:Telescope {input}`

## Configuration
This is the default configuration:

```lua
require("AirSupport").setup({
  telescope_new_file_shortcut = "<C-n>",
  telescope_delete_file_shortcut = "<C-d>",
  telescope_edit_file_shortcut = "<C-e>"
})
```

You can change the setup like this:

```lua
require("AirSupport").setup({
  telescope_edit_file_shortcut = "<C-r>"
})
```

## Acknowledgements
I was working on this project for a while and I discovered the [Cheatsheet.nvim](https://github.com/sudormrfbin/cheatsheet.nvim) plugin is very similar to the concept that I was trying to achieve. I also borrowed some code and styles as well :)
