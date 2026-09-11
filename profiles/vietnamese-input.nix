# Enable the Lotus Vietnamese input method; for example, selecting this profile makes Fcitx5 available in Wayland sessions.
{
  inputs,
  pkgs,
  username,
  ...
}:

{
  # Import the Lotus NixOS module from the pinned flake input.
  imports = [
    inputs.fcitx5-lotus.nixosModules.fcitx5-lotus
  ];

  # Configure Fcitx5 with a Wayland frontend and the Lotus addon.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = [
        inputs.fcitx5-lotus.packages.${pkgs.stdenv.hostPlatform.system}.fcitx5-lotus
        pkgs.fcitx5-gtk
      ];
    };
  };

  # Run the Lotus service for the selected user; for example, `users = [ username ]` limits service ownership to that account.
  services.fcitx5-lotus = {
    enable = true;
    package = inputs.fcitx5-lotus.packages.${pkgs.stdenv.hostPlatform.system}.fcitx5-lotus;
    users = [ username ];
  };
}
