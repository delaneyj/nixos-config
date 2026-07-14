if status is-interactive
    set -l gcr_sock "/run/user/"(id -u)"/gcr/ssh"

    if test -S $gcr_sock
        if not set -q SSH_AUTH_SOCK; or not test -S "$SSH_AUTH_SOCK"
            set -gx SSH_AUTH_SOCK $gcr_sock
        end
    end

    if set -q SSH_AUTH_SOCK; and test -S "$SSH_AUTH_SOCK"
        set -l ssh_bootstrap_flag "$XDG_RUNTIME_DIR/fish-ssh-agent-bootstrapped"

        if not test -e $ssh_bootstrap_flag
            if test -f ~/.ssh/id_rsa
                ssh-add -l >/dev/null 2>&1
                if test $status -eq 2
                    ssh-add ~/.ssh/id_rsa </dev/tty >/dev/tty 2>/dev/null
                end
            end

            touch $ssh_bootstrap_flag
        end
    end

    alias sd sd-cli
    alias switch-nixos "$HOME/nixos-config/switch"
    alias yolo "codex --dangerously-bypass-approvals-and-sandbox"

    # Auto-enter nix develop for projects with a flake.
    function __auto_nix_develop
        if set -q IN_NIX_SHELL
            return
        end

        if not test -f "$PWD/flake.nix"; and not test -f "$PWD/shell.nix"; and not test -f "$PWD/default.nix"
            return
        end

        if command -v nix >/dev/null
            exec nix develop "$PWD" --command fish
        end
    end

    function __auto_nix_develop_on_pwd --on-variable PWD
        __auto_nix_develop
    end

    __auto_nix_develop
end
