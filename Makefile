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
	docker buildx build --platform linux/arm64 -t sparkfabrik/ops-base:latest -f Dockerfile .
