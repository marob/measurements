#!/bin/bash
set -euo pipefail

DOWNLOAD () {
    local RECD="${1}"
    local FILE="${2}"
    local LINK="https://zenodo.org/record/${RECD}/files/${FILE}?download=1${FILE}"
    curl "${LINK}" --output "${FILE}"
    aunpack "${FILE}"
}

DOWNLOAD 4492935 20210109-0.11.0-91cf51ddb8af003685eca89f96371fd2e7bb3c7e.tar.xz
DOWNLOAD 4492861 20200608-0.11.0-91cf51ddb8af003685eca89f96371fd2e7bb3c7e.tar.xz
DOWNLOAD 4704446 20210418-0.11.0-91cf51ddb8af003685eca89f96371fd2e7bb3c7e.tar.xz
DOWNLOAD 5115656 20210718-0.11.0-91cf51ddb8af003685eca89f96371fd2e7bb3c7e.tar.xz
DOWNLOAD 5583173 20211018-0.13.0-e3c0a0ad4d70494a7ed3051f5c118199bd56f0da.tar.xz
DOWNLOAD 5894853 20220118-0.13.0-e3c0a0ad4d70494a7ed3051f5c118199bd56f0da.tar.xz
DOWNLOAD 6510036 20220340-0.14.0-3eef1364a142426f508c29d1e6604b1ba3d7e23e.tar.xz
