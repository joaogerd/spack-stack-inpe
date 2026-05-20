# spack-stack-inpe

INPE site configurations and operational documentation for deploying JCSDA `spack-stack` environments on INPE HPC systems.

The initial validated target is **JACI**, using JCSDA `spack-stack` `release/2.1`, CrayPE and Cray MPICH for future MONAN/JEDI and MPAS-JEDI work.

Portuguese version: [README.pt-BR.md](README.pt-BR.md)

## Overview

`spack-stack-inpe` stores site-specific configuration files, operational scripts and validation notes required to create reproducible `spack-stack` environments on INPE HPC systems.

The repository is designed to support MONAN, JEDI and MPAS-JEDI workflows without storing the MONAN, MPAS-JEDI or JEDI source trees.

## Motivation

INPE HPC systems require local adaptation of compilers, MPI, module systems, filesystem paths, schedulers and external packages. This repository records those decisions in a reproducible and auditable way.

The current JACI work is based on lessons learned from earlier EGEON work and from the dedicated JACI bootstrap repository. The goal now is to consolidate the stable site configuration and operational documentation into a single institutional repository.

## Relationship with MONAN, MPAS-JEDI and JEDI

This repository provides the validated software stack. MONAN/JEDI workflows consume this stack from separate repositories.

```text
spack-stack-inpe  -> creates and validates the software stack
MONAN-JEDI        -> builds and tests MONAN/JEDI or MPAS-JEDI using the stack
MONAN-bundle      -> application or bundle-level build and test workflows
```

## Current status

| Site | Status | Stack | Notes |
|---|---|---|---|
| JACI | active target | `spack-stack release/2.1` | CrayPE, Cray MPICH, PBS |
| EGEON | historical/legacy | `spack-stack 1.7.0` | SLURM, `gnu9`, OpenMPI |

## Main features

- JCSDA-compatible site layout.
- JACI site configuration.
- CrayPE setup procedure.
- Cray MPICH overlay and wrapper strategy.
- Reproducible validation scripts.
- Portuguese and English documentation.
- Operational troubleshooting notes.

## Repository layout

```text
spack-stack-inpe/
├── configs/        # site and environment configuration files
├── scripts/        # operational scripts for preparing and validating stacks
├── docs/           # MkDocs documentation in English and Portuguese
├── tests/          # smoke tests and validation helpers
├── README.md       # quick project entry point in English
├── README.pt-BR.md # quick project entry point in Portuguese
└── mkdocs.yml      # Material for MkDocs configuration
```

## Quick start for JACI

```bash
cd /p/projetos/monan_das/${USER}/projects

git clone https://github.com/joaogerd/spack-stack-inpe.git
cd spack-stack-inpe

export TEST_ID="spack-stack-inpe-validation-$(date -u +%Y%m%dT%H%M%SZ)"
export FRESH_INSTALL=1
export FORCE_SOURCE_BUILD=1
export INSTALL_JOBS=1
export SPACK_INSTALL_VERBOSE=1
export SPACK_INSTALL_FAIL_FAST=1

bash scripts/01_prepare_jaci_stack.sh
bash scripts/02_install_packages.sh
bash scripts/03_generate_tcl_modules.sh
bash scripts/04_validate_environment.sh
bash scripts/05_validate_cmake_findmpi.sh
bash scripts/06_collect_logs.sh
```

## Minimal usage example

After the stack has been validated:

```bash
source <generated-stack-env-script>
module avail
module load stack-gcc/<version>
module load stack-cray-mpich/<version>
module load jedi-mpas-env/<version>
```

## Documentation

Full documentation:

- [English documentation](docs/en/index.md)
- [Portuguese documentation](docs/pt-BR/index.md)

## Contributing

Use `develop` as the integration branch and create topic branches for documentation, fixes and site updates.

Recommended branch pattern:

```text
main         -> stable and publishable state
develop      -> integration branch
docs/*       -> documentation work
feature/*    -> new functionality
fix/*        -> corrections
refactor/*   -> structural changes
experiment/* -> non-production tests
```

See the development guide in the documentation for details.

## License

LGPL v3.0, unless a different institutional policy is explicitly defined.

## Project boundaries

This repository does not store MONAN, MPAS-JEDI or JEDI source code. It provides the validated `spack-stack` environment consumed by those projects.
