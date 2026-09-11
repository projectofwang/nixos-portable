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
      selectedProfiles = profiles.validate machine.profiles;
      home = import ./home-manager.nix { inherit inputs; };
    in
    lib.nixosSystem {
      inherit (machine) system;

      specialArgs = {
        inherit inputs machine;
        hostname = machine.hostname;
        username = machine.username;
        timeZone = machine.timeZone;
        nixosStateVersion = machine.nixosStateVersion;
        homeStateVersion = machine.homeStateVersion;
      };

      modules = [
        hostModule
        home-manager.nixosModules.home-manager
      ]
      ++ map (profile: ../profiles/${profile}.nix) selectedProfiles
      ++ [
        {
          system.stateVersion = machine.nixosStateVersion;
          home-manager = home.mkHome {
            username = machine.username;
            homeStateVersion = machine.homeStateVersion;
          };
        }
      ];
    };
}
