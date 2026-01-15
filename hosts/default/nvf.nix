{ config, pkgs, lib, ... }:
let
  isMaximal = true;
in
{
  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings.vim = {
      viAlias = true;
      vimAlias = true;

      debugMode = {
        enable = false;
        level = 16;
        logFile = "/tmp/nvim.log";
      };

      spellcheck = {
        enable = true;
        programmingWordlist.enable = isMaximal;
      };

      lsp = {
        enable = true;
        formatOnSave = true;
        lightbulb.enable = true;
        lspsaga.enable = false;
        trouble.enable = true;
        lspSignature.enable = !isMaximal; # conflicts with blink/otter in maximal
        otter-nvim.enable = isMaximal;
        nvim-docs-view.enable = isMaximal;
      };

      debugger = {
        nvim-dap = {
          enable = true;
          ui.enable = true;
        };
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        # Languages enabled in maximal config
        nix.enable = true;
        markdown.enable = true;
        bash.enable = isMaximal;
        clang.enable = isMaximal;
        css.enable = isMaximal;
        html.enable = isMaximal;
        json.enable = isMaximal;
        sql.enable = isMaximal;
        java.enable = isMaximal;
        kotlin.enable = isMaximal;
        ts.enable = isMaximal;
        go.enable = isMaximal;
        lua.enable = isMaximal;
        zig.enable = isMaximal;
        python.enable = isMaximal;
        typst.enable = isMaximal;
        rust = {
          enable = isMaximal;
          crates.enable = isMaximal;
        };
        toml.enable = isMaximal;
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        modes-nvim.enable = false; # Often conflicts or is annoying
        illuminate.enable = true;
        breadcrumbs.enable = true;
        smartcolumn.enable = true;
        fastaction.enable = true;
      };

      statusline.lualine.enable = true;
      telescope.enable = true;
      autocomplete.nvim-cmp.enable = true;
      
      # Helper for Iron.nvim (Python REPL)
      # This is NOT part of the official maximal config yet, but essential for your request.
      startPlugins = [ pkgs.vimPlugins.iron-nvim ];
      luaConfigRC.iron = ''
        local iron = require("iron.core")
        local view = require("iron.view")
        local common = require("iron.fts.common")

        iron.setup({
          config = {
            scratch_repl = true,
            repl_definition = {
              python = {
                command = {"${pkgs.python3}/bin/python3"},
                format = common.bracketed_paste_python
              }
            },
            repl_open_cmd = view.split.vertical.botright(0.4)
          },
          keymaps = {
            send_motion = "<space>sc",
            visual_send = "<space>sc",
            send_file = "<space>sf",
            send_line = "<space>sl",
            interrupt = "<space>si",
            exit = "<space>sq",
            clear = "<space>cl",
          },
          highlight = { italic = true },
          ignore_blank_lines = true, 
        })
      '';
    };
  };
}
