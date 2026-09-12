{ inputs }:

{
  mkHome =
    {
      username,
      homeStateVersion,
    }:
    {
      # Reuse the system package set and expose user packages through Home Manager.
      useGlobalPkgs = true;
      useUserPackages = true;

      # Preserve existing files during Home Manager migrations.
      backupFileExtension = "hm-bak";

      # Pass repository inputs and host identity to Home Manager modules.
      extraSpecialArgs = {
        inherit inputs homeStateVersion username;
      };

      # Load the shared module tree and the user's base home definition.
      users.${username} = {
        imports = [
          ../modules/home-manager
          ../home/default.nix
        ];
        home.stateVersion = homeStateVersion;
      };
    };
}
