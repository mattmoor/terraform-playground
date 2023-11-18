# `mattmoor` dev package build cluster

This provisions the build cluster I used to do stuff with Wolfi and our
enterprise packages via `melange`.

```
make BUILDWORLD=no MELANGE_EXTRA_OPTS="--runner kubernetes" package/busybox
```
