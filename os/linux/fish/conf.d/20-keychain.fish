# Load keychain for SSH agent with 8-hour cache (Linux)
if command -v keychain >/dev/null
    eval (keychain --quiet --eval --timeout 28800 monster-github)
end
