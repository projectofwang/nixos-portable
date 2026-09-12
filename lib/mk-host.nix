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

  # Build an isolated host/profile composition for CI so each matrix entry tests only the
  # common baseline plus its selected profile rather than rebuilding every role profile.
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
