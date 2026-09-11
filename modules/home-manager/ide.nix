# Own Zed only; for example, the `ide` profile can provide Zed without installing Neovim.
{ ... }:

{
  # Keep Zed configuration immutable so the repository remains the source of truth.
  programs.zed-editor = {
    enable = true;
    mutableUserSettings = false;

    # Install language extensions needed by this configuration; for example, Nix, TOML, and Rust support are available immediately.
    extensions = [
      "nix"
      "toml"
      "rust"
    ];

    # Define editor behavior and project-terminal defaults declaratively.
    userSettings = {
      format_on_save = true;
      hour_format = "hour24";
      terminal = {
        working_directory = "current_project_directory";
      };
    };
  };
}
