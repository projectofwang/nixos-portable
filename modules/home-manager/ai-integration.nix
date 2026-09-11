{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkMerge [
    # Configure Zed only when its owning profile is enabled.
    (lib.mkIf config.programs.zed-editor.enable {
      programs.zed-editor.userSettings = {
        # Use Zed's native llama.cpp provider instead of wrapping it in a generic OpenAI provider.
        language_models = {
          "llama.cpp" = {
            api_url = "http://127.0.0.1:8080";
            auto_discover = false;
            available_models = [
              {
                name = "qwen3.5-35b-a3b-q4_k_m";
                display_name = "Qwen 3.5 35B-A3B Q4_K_M (llama.cpp)";
                max_tokens = 65536;
                supports_tools = true;
                supports_images = true;
              }
            ];
          };
        };
      };
    })

    # Configure CodeCompanion only when Neovim is already enabled by the editor profile.
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.plugins = [
        {
          # Install the plugin without making AI integration own Neovim itself.
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
                          default = "qwen3.5-35b-a3b-q4_k_m",
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
