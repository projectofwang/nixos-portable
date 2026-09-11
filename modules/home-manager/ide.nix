# Provide VS Code as the repository's IDE; AI configuration remains outside this module.
{ ... }:

{
  programs.vscode = {
    enable = true;

    # Keep the editor installation declarative while leaving user-specific settings and extensions manageable by the user.
    mutableExtensionsDir = true;
  };
}
