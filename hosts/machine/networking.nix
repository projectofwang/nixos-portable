{
  ...
}:

{
  # Use NetworkManager for links and dnscrypt-proxy for DNS transport.
  networking = {
    # Keep all normal host DNS queries on the local dnscrypt-proxy listener.
    nameservers = [
      "127.0.0.1"
      "::1"
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

        # Bootstrap the hostname of the user's private encrypted DNS server.
        # This resolver is only used for one-shot bootstrap resolution;
        # normal host DNS queries stay on the local dnscrypt-proxy listener.
        bootstrap_resolvers = [ "1.1.1.1:53" ];
        ignore_system_dns = true;

        # Use the user's self-hosted encrypted DNS resolver.
        server_names = [ "sdns" ];
        static.sdns.stamp = "sdns://AgcAAAAAAAAAAAAdc2Rucy50YWl5dWFud2FuZ2ppZS5kcGRucy5vcmcKL2Rucy1xdWVyeQ";
      };
    };
  };
}
