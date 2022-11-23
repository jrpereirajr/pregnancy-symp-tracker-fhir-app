ARG IMAGE=intersystemsdc/irishealth-community:2020.3.0.200.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.4.0.547.0-zpm
ARG IMAGE=containers.intersystems.com/intersystems/iris:2021.1.0.215.0
ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

WORKDIR /home/irisowner/irisbuild

ARG TESTS=0
ARG MODULE="pregnancy-symp-tracker-fhir-app"
ARG NAMESPACE="IRISAPP"
ARG FHIRAAS_APIKEY

## Embedded Python environment
ENV IRISUSERNAME "_SYSTEM"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE $NAMESPACE
ENV PYTHON_PATH=/usr/irissys/bin/
ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

RUN --mount=type=bind,src=.,dst=. \
    pip3 install -r requirements.txt && \
    iris start IRIS && \
	iris session IRIS < iris.script && \
    ([ $TESTS -eq 0 ] || iris session iris -U $NAMESPACE "##class(%ZPM.PackageManager).Shell(\"test $MODULE -v -only\",1,1)") && \
    iris session iris -U IRISAPP "##class(Ens.Config.Credentials).SetCredential(\"fhiraas-apikey\",\"\",\"$FHIRAAS_APIKEY\")" && \
    iris session iris -U IRISAPP "##class(dc.apps.pregsymptracker.restapi.impl).ConfigTest()" && \
    iris stop IRIS quietly
