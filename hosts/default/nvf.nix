{ config, pkgs, lib, ... }:
let
  isMaximal = true;
  nvimStateDir = "${config.home.homeDirectory}/.local/state/nvf";
  nvimLogFile = "${nvimStateDir}/nvim.log";
  notifyLogFile = "${nvimStateDir}/notify.log";
  fallbackPython = pkgs.python311.withPackages (ps: with ps; [
    ipython
    debugpy
  ]);
  uvPython = pkgs.writeShellApplication {
    name = "uv-python";
    runtimeInputs = [ pkgs.uv fallbackPython ];
    text = ''
      set -euo pipefail
      if [ -f pyproject.toml ] || [ -f uv.lock ] || [ -f requirements.txt ]; then
        exec ${pkgs.uv}/bin/uv run python "$@"
      else
        exec ${fallbackPython}/bin/python "$@"
      fi
    '';
  };
  uvIpython = pkgs.writeShellApplication {
    name = "uv-ipython";
    runtimeInputs = [ pkgs.uv fallbackPython ];
    text = ''
      set -euo pipefail
      if [ -f pyproject.toml ] || [ -f uv.lock ] || [ -f requirements.txt ]; then
        exec ${pkgs.uv}/bin/uv run ipython "$@"
      else
        exec ${fallbackPython}/bin/ipython "$@"
      fi
    '';
  };
in
{
  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings.vim = {
      viAlias = true;
      vimAlias = true;

      debugMode = {
        enable = true;
        level = 16;
        logFile = nvimLogFile;
      };

      spellcheck = {
        enable = true;
        programmingWordlist.enable = isMaximal;
      };

      lsp = {
        enable = true;
        formatOnSave = true;
        lspkind.enable = false;
        lightbulb.enable = true;
        lspsaga.enable = false;
        trouble.enable = true;
        lspSignature.enable = !isMaximal;
        otter-nvim.enable = isMaximal;
        nvim-docs-view.enable = isMaximal;
        harper-ls.enable = isMaximal;
      };

      debugger.nvim-dap = {
        enable = true;
        ui.enable = true;
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;
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
          extensions."crates-nvim".enable = isMaximal;
        };
        toml.enable = isMaximal;
        assembly.enable = false;
        astro.enable = false;
        nu.enable = false;
        csharp.enable = false;
        julia.enable = false;
        vala.enable = false;
        scala.enable = false;
        r.enable = false;
        gleam.enable = false;
        dart.enable = false;
        ocaml.enable = false;
        elixir.enable = false;
        haskell.enable = false;
        hcl.enable = false;
        ruby.enable = false;
        fsharp.enable = false;
        just.enable = false;
        qml.enable = false;
        tailwind.enable = false;
        svelte.enable = false;
        nim.enable = false;
      };

      visuals = {
        nvim-scrollbar.enable = isMaximal;
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        cinnamon-nvim.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
        cellular-automaton.enable = false;
      };

      statusline.lualine = lib.mkForce {
        enable = true;
        theme = "catppuccin";
      };

      theme = lib.mkForce {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = false;
      };

      autopairs.nvim-autopairs.enable = true;

      autocomplete = {
        nvim-cmp.enable = !isMaximal;
        blink-cmp.enable = isMaximal;
      };

      snippets.luasnip.enable = true;

      filetree.neo-tree.enable = true;

      tabline.nvimBufferline.enable = true;

      treesitter = {
        enable = true;
        context.enable = true;
      };

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      telescope.enable = true;

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false;
        neogit.enable = isMaximal;
      };

      minimap = {
        minimap-vim.enable = false;
        codewindow.enable = isMaximal;
      };

      dashboard = {
        dashboard-nvim.enable = false;
        alpha.enable = isMaximal;
      };

      notify.nvim-notify.enable = true;

      projects.project-nvim.enable = isMaximal;

      utility = {
        ccc.enable = false;
        vim-wakatime.enable = false;
        diffview-nvim.enable = true;
        yanky-nvim.enable = false;
        qmk-nvim.enable = false;
        icon-picker.enable = isMaximal;
        surround.enable = isMaximal;
        leetcode-nvim.enable = isMaximal;
        multicursors.enable = isMaximal;
        smart-splits.enable = isMaximal;
        undotree.enable = isMaximal;
        nvim-biscuits.enable = isMaximal;
        motion = {
          hop.enable = true;
          leap.enable = true;
          precognition.enable = isMaximal;
        };
        images = {
          image-nvim.enable = false;
          img-clip.enable = isMaximal;
        };
      };

      notes = {
        neorg.enable = false;
        orgmode.enable = false;
        mind-nvim.enable = isMaximal;
        todo-comments.enable = true;
      };

      terminal.toggleterm = {
        enable = true;
        lazygit.enable = true;
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        modes-nvim.enable = false;
        illuminate.enable = true;
        breadcrumbs = {
          enable = isMaximal;
          navbuddy.enable = isMaximal;
        };
        smartcolumn = {
          enable = true;
          setupOpts.custom_colorcolumn = {
            nix = "110";
            ruby = "120";
            java = "130";
            go = ["90" "130"];
          };
        };
        fastaction.enable = true;
      };

      assistant = {
        chatgpt.enable = false;
        copilot = {
          enable = false;
          cmp.enable = isMaximal;
        };
        codecompanion-nvim.enable = false;
        avante-nvim.enable = isMaximal;
      };

      session.nvim-session-manager.enable = false;

      gestures.gesture-nvim.enable = false;

      comments.comment-nvim.enable = true;

      presence.neocord.enable = false;

      startPlugins = with pkgs.vimPlugins; [
        iron-nvim
        nvim-dap-python
      ];

      luaConfigRC.iron = ''
        local iron = require("iron.core")
        local view = require("iron.view")
        local common = require("iron.fts.common")
        vim.fn.mkdir("${nvimStateDir}", "p")

        iron.setup({
          config = {
            scratch_repl = true,
            close_window_on_exit = true,
            repl_open_cmd = view.split.vertical.botright(0.35),
            repl_definition = {
              python = {
                command = {"${uvIpython}/bin/uv-ipython", "--no-autoindent"},
                format = common.bracketed_paste_python
              },
              sh = {
                command = {"${pkgs.bash}/bin/bash"}
              }
            }
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

      luaConfigRC.dap_python = ''
        local dap_python = require("dap-python")
        dap_python.setup("${uvPython}/bin/uv-python")
        dap_python.test_runner = "pytest"
      '';

      luaConfigRC.notify_logger = ''
        local log_path = "${notifyLogFile}"
        local level_map = {}
        for name, value in pairs(vim.log.levels) do
          level_map[value] = name
        end
        local function append(msg, level)
          local file = io.open(log_path, "a")
          if file then
            local line = string.format(
              "%s\t%s\t%s\n",
              os.date("%Y-%m-%d %H:%M:%S"),
              level_map[level or vim.log.levels.INFO] or tostring(level or vim.log.levels.INFO),
              vim.inspect(msg)
            )
            file:write(line)
            file:close()
          end
        end
        local original_notify = vim.notify
        vim.notify = function(msg, level, opts)
          append(msg, level)
          return original_notify(msg, level, opts)
        end
      '';
    };
  };
}
