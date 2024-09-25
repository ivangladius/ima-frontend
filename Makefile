# Variables
IMAGE_NAME = flutter-web-app
CONTAINER_NAME = flutter-web-container
PORT = 8080

# Phony targets
.PHONY: build run stop rm clean rebuild logs

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the Docker container
run:
	docker run -d -p $(PORT):80 --name $(CONTAINER_NAME) $(IMAGE_NAME)

# Stop the Docker container
stop:
	docker stop $(CONTAINER_NAME)

# Remove the Docker container
rm:
	docker rm $(CONTAINER_NAME)

# Clean up (stop and remove the container)
clean: stop rm

# Rebuild the Docker image and run the container
rebuild: clean build run

# Show logs from the container
logs:
	docker logs -f $(CONTAINER_NAME)