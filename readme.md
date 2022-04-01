# MISP2

[![Go to X-Road Community
Slack](https://img.shields.io/badge/Go%20to%20Community%20Slack-grey.svg)](https://jointxroad.slack.com/)
[![Get invited](https://img.shields.io/badge/No%20Slack-Get%20invited-green.svg)](https://x-road.global/community)

MISP2 (Mini-Information System Portal) is an application that provides an easy
way to query data over X-Road. Its easy-to-use web-based user interface provides
a unified way to access different services.

## About the repository

This respository contains the following modules:

* [install-source](./install-source) which contains the installation scripts and
  packaging related functionality
* [orbeon-war](./orbeon-war) which contains the build files for the customised
  [Orbeon Forms](https://www.orbeon.com/) instance
* [web-app](./web-app) which contains the source of the MISP2 web application 
  itself

The for source code for the modules `install-source`, 'orbeon-war' and `web-app`
of MISP2 is open for all and it is licensed under the MIT licence.

This repository also contains a git submodule [orbeon](./orbeon) which links to the
[GitHub repository of Orbeon Forms](https://github.com/orbeon/orbeon-forms).

## Development of MISP2

### How to build MISP2?

See the instructions in [build.md](./build.md)

### How to run the development packages locally

See the instructions in [docker-dev/readme.md](./docker-dev/readme.md)

## Documentation

More information about the software and how to use it can be found under the
[docs](./docs) directory, which contains the following documents:

* [Architecture](docs/misp2_architecture.md)
* [Installation guide](docs/misp2_installation_manual_18.04.md)
* [Manager guide](docs/misp2_manager_guide.md)
* [User guide](docs/misp2_user_guide.md)
* [Complex services](docs/misp2_creating_complex_queries.md)

## Support disclaimer

The following activities, among others, are undertaken by the [Nordic Institute
for Interoperability Solutions (NIIS)](https://www.niis.org/) with regard to the
MISP2 software:

* management, development, verification, and audit of the source code
* administration of documentation
* administration of business and technical requirements
* conducting development
* developing and implementing principles of licensing and distribution
* providing second-line support for the NIIS members
* international cooperation.

[X-Road Technology Partners](https://x-road.global/xroad-technology-partners)
are enterprises providing X-Road consultation services, e.g. deploying
independent X-Road instances, developing X-Road extensions and X-Road-compatible
services, integrating informations systems with X-Road etc.

No support for MISP2 deployment is provided here.

## Credits

* MISP2 was originally developed by the [Estonian Information System
  Authority](https://www.ria.ee/en.html) during 2015-2020.
* In 2020 it was agreed that [Nordic Institute for Interoperability Solutions
  (NIIS)](https://www.niis.org/) takes maintenance responsibility.
