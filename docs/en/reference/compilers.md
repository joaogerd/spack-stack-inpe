# Compilers

This page documents compiler policy for `spack-stack-inpe`.

## JACI compiler model

The JACI line uses the Cray programming environment. The active compiler interface is provided by CrayPE drivers:

```text
cc
CC
ftn
```

## What to document

For each compiler configuration, record:

- loaded modules;
- compiler version reported by the driver;
- paths resolved by `which`;
- Spack compiler spec;
- target architecture;
- validation command output.

## Rule

Do not assume that a compiler module name is equivalent to the compiler version reported by the compiler driver. Always validate with real command output.
