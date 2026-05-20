# Configuration

This page explains how `spack-stack-inpe` organizes site and environment configuration.

## Configuration layers

```text
site configuration      -> describes the HPC machine
environment definition  -> describes the software stack to create
operational scripts     -> prepare, install, validate and collect logs
```

## Site configuration

Site files must describe the local infrastructure only:

```text
configs/sites/tier2/jaci/
├── config.yaml
├── mirrors.yaml
├── modules.yaml
├── packages.yaml
├── packages_gcc-*.yaml
├── setup.sh
└── README.md
```

The site layer should define compilers, MPI, externals, module paths, filesystem assumptions and local Spack settings.

## Environment configuration

Environment files define the stack that will be created for a scientific workflow.

Application-level dependencies belong in the environment or template layer, not in the generic site configuration.

## Rule

Do not mix machine infrastructure with MONAN/JEDI application workflow logic.
