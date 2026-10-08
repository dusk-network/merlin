# Merlin — AI Agent Instructions

## Project Overview

**dusk-merlin** is Dusk's maintained fork of Merlin 3.0.0, a STROBE-based
transcript and synthetic RNG for zero-knowledge proofs. Single crate, no
workspace. The package is `dusk-merlin`; the Rust library target remains
`merlin` (`use merlin::Transcript`).

### Key Files

| Path | Purpose |
|------|---------|
| `src/transcript.rs` | Transcript framing, challenges, witness-bound RNG |
| `src/strobe.rs` | Minimal STROBE-128 operations and Keccak state |
| `src/constants.rs` | Protocol domain-separation label |
| `src/lib.rs` | Public exports, `no_std` and endianness gates |
| `README.md` | Included in crate documentation through `src/lib.rs`; validate edits with `make doc` |
| `tests/compatibility.rs` | Fixed upstream transcript/RNG vectors and borrowed-label coverage |

## Commands

The toolchain file selects stable Rust; the declared MSRV is Rust 1.96.1.
Use the Makefile targets rather than assuming sibling crates' flags apply.

```sh
cargo build
make test                 # All features, including unit/integration/doc tests
cargo test                # Default features
make cq                   # Formatting check and Clippy
make fmt                  # Apply formatting
make fmt CHECK=1           # Check formatting without changing files
make clippy               # All targets/features; warnings denied
make no-std               # No-default-features build for wasm32-unknown-unknown
make doc                  # All-feature docs; warnings denied
```

`make no-std` installs the WASM target when possible; it builds but does not
execute WASM tests. No nightly toolchain is required for these commands.

For toolchain or dependency changes, also verify the declared minimum:

```sh
cargo +1.96.1 test --all-features
rustup target add --toolchain 1.96.1 wasm32-unknown-unknown
cargo +1.96.1 build --no-default-features --target wasm32-unknown-unknown
```

### PR Minimum

```sh
make test
make cq
make no-std
make doc
```

For documentation-only changes, check the documented commands and links;
do not change production code or regenerate vectors as incidental cleanup.

## Compatibility and Elevated Care

This is cryptographic code used by downstream proof systems. A transcript
change can invalidate proofs or weaken protocol binding.

- Preserve Merlin 3.0 transcript and transcript-RNG outputs. Keep the
  `Merlin v1.0` protocol label independent of the package version.
- Preserve framing, little-endian length/integer encoding, STROBE operation
  flags, permutation boundaries, and witness/external-randomness binding.
- Treat `keccak` upgrades as transcript-critical: verify unchanged transcript
  and RNG outputs against the independent compatibility vectors.
- Treat incompatible `rand_core` upgrades as public API breaking changes:
  its traits appear in `TranscriptRng` and `TranscriptRngBuilder::finalize`.
- Keep the `merlin` library target even though the package is `dusk-merlin`.
- Support little-endian targets only. The big-endian compile error is
  deliberate; do not remove it without independent compatibility evidence.
- Preserve the layout and alignment required by the Keccak state cast and
  state zeroization. Do not introduce unsafe code as speculative optimization.
- Preserve `no_std`: gate `std` imports and dependencies appropriately.
- `std` is enabled by default. `debug-transcript` enables `std` and prints
  transcript data; it is for development only, not production builds.
- Never log witness data or RNG entropy. Avoid suppressing Clippy warnings.
- Benchmark optimizations against realistic callers, and retain independent
  compatibility tests. A local speedup does not justify protocol changes.

## Change Propagation

Validate transcript and RNG changes through Plonk, then Phoenix circuits and
Rusk. Check proof generation, verification, and historical proof compatibility;
use these downstream workloads when benchmarking optimizations.

## Compatibility Vector Provenance and Regeneration

The fixed vectors in `tests/compatibility.rs` come from **untouched upstream
Merlin 3.0.0**, tag `3.0.0`, commit
`a94892f457202399661573480bb7250b4fe7c0af` in
`https://github.com/zkcrypto/merlin`.

Use a separate checkout, never this fork, as the output oracle:

```sh
git clone https://github.com/zkcrypto/merlin merlin-upstream-3.0.0
git -C merlin-upstream-3.0.0 checkout --detach a94892f457202399661573480bb7250b4fe7c0af
git -C merlin-upstream-3.0.0 rev-parse HEAD
```

1. Confirm the checkout matches that exact commit. Do not modify upstream
   production source or `Cargo.toml`, including its dependency declarations.
2. To verify the existing literals, copy `FixedRng`, its imports/implementations,
   and the three `*_matches_merlin_3_0_0` tests into a new file
   `tests/dusk_vectors.rs` in the upstream checkout. Do not copy the
   fork-specific borrowed-label test: upstream requires static labels.
3. Run `cargo +1.96.1 test --test dusk_vectors` from that checkout. Unchanged
   literals must pass against upstream as well as this fork.
4. For new coverage, put the exact input construction and `FixedRng` in a
   temporary upstream example, print the resulting byte arrays, and run it
   with `cargo +1.96.1 run --example <name>`. Copy those output literals into
   the fork's test, preserving operation order, labels, lengths, witness
   bytes, and external RNG seed/state. Record the upstream commit provenance.
5. Check `git diff --exit-code a94892f457202399661573480bb7250b4fe7c0af -- src Cargo.toml`
   in the upstream checkout, then run `make test` in the fork.

Never regenerate expected output using this fork to make a failing test pass.
A mismatch requires investigation, not replacement of the compatibility
boundary. Keep new coverage separate from intentional protocol changes; the
latter require an explicit downstream compatibility decision.

## Git

- Branch from `main`; do not push directly to it.
- Follow recent commit style: `docs: ...`, `fix: ...`, `test: ...`, `chore: ...`.
- Keep each commit scoped to one concern. Separate dependency upgrades,
  behavior changes, and unrelated documentation or cleanup.
- Do not bump versions, tag releases, or publish packages without explicit
  authorization.

## Changelog

Update `CHANGELOG.md` under `[Unreleased]` for user-visible changes only. Exclude tests, CI, tooling, and refactors.

- One fact per entry. Name the public item and behavior, including the affected released item if breaking. Leave implementation, rationale, consequences, and migration to the linked issue.
- Use existing `Added`, `Changed`, or `Removed` sections. Use `Fixed` only for released bugs. Correct unreleased bugs in their original entry.
- Link only the GitHub issue, not the PR. Match existing link style and define references below. Preserve other entries and follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and Markdown blank-line spacing.
