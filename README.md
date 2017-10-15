# CharmMylynConnector
A Mylyn Connector for SAP Change and Request Management

## Installation
The ABAP ChaRM API (Z001_CHARM_MYLYN_API) can be installed using [ABAP GIT](https://github.com/larshp/abapGit).

The Eclipse Plugin can be installed via Maven. The core-project "net.bonprix.sap.solman.core" and the ui-project (net.bonprix.sap.solman.ui) will generate a .jar file which can be copied to the dropins folder of your Eclipse installation.

The core project needs several 3rd party libraries which can be installed by running maven from console using "mvn install -f lib_pom.xml".

The SDK for Mylyn can be downloaded from [here](http://download.eclipse.org/mylyn/releases/latest/). It includes an instruction for installing the Mylyn libraries.
