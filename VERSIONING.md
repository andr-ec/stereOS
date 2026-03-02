# stereOS Versioning

stereOS uses unified calendar versioning with mixtape specific streams.

All mixtapes share a common base (the `modules/`, `lib/`, `profiles/`, etc.)
and share one version derived from git tags.
But each mixtape also has different individual packages and feature specific to their use case.

## Format

```
YYYY.0M.DD.N
```

- **YYYY** — four-digit year
- **0M** — zero-padded monthly
- **0D** - zero-padded day
- **N** — release counter for that day, starting at 0

Examples: `2026.03.01.0`, `2077.11.21.9`, `2030.01.01.100`

To see exactly what changed between two releases, compare the commit SHAs:

```bash
git log 2026.03.1..2026.03.2
```

## OCI mixtape format

Images are available in the `download.stereos.ai/mixtapes` OCI registry.
Each mixtape gets its own channel with a few utility tags available:

```
download.stereos.ai/mixtapes/coder:latest
download.stereos.ai/mixtapes/coder:nightly
download.stereos.ai/mixtapes/coder:2026.03.01.0
```

`latest` always points to the most recent tagged release.
`nightly` are unstable nightly builds. CI/CD selectively builds nightly releases
based on what's changed for a mixtape's packages, modules, profiles, etc.
Use at your own risk.
