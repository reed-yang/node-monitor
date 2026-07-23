# AGENTS.md

## Repository purpose

node-monitor is a Go terminal dashboard that discovers Slurm nodes and queries NVIDIA GPU state over SSH. The Go implementation (`main.go`, `cmd/`, and `internal/`) is authoritative. The Python package under `node_monitor/` is legacy; do not update it unless the task explicitly targets the Python implementation.

## Installation and cluster onboarding

When asked to install or configure node-monitor on a server, follow [`docs/agent-setup.md`](docs/agent-setup.md) as the source of truth.

In particular:

- inspect before changing the server;
- use Slurm node names or stable SSH aliases as canonical node IDs;
- put routable FQDNs/IPs in SSH `HostName`, not in a new node-monitor mapping;
- preserve existing SSH and node-monitor configuration;
- do not change OS hostnames, DNS, Slurm, firewall rules, or SSH keys;
- verify with `node-monitor --static --debug` and report partial/offline results honestly;
- do not rely on `ProxyJump` or `ProxyCommand`; the current Go SSH client does not execute them.

## Contributor workflow

Before implementation, read `README.md`, relevant files under `docs/`, and `logs/findings.md` / `logs/progress.md`. For multi-step work, create or update a plan under `docs/superpowers/plans/`. Record material discoveries and progress in `logs/`.

Prefer existing packages and utilities over parallel implementations. Preserve unrelated formatting and user changes. Code comments, documentation, and commit messages are written in English unless the user requests otherwise.

Useful verification commands:

```bash
go test ./...
go vet ./...
make check-readme-screenshot
git diff --check
```

Run `make check-readme-screenshot` when display rendering, fixtures, screenshot generation, or README screenshot references change. Do not regenerate screenshot assets for unrelated documentation changes.

## Architecture boundaries

- `cmd/root.go`: CLI flags, node-resolution precedence, and TUI/static dispatch.
- `internal/slurm`: Slurm discovery using `sinfo`.
- `internal/config`: TOML loading and global SSH options.
- `internal/ssh`: effective SSH config lookup, connection pooling, and remote NVIDIA queries.
- `internal/tui`: Bubble Tea state and rendering.

Node resolution precedence is `--nodes`, then `--group`, then configured `nodes`, then Slurm auto-discovery. SSH aliases are resolved by the Go client using `HostName`, `User`, `Port`, and `IdentityFile` from OpenSSH config.
