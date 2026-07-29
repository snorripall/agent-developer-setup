# GUI askpass for sudo when agents (e.g. OpenCode) have no TTY
if test -x $HOME/.local/bin/sudo-askpass
    set -gx SUDO_ASKPASS $HOME/.local/bin/sudo-askpass
end
