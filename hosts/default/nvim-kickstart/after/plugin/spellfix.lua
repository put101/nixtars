local spell_dir = vim.fn.stdpath("data") .. "/spell"
vim.fn.mkdir(spell_dir, "p")
vim.opt.spellfile = spell_dir .. "/en.utf-8.add"
if vim.fn.executable("curl") == 1 then
  local programming_spell = spell_dir .. "/programming.utf-8.spl"
  if vim.fn.filereadable(programming_spell) == 0 then
    vim.notify("Downloading programming spell file...", vim.log.levels.INFO)
    vim.fn.system({
      "curl", "-fsSL",
      "-o", programming_spell,
      "https://raw.githubusercontent.com/psliwka/vim-dirtytalk/master/spell/programming.utf-8.spl"
    })
    if vim.v.shell_error == 0 then
      vim.opt.spelllang:append("programming")
    end
  else
    vim.opt.spelllang:append("programming")
  end
end
