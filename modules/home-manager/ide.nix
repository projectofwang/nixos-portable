{ config, lib, pkgs, ... }:

let
  aiPlugin = {
    plugin = pkgs.vimPlugins.codecompanion-nvim;
    type = "lua";
    config = ''
      require("codecompanion").setup({
        adapters = {
          http = {
            ollama_qwen = function()
              return require("codecompanion.adapters").extend("ollama", {
                name = "ollama_qwen",
                env = {
                  url = "http://127.0.0.1:11434",
                },
                schema = {
                  model = {
                    default = "qwen3.5:4b",
                  },
                  num_ctx = {
                    default = 65536,
                  },
                },
              })
            end,
          },
        },
        interactions = {
          chat = {
            adapter = {
              name = "ollama_qwen",
              model = "qwen3.5:4b",
            },
          },
          inline = {
            adapter = {
              name = "ollama_qwen",
              model = "qwen3.5:4b",
            },
          },
          cmd = {
            adapter = {
              name = "ollama_qwen",
              model = "qwen3.5:4b",
            },
          },
        },
        opts = {
          log_level = "ERROR",
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanion<cr>", {
        desc = "AI inline assistant",
      })
      vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", {
        desc = "AI chat",
      })
    '';
  };
in
{
  programs.zed-editor = {
    enable = true;
    mutableUserSettings = false;
    extensions = [
      "nix"
      "toml"
      "rust"
    ];
    userSettings = {
      format_on_save = true;
      hour_format = "hour24";
      terminal = {
        working_directory = "current_project_directory";
      };
    }
    // lib.optionalAttrs config.my.ai.enable {
      language_models.ollama = {
        api_url = "http://127.0.0.1:11434";
        auto_discover = false;
        available_models = [
          {
            name = "qwen3.5:4b";
            display_name = "Qwen 3.5 4B (local)";
            max_tokens = 65536;
            supports_tools = true;
            supports_thinking = true;
            supports_images = true;
          }
        ];
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      curl
      ripgrep
    ];

    plugins = [
      pkgs.vimPlugins.plenary-nvim
    ] ++ lib.optional config.my.ai.enable aiPlugin;
  };
}
