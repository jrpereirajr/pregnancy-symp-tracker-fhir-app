 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/pregnancy-symp-tracker-fhir-app)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=jrpereirajr/pregnancy-symp-tracker-fhir-app&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=jrpereirajr/pregnancy-symp-tracker-fhir-app)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=jrpereirajr/pregnancy-symp-tracker-fhir-app&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=jrpereirajr/pregnancy-symp-tracker-fhir-app)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

- [Pregnancy Symptoms Tracker](#pregnancy-symptoms-tracker)
  * [Description](#description)
  * [Team](#team)
  * [Technical overview](#technical-overview)
  * [Installing using ZPM](#installing-using-zpm)
  * [Installing using Docker](#installing-using-docker)
  * [Config](#config)
  * [Trying the app](#trying-the-app)

# Pregnancy Symptoms Tracker

This is an example of how to FHIR to help pregnants to track their symptoms and share with health caregivers.

## Description

Usually, pregnant women have a lot of changes in their daily routines with several symptoms. Most of them usually are normal and non harmful ones, but some of them could be important signs that something is not good and caregivers need to be reported.

This application uses InterSystems technologies in order to help pregnant women to report their symptoms and caregivers to assist such patients.

This application was developed for the InterSystems IRIS for Health Contest: FHIR for Women's Health.

## Team

* [Henrique Dias](https://community.intersystems.com/user/henrique-dias-2)
* [José Roberto Pereira](https://community.intersystems.com/user/jos%C3%A9-roberto-pereira-0)
* [Henry Pereira](https://community.intersystems.com/user/henry-pereira)

## Technical overview

The following InterSystems technologies was used in this project:

* InterSystems IRIS Platform, providing general functionalities such as persistence, Web layer, REST API, security, and so on
* InterSystems FHIR Server, providing CRUD for FHIR resources

Those technologies are used as depicted by the following diagram:

![Application general architecture](https://github.com/jrpereirajr/pregnancy-symp-tracker-fhir-app/raw/master/img/W3U0DcpPRr.png)

The patient accesses the application using a web browser.

The application web resources are handled by the [IRIS Web Gateway[(https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GCGI_intro). Such resources use the application REST API, supported by the [IRIS REST Services](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GREST_intro).

The application REST API uses IRIS ObjectScript classes to perform the application logic. Such logic includes usage of the [InterSystems FHIR Server](https://docs.intersystems.com/services/csp/docbook/DocBook.UI.Page.cls?KEY=PAGE_fas) service for FHIR resources handling and local IRIS persistence for additional information.

The FHIR Server provides a REST API for performing CRUD operations via the [HL7 FHIR standard](https://hl7.org/fhir/). This standard has a rich abstraction set for dealing with healthcare. Such abstractions are called resources in FHIR.

The application REST API uses the FHIR Server REST API in order to handle FHIR requests. The authentication is done by an API KEY generated by FHIR Server and stored in IRIS Interoperability credentials.

This application uses the FHIR resources [Patient](https://build.fhir.org/patient.html), [Practitionner](https://www.hl7.org/fhir/practitioner.html) and [Observation](https://build.fhir.org/observation.html). Patients' resources are bound to IRIS users and Observation resources are used to store the patient's symptoms.

## Installing using ZPM

```
USER>zpm "pregnancy-symp-tracker-fhir-app"
```

## Installing using Docker

If the online demo is not available anymore or you would like to play with the project code, you can set up a docker container. In order to get your container running, follow these steps:

Clone/git pull the repo into any local directory

```
$ git clone git@github.com:jrpereirajr/pregnancy-symp-tracker-fhir-app.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## Config

After ZPM installation, you need to create a configuration object like this one:

```
Set ^restapi.FHIRaaSClient = {"config": {
    "Server": "fhir.ghim09twjq5g.static-test-account.isccloud.io",
    "Port": 443,
    "UseHTTPS": 1,
    "SSLConfig": "default",
    "APIKeyCred": "fhirserver-apikey"
}}.%ToJSON()
```

Where `Server` is your FHIR Server address and `APIKeyCred` is an IRIS Interoperability credential with the FHIR Server API KEY.

You can create a credential using the [IRIS portal](http://localhost:64756/csp/sys/%25CSP.Portal.Home.zen) in the menu Interoperability >> Credentials. Click on the New button, inform the credential ID and the FHIR Server API KEY in the Password field, then save by hitting the Save button.

![IRIS Interoperability Credentials](https://github.com/jrpereirajr/pregnancy-symp-tracker-fhir-app/raw/master/img/qxDSg8Lk5o.png)

## Trying the app

Access the application [here](http://localhost:64756/csp/preg-symp-tracker/index.csp).

Use the following users in order to try the demo:

| User          | Password      | Role
|---------------|---------------|---------------
| MarySmith     | marysmith     | Patient
| SuzieMartinez | suziemartinez | Patient
| AnneJackson   | annejackson   | Doctor/Patient
| PerterMorgan  | pertermorgan  | Doctor

When you log in as a patient, you can manage symptoms in the [My Symptoms](http://localhost:64756/csp/preg-symp-tracker/patient.csp) page or check out some metrics in the [My Dashboard](http://localhost:64756/csp/preg-symp-tracker/dashboardpatient.csp) page.

When you log in as a doctor, you can see the doctor's patients list in the [Doctor Dashboard](http://localhost:64756/csp/preg-symp-tracker/doctor.csp) page.

When you log in with a user having both roles, you can access all the pages.

Here are some screenshots:

![Patient symptoms page](https://github.com/jrpereirajr/pregnancy-symp-tracker-fhir-app/raw/master/img/2clZMr2z9B.png)

![Patient dashboard page](https://github.com/jrpereirajr/pregnancy-symp-tracker-fhir-app/raw/master/img/jrxjTdnqFT.png)

![Doctor's patient list](https://github.com/jrpereirajr/pregnancy-symp-tracker-fhir-app/raw/master/img/twGUA6mU1C.png)