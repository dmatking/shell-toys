# Windows Terminal Multi-Pane Launch

Launch Windows Terminal with multiple panes from the command line, each running a command on a remote host. Requires passwordless SSH key pairs.

## 2-pane (side by side)

```bat
wt -M nt --commandline "ssh" -t host1 htop ; split-pane -V --commandline "ssh" -t host2 htop; mf --direction left
```

## 4-pane (2x2 grid)

```bat
wt -M nt --commandline "ssh" -t host1 htop ; split-pane -V --commandline "ssh" -t host2 htop; mf --direction left ; split-pane -H --commandline "ssh" -t host3 htop; mf --direction right ; split-pane -H --commandline "ssh" -t host4 htop
```

## Notes

- `-M` opens maximized
- `nt` opens a new tab
- `split-pane -V` splits vertically, `-H` horizontally
- `mf --direction` moves focus between panes
- Replace `htop` with any command to run on connect
- SSH host aliases in `~/.ssh/config` keep the commands clean
