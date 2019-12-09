# T-Kernel2.0
[![github-action](https://github.com/Matts966/T-Kernel2.0/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/Matts966/T-Kernel2.0/actions)

## Quick Start

To start kernel process in emulator, 

```
make
```

If it fails, you can use remote image by,

```
docker run -it --rm matts966/tkernel2.0
```

You can develop by writing `src/usermain.c`.
The `src` directory is copied as user source code.

## Requirement

- docker installation

## License

This repository is distributed under [T-License](https://www.tron.org/download/index.php?route=information/information&information_id=40).
