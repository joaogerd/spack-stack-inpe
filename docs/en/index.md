# spack-stack-inpe

`spack-stack-inpe` provides INPE site configurations, operational scripts and validation documentation for deploying JCSDA `spack-stack` environments on INPE HPC systems.

The current active target is JACI, using `spack-stack release/2.1`, CrayPE and Cray MPICH. Historical EGEON material is preserved as legacy context because it explains earlier decisions around `spack-stack 1.7.0`, SLURM and MPAS-JEDI build automation.

## Project boundary

```text
spack-stack-inpe  -> creates and validates the software stack
MONAN-JEDI        -> builds and tests MONAN/JEDI or MPAS-JEDI using the stack
MONAN-bundle      -> application or bundle-level build and test workflows
```

This repository must not store MONAN, MPAS-JEDI or JEDI source code.

## Main sections

- Getting started: first orientation for new users.
- Installation: operational stack creation procedure.
- Configuration: site and environment configuration files.
- Architecture: repository structure and design decisions.
- Cookbook: practical recipes.
- Reference: exact technical details.
- Development: contribution, testing and maintenance policy.
