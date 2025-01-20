#!/bin/bash
set -e

# check if git working copy is dirty, if so, commit changes
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "WIP"
fi

BUILDER_UID="$(id -u)"
BUILDER_GID="$(id -g)"
CACHE_DIR="${CACHE_DIR:-$HOME/hassos-cache}"
ARGS="$*"
COMMAND="${ARGS:-bash}"

mkdir -p "${CACHE_DIR}"
chown -R "${BUILDER_UID}:${BUILDER_GID}" "${CACHE_DIR}"
docker build --progress=plain -t hassos:local .

# Make sure loop devices are present before starting the container
#sudo losetup -f > /dev/null

# shellcheck disable=SC2086
docker run -it --rm --privileged \
  -v "$(pwd)/output:/build/output" -v "${CACHE_DIR}:/cache" \
  -e BUILDER_UID="${BUILDER_UID}" -e BUILDER_GID="${BUILDER_GID}" \
  hassos:local ${COMMAND}
