# Provide a small command-line facade over the flake; for example, every operation accepts the discovered host name.
{ pkgs, flake }:

pkgs.writeShellApplication {
  name = "nixos-portable";
  runtimeInputs = [
    pkgs.git
    pkgs.nix
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
      nixos-portable check
      nixos-portable build machine
      nixos-portable switch machine
      nixos-portable deploy machine root@server
    EOF
    }

    die() {
      printf 'error: %s\n' "$1" >&2
      usage >&2
      exit 2
    }

    if [[ -z "''${1:-}" ]]; then
      die "missing command"
    fi

    command="$1"
    shift

    flake_dir="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -z "$flake_dir" ]]; then
      flake_dir="$PWD"
    fi

    flake_ref="''${flake_dir}"
    cd "$flake_dir"

    require_args() {
      local expected="$1"
      local actual="$#"
      (( actual == expected + 1 )) || die "expected $expected argument(s), got $((actual - 1))"
    }

    case "$command" in
      check)
        require_args 0
        mapfile -t nix_files < <(git ls-files '*.nix')
        if (( ''${#nix_files[@]} > 0 )); then
          nix fmt -- --check "''${nix_files[@]}"
        fi
        nix flake check --no-write-lock-file "$flake_ref"
        ;;
      build)
        require_args 1
        host="$1"
        nixos-rebuild build --flake "''${flake_ref}#$host"
        ;;
      switch)
        require_args 1
        host="$1"
        nixos-rebuild switch --flake "''${flake_ref}#$host"
        ;;
      deploy)
        require_args 2
        host="$1"
        target="$2"
        nixos-rebuild switch --flake "''${flake_ref}#$host" --target-host "$target"
        ;;
      -h|--help|help)
        require_args 0
        usage
        ;;
      *)
        die "unknown command: $command"
        ;;
    esac
  '';
}
