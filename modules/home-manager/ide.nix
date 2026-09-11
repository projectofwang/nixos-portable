{ ... }:

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
    };
  };
}
