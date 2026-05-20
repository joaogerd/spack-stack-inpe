# Validation tags

Validation tags identify stack states that were reproduced and reviewed.

## Suggested format

```text
jaci-spack-stack-2.1-gcc12-craympich-YYYYMMDD
```

## Minimum requirements

Before creating a validation tag:

- run with a new `TEST_ID`;
- use a fresh install tree;
- preserve logs;
- review concretization and installation output;
- validate modules;
- validate CMake `FindMPI`;
- have another user reproduce the procedure when possible.

## What the tag means

A validation tag means the stack creation procedure reached the documented success criteria. It does not automatically validate every application workflow that may use the stack.
