# MISP2 development environment

The development environment is set up using docker compose, with two containers:

 * `misp` - which contains the Tomcat server that houses both the MISP2 web application
   as well as the Orbeon installation.
 * `db` - which contains the Postgres instance that houses the MISP2 database. The container
   maps the database data to a volume so that re-creating the containers does not cause the
   setup to be lost.

## Running the environment

The environment can be started with the following command:

```bash
docker compose up -d
```

The environment can be stopped with the following command:
```bash
docker compose down
```

### First run

If the database has not been initialised, you will need to log in to the `misp` containers
once in has started and add the administrator user.

To log into the container, run the following command:

```bash
docker compose exec misp bash
```

Once inside the container, run the following commands:

```bash
cd /utils
./admintool.sh -add
```

This will prompt you to enter the username and password for the administrator user.

### Deploying the web application and Orbeon

To deploy the war files for the applications, move back to the root directory of the project
and execute the following command:

```bash
./gradlew deployDevOrbeon deployDevMisp
```
