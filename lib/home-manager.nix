# Provide the shared Home Manager constructor; for example, every host gets the same module baseline and state-version wiring.
{ inputs }:

{
  mkHome =
    {
      username,
      homeStateVersion,
    }:
    {
      # Reuse the system package set and expose user-installed packages through Home Manager.
      useGlobalPkgs = true;
      useUserPackages = true;

      # Preserve replaced files instead of silently overwriting them during migration.
      backupFileExtension = "hm-bak";

      # Pass machine-independent inputs and state metadata to Home Manager modules.
      extraSpecialArgs = {
        inherit inputs homeStateVersion username;
      };

      # Import the reusable Home Manager tree and the user's base home definition.
      users.${username} = {
        imports = [
          ../modules/home-manager
          ../home/default.nix
        ];
        home.stateVersion = homeStateVersion;
      };
    };
}
