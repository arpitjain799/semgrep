#
# A container with semgrep in it, made to work from within the container.
# - changes the entrypoint to bash
# - installs some basic packages
#
# This is used for running semgrep benchmarks and other CI jobs without having
# to rebuild semgrep from scratch.
#

# Version of semgrep built each time the main ('develop') branch is updated.
# It's built from the main Dockerfile (semgrep.Dockerfile) in the semgrep repo.
#
# For things like benchmarks, we want a "recent version of semgrep that works".
#
FROM returntocorp/semgrep:develop

# Various utilities. We can always install them during the CI job but it's
# it's nice to do it here while we're root.
#
RUN apk add --no-cache \
  bash \
  curl \
  jq

# TODO: remove the explicit python3 install once our version of alpine has python3.11
#
# Install python >= 3.11 needed by pre-commit (for what operation?)
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main python3 && \
  python3 --version > /tmp/python-version && \
  grep -F 3.11 /tmp/python-version
# Install version XXX of pre-commit needed for YYY (requires python >= 3.11):
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing pre-commit

# Let the user know how their container was built
COPY dockerfiles/semgrep-dev.Dockerfile /Dockerfile

# cd ~
WORKDIR /home/semgrep

ENTRYPOINT ["/bin/bash"]
