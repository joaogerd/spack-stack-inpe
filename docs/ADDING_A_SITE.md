# Adding a new INPE site

This guide describes the minimum structure required to add another site or machine to `spack-stack-inpe` without duplicating the JACI workflow.

## 1. Choose the site name

Use a short lowercase name:

```text
jaci
egeon
example-site
```

The examples below use `example-site`.

## 2. Create the site configuration directory

Prefer the same layout used by JCSDA `spack-stack`:

```text
configs/sites/tier2/example-site/
```

At minimum, this directory should contain:

```text
README.md
setup.sh
site.env
config.yaml
packages.yaml
modules.yaml
mirrors.yaml
```

Compiler-specific package files may be added when needed:

```text
packages_gcc-12.3.yaml
packages_intel-2024.yaml
```

## 3. Do not create an INPE environment template by default

Do not add a copied environment under:

```text
envs/example-site/<environment-name>/
```

The scientific environment should come from the selected JCSDA `spack-stack` release and template.

The generated environment will be created at runtime by:

```bash
spack stack create env \
  --site example-site \
  --template <jcsda-template> \
  --compiler <compiler> \
  --name <environment-name> \
  --prefix <install-prefix>
```

Only add an `envs/` tree to this repository if INPE intentionally starts maintaining a modified scientific stack that differs from JCSDA.

## 4. Create `site.env`

The `site.env` file connects the generic scripts to the site-specific layout and to the JCSDA environment template selected for that site.

Minimal example:

```bash
export DEFAULT_PROJECT_ROOT="/path/to/project/root/${USER}"
export DEFAULT_TEST_ID="spack-stack-inpe-example-site-test"
export DEFAULT_ENV_NAME="example-site-skylab-dev-gcc12-openmpi"

export JCSDA_SITE_NAME="example-site"
export JCSDA_ENV_TEMPLATE="skylab-dev"
export JCSDA_COMPILER="gcc-12.3"

export DEFAULT_SPACK_STACK_REPO="https://github.com/JCSDA/spack-stack.git"
export DEFAULT_SPACK_STACK_REF="release/2.1"
export DEFAULT_SPACK_STACK_INPE_REPO="https://github.com/joaogerd/spack-stack-inpe.git"
export DEFAULT_SPACK_STACK_INPE_REF="main"

export DEFAULT_SITE_STACK_PATH="configs/sites/tier2/example-site"

export SITE_BASE_ENV_SCRIPT="scripts/sites/example-site/load_base_environment.sh"
export SITE_USES_CRAY_MPICH_OVERLAY="0"
```

Use `SITE_USES_CRAY_MPICH_OVERLAY=1` only for a CrayPE site that needs the external `cray-mpich` overlay behavior.

## 5. Create a site base environment loader

Create:

```text
scripts/sites/example-site/load_base_environment.sh
```

This file should load the modules and define compiler variables for that site.

Minimal example:

```bash
#!/usr/bin/env bash
set -euo pipefail

module purge
module load gcc/12.3
module load openmpi/4.1.6

export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export F90=gfortran
```

For CrayPE systems, this script may load `PrgEnv-*`, `cray-mpich`, `libfabric`, target modules and define `CC=cc`, `CXX=CC`, `FC=ftn`.

## 6. Run the workflow for the new site

```bash
SITE=example-site bash scripts/01_prepare_jaci_stack.sh
SITE=example-site bash scripts/02_install_packages.sh
SITE=example-site bash scripts/03_generate_tcl_modules.sh
SITE=example-site bash scripts/04_validate_environment.sh
SITE=example-site bash scripts/05_validate_cmake_findmpi.sh
SITE=example-site bash scripts/06_collect_logs.sh
```

The first script name still contains `jaci` for compatibility with the current workflow. The selected site is controlled by `SITE` and `site.env`.

## 7. Validation checklist

Before considering the site usable, collect evidence for:

```text
spack arch
spack stack create env output
spack config blame config
spack config blame packages
spack config blame compilers
spack config blame modules
spack concretize -f
spack install
spack module tcl refresh -y
module load <generated-env-module>
python import checks
CMake FindMPI check
```

Do not tag or document the site as validated until the logs are reviewed.

## 8. Avoiding duplication

Do not copy the full JACI scripts for every new machine.

Add only:

```text
configs/sites/tier2/<site>/site.env
configs/sites/tier2/<site>/*.yaml
configs/sites/tier2/<site>/setup.sh
scripts/sites/<site>/load_base_environment.sh
```

Keep the numbered scripts under `scripts/` generic whenever possible.
