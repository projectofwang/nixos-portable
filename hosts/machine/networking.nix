{ ... }:

{
  networking = {
    nameservers = [
      "127.0.0.1"
      "::1"
      "9.9.9.9"
    ];

    # Keep the non-local fallback usable when dnscrypt-proxy is unavailable.
    resolvconf.extraConfig = "resolv_conf_local_only=NO";

    networkmanager = {
      enable = true;
      dns = "none";
    };

    firewall.enable = true;
  };

  services = {
    resolved.enable = false;

    dnscrypt-proxy = {
      enable = true;
      settings = {
        listen_addresses = [
          "127.0.0.1:53"
          "[::1]:53"
        ];

        # Plain DNS is only a fallback when the encrypted resolver is down.
        fallback_resolvers = [ "9.9.9.9:53" ];

        server_names = [ "sdns" ];
        static.sdns.stamp = "sdns://AgcAAAAAAAAAAAAYc2Rucy5jaGljb2FydW4uZHBkbnMub3JnCi9kbnMtcXVlcnk";
      };
    };
  };
}
