function env-sync --description "Sync API keys from Bitwarden to environment"
    set -l script (dirname (dirname (dirname (realpath (status filename)))))/scripts/env-sync.sh

    if not test -f "$script"
        echo "Error: env-sync.sh not found at $script" >&2
        return 1
    end

    for arg in $argv
        if test "$arg" = "-h" -o "$arg" = "--help"
            "$script" --shell fish $argv
            return $status
        end
    end

    "$script" --shell fish $argv | source
end
