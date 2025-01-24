# Use an official Python runtime as a parent image
FROM ubuntu


CMD ["echo", "hello world"]

# These labels will be changing at every build
# therefore we leave them at the end in order
# to minimise the amount of layers that are
# built every time.
ARG COMMIT
ARG BRANCH
ARG VERSION
ARG GIT_URL
LABEL COMMIT=${COMMIT} BRANCH=${BRANCH} VERSION=${VERSION}
LABEL org.opencontainers.image.source ${GIT_URL}