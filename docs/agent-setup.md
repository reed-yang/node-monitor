# Agent setup runbook

This runbook is for an AI or coding agent installing node-monitor on a Slurm login/controller host or another management host that can reach the GPU nodes directly.

The goal is a working, user-scoped installation with deterministic node discovery and SSH routing. Inspect first, preserve existing configuration, make the smallest necessary change, and verify with node-monitor itself.

## Non-negotiable rules

1. Start with read-only inspection. Do not guess cluster node names, IP addresses, SSH users, keys, or jump hosts.
2. Prefer a user-scoped install in `~/.local/bin`. Do not use `sudo` unless the user explicitly approves it.
3. Never change operating-system hostnames, DNS, Slurm configuration, firewall rules, SSH server settings, or existing SSH keys as part of this setup.
4. Preserve and merge `~/.ssh/config` and `~/.config/node-monitor/config.toml`. Back up an existing file before changing it and validate the result after the change.
5. Never print, copy, replace, or upload private key material. If a passphrase-protected key is required, prefer an already-running SSH agent.
6. Do not scan the network to invent an inventory. If Slurm, DNS, existing SSH configuration, and user-provided inventory do not supply an authoritative mapping, stop and ask the user.
7. Run node-monitor on a host with direct TCP reachability to the GPU nodes. The current Go client reads `HostName`, `User`, `Port`, and `IdentityFile` from OpenSSH config, but it does not execute `ProxyJump` or `ProxyCommand`.

## Node identity contract

Keep node identity separate from network addressing:

| Value | Example | Where it belongs |
|---|---|---|
| Canonical node ID | `gpu-01` | Slurm node name, SSH `Host` alias, and node-monitor `nodes`/`groups` |
| Routable address | `gpu-01.cluster.example` or `10.20.0.11` | SSH `HostName`, only when the canonical ID is not directly resolvable |
| Remote OS hostname | `gpu-01.internal` | Existing server configuration; node-monitor setup must not change it |

Use the Slurm node name as the canonical node ID when Slurm is available. Otherwise, use an existing stable SSH alias. If the only authoritative inventory contains IP addresses, create stable aliases such as `gpu-01` and map those aliases to the addresses with SSH `HostName`.

Prefer a stable FQDN over a literal IP when both are authoritative. IP addresses may change; node IDs should remain stable.

## Phase 1: inspect without changing anything

Establish the execution environment:

```bash
uname -s
uname -m
id -un
command -v node-monitor || true
command -v go || true
command -v sinfo || true
command -v ssh || true
command -v nvidia-smi || true
node-monitor --version 2>/dev/null || true
```

Check whether `~/.local/bin` is on `PATH`, whether the node-monitor config exists, and whether the SSH config exists. Do not dump private keys or unrelated configuration into the report.

If `sinfo` is available, collect exactly the names that node-monitor will discover:

```bash
sinfo -h -o '%n' | sed '/^[[:space:]]*$/d' | sort -u
```

For each candidate node, inspect OpenSSH's effective values without connecting:

```bash
ssh -G NODE 2>/dev/null | awk '$1 == "hostname" || $1 == "user" || $1 == "port" || $1 == "identityfile"'
```

Determine which of the following discovery modes applies before writing configuration.

## Phase 2: choose one discovery mode

### Mode A: Slurm auto-discovery

Use this mode when `sinfo -h -o '%n'` returns the intended GPU nodes.

- Omit the top-level `nodes` key from `~/.config/node-monitor/config.toml`; its presence takes precedence over Slurm discovery.
- Keep each Slurm node name as the canonical node ID.
- If a name is not directly resolvable, map that same name to its authoritative FQDN or IP in SSH config.
- Do not copy a transient `sinfo` result into `nodes`; leaving it unset lets new Slurm nodes appear automatically.

### Mode B: explicit inventory

Use this mode when Slurm is unavailable on the management host or when the user intentionally wants a fixed subset.

- Obtain the inventory from the user, existing SSH aliases, or another authoritative source.
- Put the stable aliases in the top-level `nodes` array.
- Use the same aliases as keys in optional `[groups]` entries.
- Put addresses in SSH `HostName`, not in a separate node-monitor address map. node-monitor does not have or need such a map.

### Mode C: Slurm plus curated groups

