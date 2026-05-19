# spack-stack-inpe architecture

This repository stores INPE site configuration and operational scripts for using the JCSDA `spack-stack` on INPE HPC systems.

The main design rule is:

```text
JCSDA spack-stack defines the scientific environment
INPE spack-stack-inpe defines the site configuration for INPE machines
```

Generic workflow logic must not contain machine-specific assumptions. Machine-specific assumptions must live under a site directory or a site script.

## Current repository roles

```text
configs/sites/
```

Stores files that are copied into the JCSDA `spack-stack` tree. These files follow the upstream `spack-stack` site layout as closely as possible. For JACI, the current path is:

```text
configs/sites/tier2/jaci/
```

This directory contains the Spack configuration files consumed by `spack-stack`, such as `packages.yaml`, `modules.yaml`, `config.yaml`, `mirrors.yaml`, `setup.sh` and compiler-specific package files.

```text
scripts/
```

Stores user-facing workflow scripts. The numbered scripts define the operational sequence:

```text
01_prepare_jaci_stack.sh
02_install_packages.sh
03_generate_tcl_modules.sh
04_validate_environment.sh
05_validate_cmake_findmpi.sh
06_collect_logs.sh
```

The name of `01_prepare_jaci_stack.sh` is preserved for compatibility with the current JACI procedure, but the internals now use site-aware configuration.

```text
scripts/lib/
```

Stores generic shell helpers used by several workflow scripts. These helpers load site configuration, initialize common paths and activate the generated `spack-stack` environment.

Generic helpers must not hard-code JACI, CrayPE, PBS, paths under `/opt/cray`, or module names.

```text
scripts/sites/<site>/
```

Stores site-specific helper scripts. For example:

```text
scripts/sites/jaci/load_base_environment.sh
```

This script is allowed to contain JACI-specific CrayPE module logic because it belongs to the JACI site layer.

```text
docs/
```

Stores project documentation. Site-specific operational manuals should be kept under language-specific documentation directories when needed.

## Environment ownership

This repository should not maintain a copied JCSDA environment under `envs/<site>/<environment>` at this stage.

The JCSDA `spack-stack` already provides the mechanism to create environments from official templates through:

```bash
spack stack create env \
  --site <site> \
  --template <template> \
  --compiler <compiler> \
  --name <environment-name> \
  --prefix <install-prefix>
```

The generated environment lives inside the working copy of JCSDA `spack-stack`:

```text
<work-root>/spack-stack/envs/<environment-name>/
```

That generated directory is a build artifact, not source maintained by `spack-stack-inpe`.

## Site runtime configuration

Each supported site should provide a `site.env` file. For JACI:

```text
configs/sites/tier2/jaci/site.env
```

This file defines script-level defaults such as:

```text
DEFAULT_PROJECT_ROOT
DEFAULT_TEST_ID
DEFAULT_ENV_NAME
DEFAULT_SPACK_STACK_REF
DEFAULT_SITE_STACK_PATH
JCSDA_SITE_NAME
JCSDA_ENV_TEMPLATE
JCSDA_COMPILER
SITE_BASE_ENV_SCRIPT
```

It may also define site-specific module names, compiler driver paths, external MPI prefixes and validation module names.

## What is generic

The following concepts are generic:

```text
clone or update JCSDA spack-stack
clone or update spack-stack-inpe
copy selected INPE site files into the JCSDA spack-stack tree
use JCSDA spack-stack tooling to create the environment
patch runtime paths for the current validation run
source the selected site setup.sh
activate the generated Spack environment
run concretize, install, module generation and validation
collect logs
```

These actions should remain in reusable scripts or helper functions.

## What is site-specific

The following concepts are site-specific:

```text
module paths
module names and versions
compiler driver paths
MPI external provider
CrayPE-specific behavior
scheduler defaults
institutional filesystem paths
site-specific Spack externals
site-specific package variants
selected JCSDA template/compiler for the site
site-specific validation modules
```

These values must live in `configs/sites/<layout>/<site>/site.env`, `configs/sites/<layout>/<site>/setup.sh`, site YAML files, or `scripts/sites/<site>/`.

## Current JACI-specific facts

The current validated JACI target remains:

```text
spack-stack release/2.1
PrgEnv-gnu/8.6.0
gcc-native/12.3
cray-mpich/8.1.31
CrayPE drivers cc, CC and ftn
```

The Cray MPICH overlay is also site-specific. It exists because the JACI CrayPE environment requires MPI compilation through `cc`, `CC` and `ftn`, while several Spack recipes ask an external MPI package for `mpicc`, `mpicxx` or `mpifort`.

## Compatibility rule

The existing JACI workflow should remain usable with:

```bash
bash scripts/01_prepare_jaci_stack.sh
bash scripts/02_install_packages.sh
bash scripts/03_generate_tcl_modules.sh
bash scripts/04_validate_environment.sh
bash scripts/05_validate_cmake_findmpi.sh
bash scripts/06_collect_logs.sh
```

The default site is `jaci`. Future sites should be selected with:

```bash
SITE=<site-name> bash scripts/<script>.sh
```

## Design limits for this refactor

This is intentionally not a full framework. It does not introduce a new Python CLI, templating engine or automatic Spack configuration generator.

The goal is to separate concepts cleanly while preserving the current manual JACI workflow.
