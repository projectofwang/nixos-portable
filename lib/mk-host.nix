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
      profileOnly ? false,
      system ? machine.system,
    }:
    let
      roleProfiles = roles.expand (machine.roles or [ ]);
      baseProfiles = if profileOnly then [ "base" ] else roleProfiles ++ machine.profiles;
      selectedProfiles = profiles.validate (lib.unique (baseProfiles ++ extraProfiles));
      home = import ./home-manager.nix { inherit inputs; };
      targetSystem = architectures.validate system;
      declaredArchitectures = machine.architectures or [ machine.system ];
      incompatibleProfiles = lib.filter (
        profile: !(builtins.elem targetSystem (profiles.architecturesFor profile))
      ) selectedProfiles;
    in
    assert lib.assertMsg (builtins.elem targetSystem declaredArchitectures)
      "Host '${machine.hostname}' does not declare architecture '${targetSystem}'";
    assert lib.assertMsg (incompatibleProfiles == [ ])
      "Host '${machine.hostname}' selects profile(s) incompatible with architecture '${targetSystem}': ${lib.concatStringsSep ", " incompatibleProfiles}";
    lib.nixosSystem {
      system = targetSystem;

      # Pass only identity values consumed by NixOS and Home Manager modules.
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
  # Build the normal host composition used by NixOS operations.
  mkHost = args: build args;

  # Build one isolated host/profile composition for each CI matrix entry.
  mkProfileHost =
    args@{
      profile,
      ...
    }:
    build (
      builtins.removeAttrs args [ "profile" ]
      // {
        extraProfiles = [ profile ];
        profileOnly = true;
      }
    );
}
