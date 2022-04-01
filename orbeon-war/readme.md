# MISP2 Orbeon package

TODO: Change to more accurately reflect the current state

This is a component of the MISP2 software package used for packaging. The main
repository and documentation is available at
<https://github.com/nordic-institute/misp2-web-app>.


## Compiling the war

Add `ORBEON.ZIP` to the root directory of this project.
Replace the file name inside build.xml in the line `<unzip src="<ORBEON.ZIP faili nimi>" dest="${build.dir}">`.

Run:
```bash
ant war
```

The result of the `war` target is the file orbeon-misp2.war inside the
`build`directory.

## Datatable

datatable.css and datatable.xsl have been copied from eesti.ee orbeon component and slightly altered ("Forward", "Back") pagination button structure.
The rest of the datatable files have been copied from orbeon 4.4 private and public resource JAR files.
Datatable components are in folders:
custom/config/ops/yui/datatable
custom/xbl/orbeon/datatable

The altered datatable styles are added to MISP2 WebContent/resources/EE/css/xforms-ebmedded.css
In datatable.xsl, replace all xs: namespaces with xsd

