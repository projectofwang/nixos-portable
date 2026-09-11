# Compose one NixOS host from machine identity and selected profiles; for example, `mkHost` is used for both production and CI.
{
  inputs,
  lib,
  home-manager,
  profiles,
}:

{
  mkHost =
    {
      machine,
      hostModule,
    }:
    let
      # Validate profile names before converting them into module paths.
      selectedProfiles = profiles.validate machine.profiles;
      home = import ./home-manager.nix { inherit inputs; };
    in
    lib.nixosSystem {
      # Build for the machine architecture; for example, production currently targets x86_64-linux.
      inherit (machine) system;

      # Pass machine metadata explicitly so modules do not read files directly.
      specialArgs = {
        inherit inputs machine;
        hostname = machine.hostname;
        username = machine.username;
        timeZone = machine.timeZone;
        nixosStateVersion = machine.nixosStateVersion;
        homeStateVersion = machine.homeStateVersion;
      };

      # Layer machine hardware, Home Manager, and optional profiles into one system.
      modules = [
        hostModule
        home-manager.nixosModules.home-manager
      ]
      ++ map (profile: ../profiles/${profile}.nix) selectedProfiles
      ++ [
        {
          # Pin NixOS state compatibility; example: migrations deliberately update this value.
          system.stateVersion = machine.nixosStateVersion;

          # Attach the shared Home Manager configuration to the same host identity.
          home-manager = home.mkHome {
            username = machine.username;
            homeStateVersion = machine.homeStateVersion;
          };
        }
      ];
    };
}
