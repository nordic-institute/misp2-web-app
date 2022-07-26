# MISP2 Orbeon package

This folder contains the customisations for Orbeon.

## Prerequisites

This project relies of the `orbeon` git submodule to be initiated. To do this, run the
following command in the projects root directory:

```bash
git submodule init && git submodule update
```

## Building the war file

To build the war file, run the following command in the root directory of the project:

```bash
./gradlew :orbeon-war:war
```

## Datatable

The `datatable.css` and `datatable.xsl` files have been copied from the eesti.ee Orbeon component
with a slightly altered ("Forward", "Back") pagination button structure.

The rest of the datatable files have been copied from Orbeon private and public resource JAR files.

The datatable components are in the following folders:

 * custom/config/ops/yui/datatable
 * custom/xbl/orbeon/datatable
