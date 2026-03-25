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

## Real-world example: monitoring multiple app servers

A practical use is keeping an eye on a cluster of servers that tend to act up. Having a separate bat file for each "mode" lets you launch exactly what you need:

**jboss-top.bat** — system load on all four nodes
```bat
wt -M nt --commandline "ssh" -t jboss1 htop ; split-pane -V --commandline "ssh" -t jboss2 htop; mf --direction left ; split-pane -H --commandline "ssh" -t jboss3 htop; mf --direction right ; split-pane -H --commandline "ssh" -t jboss4 htop
```

**jboss-logs.bat** — tail logs on all four nodes
```bat
wt -M nt --commandline "ssh" -t jboss1 "tail -f /opt/jboss/log/server.log" ; split-pane -V --commandline "ssh" -t jboss2 "tail -f /opt/jboss/log/server.log"; mf --direction left ; split-pane -H --commandline "ssh" -t jboss3 "tail -f /opt/jboss/log/server.log"; mf --direction right ; split-pane -H --commandline "ssh" -t jboss4 "tail -f /opt/jboss/log/server.log"
```

**jboss-shell.bat** — open a shell on each node
```bat
wt -M nt --commandline "ssh" jboss1 ; split-pane -V --commandline "ssh" jboss2; mf --direction left ; split-pane -H --commandline "ssh" jboss3; mf --direction right ; split-pane -H --commandline "ssh" jboss4
```

On a large monitor this gives you a proper at-a-glance ops dashboard without any extra tooling.

## Notes

- `-M` opens maximized
- `nt` opens a new tab
- `split-pane -V` splits vertically, `-H` horizontally
- `mf --direction` moves focus between panes
- Replace `htop` with any command to run on connect
- SSH host aliases in `~/.ssh/config` keep the commands clean
