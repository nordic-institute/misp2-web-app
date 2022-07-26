# Web application

This is the main web interface for MISP2. It handles the following aspects of the system:

 * user authentication and management
 * portal configuration and management
 * access rights
 * auditing
 * form generation
 * communicating with the X-Road Security Server

## Development

The application should be built from the root directory, which contains various Gradle tasks
to tie the web application together with it's dependencies on the Orbeon product.

### Building

The application can be built with the following command from the root directory:

```bash
./gradlew :web-app:war
```

### Development environment

The development environment documentation going over setting up the docker compose containers 
can be found under the root directory ([docker-dev/readme.md](../docker-dev/readme.md)).

### Deploying to the development environment

The application war can be built and deployed to the development environment with the following
command from the root directory:

```bash
./gradlew deployDevMisp
```
