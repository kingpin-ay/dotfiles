-- ~/.config/nvim/init.lua
-- Minimal Neovim setup for general text editing.

-- Leader must be set before lazy.nvim loads plugins.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--------------------------------------------------------------------------
-- Clipboard: share one clipboard between Neovim and the system.
--------------------------------------------------------------------------
-- Every yank/delete/change goes to the system clipboard, and `p` pastes
-- whatever you last copied anywhere on the desktop. Requires wl-clipboard
-- (Wayland) or xclip/xsel (X11) to be installed.
vim.opt.clipboard = 'unnamedplus'

--------------------------------------------------------------------------
-- General editing options
--------------------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.scrolloff = 5

-- Word wrap that breaks at word boundaries, and keeps indent on wrapped lines.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Files: persistent undo, no swap/backup clutter.
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.confirm = true

--------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------
-- Clear search highlight.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Familiar save / select-all / quit.
vim.keymap.set({ 'n', 'i' }, '<C-s>', '<cmd>write<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select all' })

-- Move by visual line when text is wrapped.
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Keep the cursor in place when joining lines / centre screen on search jumps.
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Highlight the text you just yanked, so copying gives visible feedback.
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
})

--------------------------------------------------------------------------
-- Plugin manager (lazy.nvim) — bootstraps itself on first launch.
--------------------------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none', '--branch=stable',
        'https://github.com/folke/lazy.nvim.git', lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    {
        'AlexvZyl/nordic.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('nordic').setup({
                bold_keywords = false,
                italic_comments = true,
                reduced_blue = true,
                bright_border = false,
                cursorline = { theme = 'dark', blend = 0.85 },
            })
            require('nordic').load()
        end,
    },
})
