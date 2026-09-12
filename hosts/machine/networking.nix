{ ... }:

{
  # Use NetworkManager for links and dnscrypt-proxy for DNS transport.
  networking = {
    nameservers = [
      "127.0.0.1"
      "::1"
      "1.1.1.1"
    ];

    # Allow applications to see the local resolver configuration.
    resolvconf.extraConfig = "resolv_conf_local_only=NO";

    # Keep DNS management inside dnscrypt-proxy.
    networkmanager = {
      enable = true;
      dns = "none";
    };

    # Keep the host firewall enabled by default.
    firewall.enable = true;
  };

  # Disable systemd-resolved because dnscrypt-proxy owns the resolver service.
  services = {
    resolved.enable = false;

    # Expose encrypted DNS locally on the standard DNS port.
    dnscrypt-proxy = {
      enable = true;
      settings = {
        listen_addresses = [
          "127.0.0.1:53"
          "[::1]:53"
        ];

        # Use Cloudflare as the fallback resolver.
        fallback_resolvers = [ "1.1.1.1:53" ];

        # Select and pin the configured DNSCrypt resolver.
        server_names = [ "sdns" ];
        static.sdns.stamp = "sdns://AgcAAAAAAAAAAAAdc2Rucy50YWl5dWFud2FuZ2ppZS5kcGRucy5vcmcKL2Rucy1xdWVyeQ";
      };
    };
  };
}
