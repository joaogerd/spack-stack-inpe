# How to add a new site

## Goal

Add a new INPE HPC site to `spack-stack-inpe` without mixing machine infrastructure with application workflow logic.

## Steps

1. Collect machine diagnostics.
2. Identify compilers, MPI, modules, filesystem and scheduler.
3. Decide which packages should be external.
4. Create `configs/sites/<tier>/<site>/`.
5. Add `config.yaml`, `packages.yaml`, compiler-specific package files, `modules.yaml`, `mirrors.yaml` and `setup.sh`.
6. Create or reuse an environment definition.
7. Run concretization and installation.
8. Validate modules, MPI and CMake.
9. Document risks, limitations and unverified assumptions.

## Required evidence

Every new site must be based on observed command output or official machine documentation. Do not infer compiler, MPI or module paths from another cluster.
