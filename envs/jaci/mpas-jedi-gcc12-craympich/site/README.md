# JACI environment site include

## Purpose

This directory stores the site-specific include layer used by the validated JACI MPAS-JEDI spack-stack environment.

## Context

The validated environment uses:

```yaml
include:
  - site
  - common
```

This directory corresponds to the `site` include layer.

## Current files

```text
config.yaml
modules.yaml
packages.yaml
setup.sh
```

## Validation status

This directory has been reconstructed from the JACI validation audit and should be compared against the original validated environment:

```text
envs/mpas-bundle-jaci-gnu12/site/
```

## Open items

1. Confirm whether the reconstructed files exactly match the original validated files.
2. Confirm whether the install tree in `config.yaml` should remain user-specific or become an institutional template.
3. Keep GCC 13.2 out of this production layer unless explicitly validated.
