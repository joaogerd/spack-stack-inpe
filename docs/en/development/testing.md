# Testing

Testing in `spack-stack-inpe` is validation-oriented.

## Required validation areas

- YAML syntax.
- Shell script execution.
- Spack concretization.
- Package installation.
- Tcl module generation.
- MPI wrapper consistency.
- CMake `FindMPI` behavior.
- Log collection.

## Suggested command sequence

```bash
bash scripts/01_prepare_jaci_stack.sh
bash scripts/02_install_packages.sh
bash scripts/03_generate_tcl_modules.sh
bash scripts/04_validate_environment.sh
bash scripts/05_validate_cmake_findmpi.sh
bash scripts/06_collect_logs.sh
```

## Tagging requirement

A validation tag should only be created after a second person reproduces the full workflow with a new `TEST_ID`, a fresh install tree and reviewed logs.
