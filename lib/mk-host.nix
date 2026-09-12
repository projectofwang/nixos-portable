# Compose NixOS hosts from identity, host modules, roles, profiles, and Home Manager.
{
  inputs,
  lib,
  home-manager,
  profiles,
  roles,
  architectures,
}:

let
  build =
    {
      machine,
      hostModule,
      extraProfiles ? [ ],
    }:
    let
      roleProfiles = roles.expand (machine.roles or [ ]);
      selectedProfiles = profiles.validate (
        lib.unique (roleProfiles ++ machine.profiles ++ extraProfiles)
      );
      home = import ./home-manager.nix { inherit inputs; };
      system = architectures.validate machine.system;
    in
    lib.nixosSystem {
      inherit system;

      # Expose only stable, module-relevant identity values instead of the entire machine record.
      specialArgs = {
        inherit inputs;
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
in
{
  # Build the complete host definition used by normal NixOS operations.
  mkHost = args: build args;

  # Build a host with one additional profile so CI can test host × architecture × profile combinations.
  mkProfileHost =
    args@{
      profile,
      ...
    }:
    build (builtins.removeAttrs args [ "profile" ] // { extraProfiles = [ profile ]; });
}