Use Slurm auto-discovery by default and add groups only for intentional subsets. Group members must use the same canonical node IDs returned by Slurm. Launch a group with `node-monitor --group NAME`.

## Phase 3: install or update node-monitor

Use one of the supported methods in the [README](../README.md#installation). Prefer the latest pre-built release for the detected OS and architecture, verify its published checksum, and place the binary in `~/.local/bin/node-monitor` with mode `0755`.

If a compatible Go toolchain is already installed, this user-scoped fallback is acceptable:

```bash
mkdir -p "${HOME}/.local/bin"
GOBIN="${HOME}/.local/bin" go install github.com/Reed-yang/node-monitor@latest
```

Do not pipe an unreviewed remote install script into a shell. If `~/.local/bin` is not on `PATH`, update the user's shell startup file minimally or explain the exact PATH change the user must make.

Verify installation before configuring the cluster:

```bash
command -v node-monitor
node-monitor --version
```

## Phase 4: configure SSH routing

Do not add SSH entries for nodes that already resolve and authenticate correctly.

When aliases require explicit addresses, prefer a managed include file if the existing `~/.ssh/config` already includes `~/.ssh/config.d/*`. Otherwise, back up the main config, add that `Include` directive once in a position consistent with the file's existing precedence, and validate every affected alias with `ssh -G`.

Example `~/.ssh/config.d/node-monitor`:

```sshconfig
Host gpu-01
    HostName 10.20.0.11
    User cluster-user
    IdentityFile ~/.ssh/id_ed25519

Host gpu-02
    HostName 10.20.0.12
    User cluster-user
    IdentityFile ~/.ssh/id_ed25519
```

Use permissions `0700` for `~/.ssh` and `~/.ssh/config.d`, and `0600` for SSH config files. Reuse an existing authorized identity or SSH agent; do not create, rotate, or distribute keys unless the user separately asks for key management.

If the cluster is reachable only through a bastion, do not claim success because `ssh` works through `ProxyJump`. Either run node-monitor on a login host with direct reachability or stop and explain that proxy support is a product limitation.

## Phase 5: configure node-monitor

Create or merge `~/.config/node-monitor/config.toml`. Do not add `nodes` in Mode A.

Slurm auto-discovery example:

```toml
interval = 2.0
workers = 8

[ssh]
connect_timeout = 5
command_timeout = 10
```

Explicit inventory example:

```toml
nodes = ["gpu-01", "gpu-02"]
interval = 2.0
workers = 8

[ssh]
connect_timeout = 5
command_timeout = 10

[groups]
train = ["gpu-01", "gpu-02"]
```

Prefer per-host `User`, `Port`, `HostName`, and `IdentityFile` settings in SSH config. Use the node-monitor `[ssh]` section for a cluster-wide user or identity only when it truly applies to every node.

## Phase 6: verify end to end

First test one representative node using non-interactive authentication:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 NODE 'hostname; command -v nvidia-smi; nvidia-smi --query-gpu=index,name --format=csv,noheader'
node-monitor --nodes NODE --static --debug
```

Then test the configured discovery path across the cluster:

```bash
node-monitor --static --debug
```

For each intended node, confirm:

- the canonical node ID is the expected Slurm name or SSH alias;
- `ssh -G` resolves it to the intended address and user;
- non-interactive SSH authentication succeeds;
- `nvidia-smi` exists and returns GPU data;
- node-monitor reports the node and GPU data without a routing or authentication error.

An administratively down, drained, or powered-off node may remain offline. Report it accurately; do not change scheduler or power state to make the check pass.

## Stop and ask the user when

- node names or address mappings conflict across Slurm, DNS, and SSH config;
- no authoritative inventory is available;
- authentication requires a password, a new key, or access not already granted;
- only a bastion/`ProxyJump` route is available;
- installation requires `sudo` or a system-wide change;
- an existing config has custom behavior that would be overwritten;
- a node lacks `nvidia-smi` or the user lacks permission to run it.

## Final report

Return a concise report containing:

1. installed node-monitor version and binary path;
2. selected discovery mode and its reason;
3. canonical node IDs and any alias-to-address mappings added;
4. files created or modified, including backup paths;
5. single-node and full-cluster verification results;
6. unresolved offline nodes or user actions still required.
