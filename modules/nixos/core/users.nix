{ pkgs, username, ... }:

{
  # Enable Zsh before Home Manager configures the user's shell environment.
  programs.zsh.enable = true;

  # Create the primary normal user with administrative and network access.
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  # Keep sudo password authentication enabled for wheel users.
  security.sudo.wheelNeedsPassword = true;
}
