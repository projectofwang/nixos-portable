# Keep host networking separate from reusable profiles; for example, this machine uses NetworkManager with dnscrypt-proxy as the local resolver.
{ ... }:

{
  # Point the host resolver at the local dnscrypt-proxy listener with public fallback resolution.
  networking = {
    nameservers = [
      "127.0.0.1"
      "::1"
      "1.1.1.1"
    ];

    # Allow NetworkManager to keep the local resolver settings visible to applications.
    resolvconf.extraConfig = "resolv_conf_local_only=NO";

    # Let NetworkManager own link configuration while dnscrypt-proxy owns DNS transport.
    networkmanager = {
      enable = true;
      dns = "none";
    };

    # Keep the host firewall enabled by default; for example, only explicitly allowed services open ports.
    firewall.enable = true;
  };

  # Disable systemd-resolved because dnscrypt-proxy provides the resolver service.
  services = {
    resolved.enable = false;

    # Encrypt DNS queries and expose them locally on the standard DNS port.
    dnscrypt-proxy = {
      enable = true;
      settings = {
        listen_addresses = [
          "127.0.0.1:53"
          "[::1]:53"
        ];

        # Use Cloudflare as a last-resort resolver if the selected DNSCrypt server is unavailable.
        fallback_resolvers = [ "1.1.1.1:53" ];

        # Select the DNSCrypt server and pin its resolver stamp.
        server_names = [ "sdns" ];
        static.sdns.stamp = "sdns://AgcAAAAAAAAAAAAdc2Rucy50YWl5dWFud2FuZ2ppZS5kcGRucy5vcmcKL2Rucy1xdWVyeQ";
      };
    };
  };
}
