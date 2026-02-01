# Jenkins Setup with Docker

This project provides a simple setup to run a Jenkins controller within a Docker container. It is pre-configured to allow Jenkins to access the host's Docker socket, enabling it to run Docker commands and manage other containers, which is essential for many CI/CD pipelines.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) must be installed and running on your local machine.

## Building the Docker Image

A `Dockerfile` is included to build a custom Jenkins image with Docker CLI installed. To build the image, navigate to the `Jenkins_Setup` directory and run:

```bash
docker build -t jenkins-docker .
```

## Running the Jenkins Container

To run the Jenkins container, use the following command. This command includes important volume mounts to persist Jenkins data and to connect to the host's Docker daemon.

```bash
docker run -p 8080:8080 -p 50000:50000 \
--mount source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind \
--mount source=jenkins_home,target=/var/jenkins_home,type=volume \
--mount "source=C:/Users/josev/DIR_C/public_lab1/Learn_CICD/",target=/Learn_CICD,type=bind \
--name jenkins-local4 \
-e JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true" \
jenkins-docker
```

### Command Explanation

-   `-p 8080:8080`: Maps port 8080 on the host to port 8080 in the container for the Jenkins web UI.
-   `-p 50000:50000`: Maps port 50000 for communication with Jenkins agents.
-   `--mount source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind`: Mounts the Docker socket from the host into the container. This allows Jenkins to execute Docker commands.
-   `--mount source=jenkins_home,target=/var/jenkins_home,type=volume`: Creates a named volume `jenkins_home` to persist Jenkins configuration, jobs, and build history.
-   `--mount "source=C:/Users/josev/DIR_C/public_lab1/Learn_CICD/",target=/Learn_CICD,type=bind`: Mounts the local project directory into the container, allowing Jenkins jobs to access the source code.
-   `--name jenkins-local4`: Assigns a name to the container for easy reference.
-   `-e JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true"`: Sets a Java option to allow Jenkins to check out Git repositories from the local filesystem.
-   `jenkins-docker`: The name of the Docker image to use.

## Accessing Jenkins

1.  Once the container is running, open your web browser and navigate to `http://localhost:8080`.
2.  The first time you access Jenkins, you will need to provide an administrator password. You can retrieve it from the container logs by running:

    ```bash
    docker logs jenkins-local4
    ```

3.  Copy the password from the logs, paste it into the setup screen, and follow the instructions to complete the initial setup.

## Persistent Data

The `jenkins_home` named volume ensures that your Jenkins data (jobs, plugins, configurations) is saved even if the container is removed and recreated. To manage the volume, you can use standard Docker commands like `docker volume ls` and `docker volume inspect jenkins_home`.
