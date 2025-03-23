#!/bin/bash
set -ex -o pipefail
git pull --ff-only
git submodule update --init
