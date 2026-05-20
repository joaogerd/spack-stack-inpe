# Configuration files

## `config.yaml`

Defines local Spack configuration such as install trees, build stages and other site-level behavior.

## `packages.yaml`

Defines package preferences, providers and external packages common to the site.

## `packages_gcc-*.yaml`

Defines compiler-specific package configuration. On JACI this is where compiler and MPI assumptions must be carefully documented.

## `modules.yaml`

Defines how Spack generates environment modules.

## `mirrors.yaml`

Defines source or binary mirrors when available.

## `setup.sh`

Loads the base site environment before creating or using the stack.

## `spack.yaml`

Defines the environment to concretize and install.
