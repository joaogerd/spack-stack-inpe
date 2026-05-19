# Packages

This page documents package policy for `spack-stack-inpe`.

## Site layer

The site layer describes software already provided by the HPC machine and the package preferences required by that site.

## Environment layer

The environment layer describes the stack needed by a scientific workflow.

## Required documentation

For each important package decision, document:

- name;
- version;
- origin;
- required modules;
- compiler assumptions;
- MPI assumptions;
- validation command.

## JACI note

MPI package decisions must follow the CrayPE driver policy documented for JACI.
