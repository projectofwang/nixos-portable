{ ... }:

{
  networking = {
    nameservers = [
      "127.0.0.1"
      "::1"
      "1.1.1.1"
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

        # Cloudflare is the plain-DNS emergency fallback; encrypted DNS remains primary.
        fallback_resolvers = [ "1.1.1.1:53" ];

        server_names = [ "sdns" ];
        static.sdns.stamp = "sdns://AgcAAAAAAAAAAAAdc2Rucy50YWl5dWFud2FuZ2ppZS5kcGRucy5vcmcKL2Rucy1xdWVyeQ";
      };
    };
  };
}
