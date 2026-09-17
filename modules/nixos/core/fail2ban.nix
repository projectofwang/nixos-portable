{ ... }:

{
  # Enable the NixOS Fail2ban service with its built-in defaults.
  # Jail-specific tuning and hardening are intentionally left to host-level configuration.
  services.fail2ban.enable = true;
}
