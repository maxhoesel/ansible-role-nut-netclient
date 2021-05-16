#!/usr/bin/env bash
set -eu
set -o pipefail

# Lint ansible roles and git commits
tox -e lint

# Molecule tests - this grabs all molecule scenarios and executes them.
# Note that to run this command, you need to have
# - run and tox command at least once (tox -l is fine)
tox -e "$(tox -l | grep ansible | grep -v "lint" | tr '\n' ',')"
