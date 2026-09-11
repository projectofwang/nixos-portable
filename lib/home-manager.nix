{ inputs }:

{
  mkHome =
    {
      username,
      homeStateVersion,
    }:
    {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      extraSpecialArgs = {
        inherit inputs homeStateVersion username;
      };
      users.${username} = {
        imports = [
          ../modules/home-manager
          ../home/default.nix
        ];
        home.stateVersion = homeStateVersion;
      };
    };
}
