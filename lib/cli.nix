{ pkgs }:

pkgs.writeShellApplication {
  # Keep all repository operations behind one flake-aware command.
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
      nixos-portable deploy <host> <target> [build-host]

    Examples:
      nixos-portable check
      nixos-portable build machine
      nixos-portable switch machine
      nixos-portable deploy machine root@server
      nixos-portable deploy machine root@server root@builder
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

    if [[ ! -f "$flake_dir/flake.nix" ]]; then
      die "could not find flake.nix at '$flake_dir'"
    fi

    flake_ref="$flake_dir"
    cd "$flake_dir"

    require_args() {
      local expected="$1"
      shift
      local actual="$#"
      (( actual == expected )) || die "expected $expected argument(s), got $actual"
    }

    case "$command" in
      check)
        require_args 0
        mapfile -t nix_files < <(git ls-files '*.nix')
        if (( ''${#nix_files[@]} > 0 )); then
          nix fmt --no-write-lock-file -- --check "''${nix_files[@]}"
        fi
        nix flake check --no-write-lock-file "$flake_ref"
        ;;
      build)
        require_args 1 "$@"
        host="$1"
        nixos-rebuild build --flake "''${flake_ref}#$host"
        ;;
      switch)
        require_args 1 "$@"
        host="$1"
        nixos-rebuild switch --flake "''${flake_ref}#$host"
        ;;
      deploy)
        if (( $# < 2 || $# > 3 )); then
          die "expected 2 or 3 argument(s), got $#"
        fi
        host="$1"
        target="$2"
        build_args=()
        if (( $# == 3 )); then
          build_host="$3"
          build_args=(--build-host "$build_host")
        fi
        nixos-rebuild switch --flake "''${flake_ref}#$host" --target-host "$target" "''${build_args[@]}"
        ;;
      -h|--help|help)
        require_args 0 "$@"
        usage
        ;;
      *)
        die "unknown command: $command"
        ;;
    esac
  '';
}
