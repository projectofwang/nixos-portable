# Configure the shared interactive shell; for example, every host gets Zsh, Starship, direnv, and modern CLI replacements.
{ pkgs, ... }:

{
  # Add user-local executables to PATH; for example, npm global binaries become available without system installation.
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  programs = {
    # Keep Bash available for scripts and fallback shells.
    bash.enable = true;

    # Load Nix development environments automatically; for example, entering a flake directory activates its dev shell.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Render a compact, repository-aware prompt; for example, Git state appears beside the current directory.
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        palette = "terminal";
        add_newline = false;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
        };
        palettes.terminal = {
          blue = "#6dcbfa";
          red = "#ed8274";
          green = "#facc6e";
          yellow = "#87d96c";
          cyan = "#90e1c6";
          magenta = "#dabafa";
          white = "#c7c7c7";
          black = "#171b24";
          rosewater = "#d5ff80";
          flamingo = "#f28779";
          pink = "#dfbfff";
          mauve = "#dabafa";
          maroon = "#f28779";
          peach = "#d5ff80";
          teal = "#90e1c6";
          sky = "#95e6cb";
          sapphire = "#73d0ff";
          lavender = "#dfbfff";
          text = "#d1d1c7";
          subtext1 = "#c7c7c7";
          subtext0 = "#686868";
          overlay2 = "#686868";
          overlay1 = "#686868";
          overlay0 = "#171b24";
          surface2 = "#171b24";
          surface1 = "#171b24";
          surface0 = "#1f2430";
          base = "#1f2430";
          mantle = "#1f2430";
          crust = "#1f2430";
        };
      };
    };

    # Enable fast directory jumping; for example, `cd project` resolves through zoxide history.
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Provide searchable shell history without synchronizing it remotely.
    atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = false;
        update_check = false;
        style = "compact";
        inline_height = 20;
        show_preview = true;
      };
    };

    # Use fd as the default fzf source; for example, Ctrl-T searches tracked and hidden files while excluding `.git`.
    fzf = {
      enable = true;
      enableZshIntegration = true;
      historyWidget.command = "";
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--border"
        "--layout=reverse"
      ];
      fileWidget.command = "fd --type f";
      fileWidget.options = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
      changeDirWidget.command = "fd --type d";
      changeDirWidget.options = [
        "--preview 'eza --tree --color=always {} | head -200'"
      ];
    };

    # Replace cat with bat and keep readable source defaults; for example, line numbers and change markers are shown automatically.
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
      };
    };

    # Replace common directory commands with eza; for example, `ls` becomes a Git-aware listing with directory grouping.
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    # Own the interactive Zsh environment and shell aliases; for example, `find` maps to fd and `cd` maps to zoxide.
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        lt = "eza --tree";
        cat = "bat";
        find = "fd";
        cd = "z";
      };

      # Keep useful history while avoiding destructive or noisy command patterns.
      history = {
        size = 10000;
        ignoreAllDups = true;
        path = "$HOME/.zsh_history";
        ignorePatterns = [
          "rm *"
          "pkill *"
          "cp *"
        ];
      };

      # Pin fzf-tab for reproducible completion behavior; for example, completion menus can preview directories through eza.
      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "v1.1.2";
            sha256 = "sha256-Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
          };
        }
      ];

      # Add completion previews and environment-aware fzf commands during Zsh initialization.
      initContent = ''
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
        zstyle ':fzf-tab:*' switch-group '<' '>'

        if command -v fd >/dev/null 2>&1; then
          export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
          export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
        fi

        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      '';
    };
  };

  # Keep low-level search tools user-scoped; for example, `fd` and `ripgrep` back the shell workflows above.
  home.packages = with pkgs; [
    fd
    ripgrep
  ];
}
