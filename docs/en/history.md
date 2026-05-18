# History

This page records the technical evolution that led to `spack-stack-inpe`.

## EGEON phase

The earlier institutional work focused on EGEON, `spack-stack 1.7.0`, `gnu9`, OpenMPI, Lmod and SLURM. That work produced practical installation instructions, validation tests for NetCDF, HDF5 and MPI, and MPAS-JEDI build automation through `MONAN-bundle`.

## JACI bootstrap phase

The JACI phase introduced a different technical context: CrayPE, Cray MPICH, PBS/qsub, Cray PALS and machine-specific filesystem policy under `/p/projetos`.

The repository `jaci-spack-stack-bootstrap` was used as a technical laboratory to test diagnostics, site generation, local templates, CrayPE compiler drivers and MPI wrapper behavior.

## Consolidation phase

The current `spack-stack-inpe` repository should consolidate the stable site configuration and documentation while keeping application workflows in separate repositories.

## Important distinction

Historical material should be preserved when it explains decisions, but the active operational path must be clearly marked.
