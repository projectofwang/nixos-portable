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

  # The IDE profile owns the editor itself; this profile only turns on the
  # optional local-AI integration when both profiles are selected.
  home-manager.users.${username}.my.ai.enable = true;
}
