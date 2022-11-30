ARG IMAGE=intersystemsdc/irishealth-community:2020.3.0.200.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.4.0.547.0-zpm
ARG IMAGE=containers.intersystems.com/intersystems/iris:2021.1.0.215.0
ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

USER root 

WORKDIR /home/irisowner/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /home/irisowner/irisbuild

USER ${ISC_PACKAGE_MGRUSER}

ARG TESTS=0
ARG MODULE="pregnancy-symp-tracker-fhir-app"
ARG NAMESPACE="IRISAPP"
ARG SYSTEM_PWD="SYS"
ARG FHIRSERVER_APIKEY

## Embedded Python environment
# ENV IRISUSERNAME "_SYSTEM"
# ENV IRISPASSWORD "SYS"
# ENV IRISNAMESPACE $NAMESPACE
# ENV PYTHON_PATH=/usr/irissys/bin/
# ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

COPY src src
COPY iris.script iris.script
COPY Installer.cls Installer.cls
COPY module.xml module.xml

RUN iris start IRIS && \
	iris session IRIS < iris.script && \
    ([ $TESTS -eq 0 ] || iris session iris -U $NAMESPACE "##class(%ZPM.PackageManager).Shell(\"test $MODULE -v -only\",1,1)") && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Util).ChangePassword(\"_system\",\"$SYSTEM_PWD\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Util).ChangePassword(\"CSPSystem\",\"$SYSTEM_PWD\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Util).ChangePassword(\"Admin\",\"$SYSTEM_PWD\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Util).ChangePassword(\"_Ensemble\",\"$SYSTEM_PWD\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Util).ChangePassword(\"irisowner\",\"$SYSTEM_PWD\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Util).DisabledUser(\"SuperUser\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Util).DisabledUser(\"UnknownUser\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Util).DisabledUser(\"IAM\")" && \
    iris session iris -U IRISAPP "##class(Ens.Config.Credentials).SetCredential(\"fhirserver-apikey\",\"\",\"$FHIRSERVER_APIKEY\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.restapi.impl).ConfigTest()" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.util.Example).Main()" && \
    iris stop IRIS quietly
