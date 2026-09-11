{ config, lib, pkgs, ... }:

{
  # Only augment an editor when another profile already enabled it. The AI
  # profile therefore never installs an editor by itself.
  programs.zed-editor.userSettings =
    lib.mkIf config.programs.zed-editor.enable {
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

  programs.neovim.plugins =
    lib.mkIf config.programs.neovim.enable [
      {
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
      }
    ];
}
