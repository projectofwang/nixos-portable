# Create the primary interactive user; for example, the selected username receives Zsh and wheel/network access.
{ pkgs, username, ... }:

{
  # Enable Zsh at the system level so the user shell is available before Home Manager runs.
  programs.zsh.enable = true;

  # Define the normal user and its host-level group memberships.
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  # Keep sudo password protection enabled for wheel users.
  security.sudo.wheelNeedsPassword = true;
}
