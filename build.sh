#!/bin/bash
set -uo pipefail

roc build bootstrap.roc --output bootstrap --target linux-x64 --prebuilt-platform

roc_exit_code=$?
# Exit code 2 means there were warnings but no errors
if [[ $roc_exit_code -ne 0 && $roc_exit_code -ne 2 ]]; then
    exit $roc_exit_code
fi
zip bootstrap.zip bootstrap
