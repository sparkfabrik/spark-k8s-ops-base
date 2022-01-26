# You can test the precunfigured command line enviroment running:
#
# make production-cli
#
production-cli: build-docker-image
  # Run the cli.
	docker run --rm -v ${PWD}:/mnt \
	--hostname "SPARK-OPS-BASE-TEST" --name spark-k8s-ops-base \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-it sparkfabrik/ops-base:latest bash -il

build-docker-image:
	@case "$$( uname -m )" in \
		arm*) $(eval BUILDX_PLATFORM := linux/arm64) ;; \
		*) $(eval BUILDX_PLATFORM := linux/amd64) ;; \
	esac
	@echo "The build target platform is ${BUILDX_PLATFORM}"
	docker buildx build --load --platform ${BUILDX_PLATFORM} -t sparkfabrik/ops-base:latest -f Dockerfile .
