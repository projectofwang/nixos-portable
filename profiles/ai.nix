{ username, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1";
    port = 11434;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "65536";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_KEEP_ALIVE = "10m";
    };
  };

  # Add AI client integration only to editors that are already enabled by
  # another profile; selecting AI alone never installs an editor.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/ai-integration.nix
  ];
}
