# Troubleshooting

Troubleshooting entries must separate confirmed facts, technical hypotheses, suggested tests and unresolved points.

## Recommended structure

```text
Symptom
Confirmed facts
Technical hypothesis
Diagnostic commands
Proposed solution
Validation
Risks and limitations
```

## Common topics

- Spack lock timeout.
- Concretization failures.
- Incorrect MPI wrapper discovery.
- CMake `FindMPI` failures.
- Module tree not visible.
- Stale Spack cache.
- Unexpected use of `$HOME` for heavy builds.
- `parallel-netcdf` optional benchmark failures.

## Basic diagnostics

```bash
module list
which cc CC ftn
which mpicc mpicxx mpifort
spack debug report
spack find
env | sort
```
