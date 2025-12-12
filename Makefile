IMAGE ?= sparkfabrik/ops-base
TAG ?= latest
PLATFORMS ?= linux/amd64,linux/arm64
MULTIARCH_OUTPUT ?= type=cacheonly

# Preconfigured CLI: validates multi-arch (like CI) then builds/loads single-arch to run.
# Usage: make production-cli
production-cli: build-docker-image-multiarch build-docker-image run-cli

build-docker-image:
	docker buildx build --load -t $(IMAGE):$(TAG) -f Dockerfile .

# Multi-arch build mirroring CI (no output/load).
build-docker-image-multiarch:
	docker buildx build --platform $(PLATFORMS) -t $(IMAGE):$(TAG) -f Dockerfile --output=$(MULTIARCH_OUTPUT) .

run-cli:
	docker run --rm -v ${PWD}:/mnt \
		--hostname "SPARK-OPS-BASE-TEST" --name spark-k8s-ops-base \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-it $(IMAGE):$(TAG) bash -il
