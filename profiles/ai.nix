# Run the local llama.cpp service and connect optional editor integrations; for example, the service exposes an OpenAI-compatible API on port 8080.
{ username, pkgs, ... }:

{
  # Use the Vulkan backend because GPU acceleration is provided by the machine graphics layer.
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-vulkan;
    settings = {
      host = "127.0.0.1";
      port = 8080;
      hf-repo = "unsloth/Qwen3.5-35B-A3B-GGUF";
      hf-file = "Qwen3.5-35B-A3B-Q4_K_M.gguf";
      alias = "qwen3.5-35b-a3b-q4_k_m";
      ctx-size = 65536;
      temp = 0.2;
      top-p = 0.95;
      top-k = 40;
      flash-attn = "on";
    };
  };

  # Add editor integrations only; for example, Zed and Neovim can consume the same local model without owning the server.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/ai-integration.nix
  ];
}
