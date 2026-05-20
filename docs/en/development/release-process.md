# Release process

## Goal

Create traceable validation points for `spack-stack-inpe`.

## Branch model

- `main` contains stable and publishable content.
- `develop` integrates reviewed changes.
- topic branches are merged into `develop` through pull requests.
- validated releases are promoted from `develop` to `main`.

## Validation tags

Suggested JACI tag format:

```text
jaci-spack-stack-2.1-gcc12-craympich-YYYYMMDD
```

A tag must correspond to reviewed logs and a reproducible validation run.
