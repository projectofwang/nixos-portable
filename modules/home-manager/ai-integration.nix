{ config, lib, pkgs, ... }:

{
  # Only augment an editor when another profile already enabled it. The AI
  # profile therefore never installs an editor by itself.
  config = lib.mkMerge [
    (lib.mkIf config.programs.zed-editor.enable {
      programs.zed-editor.userSettings = {
        language_models = {
          "llama.cpp" = {
            api_url = "http://127.0.0.1:8080";
            auto_discover = false;
            available_models = [
              {
                name = "qwen3.5-4b";
                display_name = "Qwen 3.5 4B (llama.cpp)";
                max_tokens = 65536;
                supports_tools = true;
                supports_images = true;
              }
            ];
          };
        };
      };
    })
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.plugins = [
        {
          plugin = pkgs.vimPlugins.codecompanion-nvim;
          type = "lua";
          config = ''
            require("codecompanion").setup({
              adapters = {
                http = {
                  ["llama.cpp"] = function()
                    return require("codecompanion.adapters").extend("openai_compatible", {
                      env = {
                        url = "http://127.0.0.1:8080",
                        chat_url = "/v1/chat/completions",
                      },
                      schema = {
                        model = {
                          default = "qwen3.5-4b",
                        },
                      },
                    })
                  end,
                },
              },
              interactions = {
                chat = {
                  adapter = "llama.cpp",
                },
                inline = {
                  adapter = "llama.cpp",
                },
                cmd = {
                  adapter = "llama.cpp",
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
    })
  ];
}
