# MONAN/JEDI integration

`spack-stack-inpe` provides the validated software stack consumed by MONAN/JEDI workflows.

## Responsibility split

```text
spack-stack-inpe
  - site configuration
  - stack creation
  - stack validation
  - module generation
  - environment documentation

MONAN-JEDI or MONAN-bundle
  - source checkout
  - CMake/ecbuild configuration
  - build
  - ctest
  - application logs
```

## Expected workflow

1. Validate the JACI stack with `spack-stack-inpe`.
2. Record the validation identifier, for example `STACK_TEST_ID`.
3. Load the validated stack in the MONAN/JEDI workflow repository.
4. Configure, build and test MPAS-JEDI or MONAN-JEDI outside this repository.

## Boundary

Do not add MONAN or MPAS-JEDI source trees to this repository.
