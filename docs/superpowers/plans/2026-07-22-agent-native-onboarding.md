# Agent-native onboarding plan

**Goal:** Let a human delegate node-monitor installation and cluster onboarding to a coding agent with one copyable prompt, while giving the agent a deterministic and safe runbook for hostname, address, SSH, and Slurm discovery configuration.

## Scope

- Add a concise copy/paste prompt to `README.md`.
- Add an operator-facing agent runbook under `docs/`.
- Add a repository-level `AGENTS.md` that routes installation agents to the runbook and gives coding agents the authoritative implementation and verification commands.
- Clarify the node identity contract in the sample configuration.
- Record implementation findings and progress in `logs/`.

## Design constraints

- Preserve existing SSH and node-monitor configuration; agents must merge rather than overwrite.
- Treat the Slurm node name or a stable SSH alias as node-monitor's canonical node ID.
- Use SSH `HostName` for the routable FQDN or IP only when the canonical name is not directly resolvable.
- Never change an operating-system hostname, scheduler configuration, DNS, SSH keys, or firewall rules as part of onboarding.
- Prefer user-scoped installation and require explicit approval for privileged changes.
- Document only SSH features that the current Go client actually consumes.

## Tasks

- [x] Add `docs/agent-setup.md` with inspect, install, discover, configure, and verify phases.
- [x] Add root `AGENTS.md` with operator routing and contributor commands.
- [x] Add the human-to-agent prompt and identity model to `README.md`.
- [x] Improve comments in `configs/default.toml` without changing runtime defaults.
- [x] Run documentation checks and the Go test suite; review the final diff.
- [x] Update `logs/findings.md` and `logs/progress.md` with the completed design and validation.
