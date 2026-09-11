{ username, pkgs, ... }:

{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-vulkan;
    settings = {
      host = "127.0.0.1";
      port = 8080;
      hf-repo = "unsloth/Qwen3.5-4B-GGUF";
      hf-file = "Qwen3.5-4B-UD-Q4_K_XL.gguf";
      alias = "qwen3.5-4b";
      ctx-size = 65536;
      temp = 0.2;
      top-p = 0.95;
      top-k = 40;
      flash-attn = "on";
    };
  };

  home-manager.users.${username}.imports = [
    ../modules/home-manager/ai-integration.nix
  ];
}
