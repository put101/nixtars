local spell_dir = vim.fn.stdpath("data") .. "/spell"
vim.fn.mkdir(spell_dir, "p")

vim.opt.spellfile = spell_dir .. "/en.utf-8.add"

-- Check if vim-dirtytalk has successfully generated the programming dictionary
local dirtytalk_path = vim.fn.stdpath("data") .. "/lazy/vim-dirtytalk/spell/programming.utf-8.spl"
if vim.fn.filereadable(dirtytalk_path) == 1 then
  vim.opt.spelllang = { "en", "programming" }
else
  vim.opt.spelllang = { "en" }
end
