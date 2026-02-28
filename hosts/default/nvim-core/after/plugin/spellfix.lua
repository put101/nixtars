local spell_dir = vim.fn.stdpath("data") .. "/spell"
vim.fn.mkdir(spell_dir, "p")

-- Only set spellfile and spelllang if the files exist.
-- To get the 'programming' dictionary, add 'psliwka/vim-dirtytalk' to your plugins.
vim.opt.spellfile = spell_dir .. "/en.utf-8.add"

local programming_spell = spell_dir .. "/programming.utf-8.spl"
if vim.fn.filereadable(programming_spell) == 1 then
  vim.opt.spelllang:append("programming")
end
