# Missing internal Spack submodule

## Purpose

Document the fix for a JCSDA `spack-stack` checkout where the internal `spack/` directory was not populated.

## Symptom

When sourcing the JCSDA `setup.sh`, the shell reports errors like:

```text
spack/bin/spack: No such file or directory
spack/share/spack/setup-env.sh: No such file or directory
spack: command not found
```

## Cause

The JCSDA `spack-stack` repository uses an internal `spack/` checkout. If the repository is cloned without initializing submodules, `setup.sh` cannot find:

```text
spack/bin/spack
spack/share/spack/setup-env.sh
```

## Fix

From the root of the JCSDA `spack-stack` clone, run:

```bash
git submodule update --init --recursive
```

Then check:

```bash
test -x spack/bin/spack && echo OK_spack_bin
test -f spack/share/spack/setup-env.sh && echo OK_setup_env
```

After that, source the setup again:

```bash
source setup.sh
which spack
spack --version
```

## JACI command block

```bash
cd /p/projetos/monan_das/${USER}/work/spack-stack-inpe-test-release-2.1-gcc12/spack-stack

git submodule update --init --recursive

source configs/sites/tier2/jaci/setup.sh
source setup.sh

which spack
spack --version
```

## Validation status

This issue was observed during the clean JACI test of `spack-stack-inpe` with `spack-stack release/2.1`.
