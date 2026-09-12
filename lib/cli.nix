# Provide a small command-line facade over the flake; for example, every operation accepts the discovered host name.
{ pkgs, flake }:

pkgs.writeShellApplication {
  name = "nixos-portable";
  runtimeInputs = [
    pkgs.git
    pkgs.nixos-rebuild
  ];
  text = ''
    set -euo pipefail

    usage() {
      cat <<'EOF'
    Usage:
      nixos-portable check
      nixos-portable build <host>
      nixos-portable switch <host>
      nixos-portable deploy <host> <target>

    Examples:
      nixos-portable build machine
      nixos-portable switch machine
      nixos-portable deploy machine root@server
    EOF
    }

    command="''${1:-}"

    case "$command" in
      check)
        nix fmt -- --check $(git ls-files '*.nix')
        nix flake check --no-write-lock-file "${flake}"
        ;;
      build)
        host="''${2:-}"
        [[ -n "$host" ]] || { usage; exit 2; }
        nixos-rebuild build --flake "${flake}#$host"
        ;;
      switch)
        host="''${2:-}"
        [[ -n "$host" ]] || { usage; exit 2; }
        nixos-rebuild switch --flake "${flake}#$host"
        ;;
      deploy)
        host="''${2:-}"
        target="''${3:-}"
        [[ -n "$host" && -n "$target" ]] || { usage; exit 2; }
        nixos-rebuild switch --flake "${flake}#$host" --target-host "$target"
        ;;
      -h|--help|help)
        usage
        ;;
      *)
        usage
        exit 2
        ;;
    esac
  '';
}
