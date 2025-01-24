DOCKER_IMAGE_NAME ?= abc
DOCKER_TAG ?= `cat ./VERSION`
DOCKER_REGISTRY ?= ghcr.io/sandeepnRES
GIT_URL = https://github.ibm.com/sandeepnRES/abc
DOCKER_IMAGE_SERVER = $(DOCKER_IMAGE_NAME):$(DOCKER_TAG)
DOCKER_IMAGE_SERVER_LATEST = $(DOCKER_IMAGE_NAME):latest

COMMIT = $(shell git log -1 --oneline | cut -d ' ' -f 1)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
TIMESTAMP = $(shell date +%FT%T%z)

# This target builds a fingerprint file that provides accountability for the
# docker image and also the binary. It can be used for introspection and 
# others troubleshooting activities. More importantly it provides traceability
# of the build artifacts back to the source.
fingerprint.json: 
	@echo -e "\033[1mBUILD\033[0m - Creating build fingerprint..."
	@echo "{ "\version\" : \""$(DOCKER_TAG)\"", "\"commit\" : \""$(COMMIT)"\", \"branch\" : \""$(BRANCH)"\", \"timestamp\" : \""$(TIMESTAMP)"\" }" > fingerprint.json

.PHONY: image-name
image-name:
	@echo ${DOCKER_IMAGE_SERVER}

.PHONY: image
image: fingerprint.json
	docker build  --build-arg COMMIT=$(COMMIT) --build-arg BRANCH=$(BRANCH) --build-arg VERSION=$(DOCKER_TAG) --build-arg GIT_URL=$(GIT_URL) -t $(DOCKER_IMAGE_SERVER) -f Dockerfile .
	docker tag $(DOCKER_IMAGE_SERVER) $(DOCKER_IMAGE_SERVER_LATEST)

.PHONY: check-if-tag-exists
check-if-tag-exists:
	!(DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_SERVER) > /dev/null)

.PHONY: push-server
push-server: check-if-tag-exists image
	@echo -e "\033[1mPUSH\033[0m - Pushing Docker image..."
	docker tag $(DOCKER_IMAGE_SERVER) $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_SERVER)
	docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_SERVER)

deploy:
	docker-compose up -d

stop:
	docker-compose down
