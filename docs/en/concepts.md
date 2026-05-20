# Concepts

This page explains the main concepts used in `spack-stack-inpe`.

## Spack

Spack is the package manager used to build and compose scientific software environments.

## spack-stack

JCSDA `spack-stack` is a curated layer on top of Spack used by JEDI and related Earth system modeling workflows.

## Site

A site describes an HPC machine: compilers, MPI, modules, filesystem, mirrors, external packages and local Spack policy.

## Environment

An environment describes a concrete software stack to create from site configuration and package specifications.

## External package

An external package is a package provided by the system or vendor and reused by Spack instead of being built from source.

## Concretization

Concretization is the Spack step that resolves versions, variants, compilers, providers and dependencies into an installable DAG.

## CrayPE

CrayPE provides compiler drivers such as `cc`, `CC` and `ftn`. On JACI, these drivers are the correct interface to the Cray programming environment.
