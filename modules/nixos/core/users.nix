{ pkgs, username, ... }:

{
  # Zsh is managed by Home Manager, but NixOS must enable it system-wide
  # before it can be used as a login shell.
  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  # No password is declared here. Set the initial password during installation
  # or with `passwd` on an existing system; it persists across rebuilds.
  security.sudo.wheelNeedsPassword = true;
}
