Class dc.apps.pregsymptracker.restapi.BMIFHIRHandler Extends %RegisteredObject
{

Method ProcessFHIRMessage(pFHIRMessage As %DynamicObject) As %DynamicObject
{
    Try {
        Set bmi = ""
        Set symptomKey = pFHIRMessage.code.text
        Set bodyWeightSymptom = ##class(dc.apps.pregsymptracker.util.SymptomsList).SymptomBodyWeight()
        Set bodyHeightSymptom = ##class(dc.apps.pregsymptracker.util.SymptomsList).SymptomBodyHeight()

        Set bodyWeightResource = ""
        Set bodyHeightResource = ""
        Set effectiveDateTime = ""
        
        If (symptomKey = bodyWeightSymptom.key) {
            Set bodyHeightResource = ..GetMostRecentObservation(bodyHeightSymptom.def.coding.%Get(0).code)
            If (pFHIRMessage.id = "") {
                Set bodyWeightResource = ..GetMostRecentObservation(pFHIRMessage.code.coding.%Get(0).code)
            } Else {
                Set bodyWeightResource = ..GetObservation(pFHIRMessage.id)
            }
            Set effectiveDateTime = bodyWeightResource.entry.%Get(0).resource.effectiveDateTime

        } ElseIf (symptomKey = bodyHeightSymptom.key) {
            Set bodyWeightResource = ..GetMostRecentObservation(bodyWeightSymptom.def.coding.%Get(0).code)
            If (pFHIRMessage.id = "") {
                Set bodyHeightResource = ..GetMostRecentObservation(pFHIRMessage.code.coding.%Get(0).code)
            } Else {
                Set bodyHeightResource = ..GetObservation(pFHIRMessage.id)
            }
            Set effectiveDateTime = bodyHeightResource.entry.%Get(0).resource.effectiveDateTime
        }

        If ($ISOBJECT(bodyWeightResource)) && ($ISOBJECT(bodyHeightResource)) {
            Do ..PostBMI(bodyWeightResource, bodyHeightResource, effectiveDateTime)
        }
    } Catch(e) {
        Set ^myerror($ZDT($H, 3)) = e.AsStatus()
    }
    Return pFHIRMessage
}

Method GetFHIRResource(pPath As %String) As %DynamicObject
{
    #Dim response As %Net.HttpResponse
    #Dim fhiraasClient As dc.apps.pregsymptracker.restapi.FHIRaaSClient = ##class(dc.apps.pregsymptracker.restapi.impl).GetFHIRaaSClient()

    Set responseData = {}
    Set patientId = ##class(dc.apps.pregsymptracker.restapi.impl).GetCurrentPatientId()
    Set response = fhiraasClient.HTTPGet(pPath)
    Return ..ProcessResponse(response)
}

Method ProcessResponse(pResponse As %Net.HttpResponse)
{
    Set responseStatus = pResponse.StatusCode
    Set responseData = ""
    If (responseStatus [ "2") {
        Do {
            Set responseData = responseData_pResponse.Data.Read(10000)
        } While ('pResponse.Data.AtEnd)
        Set responseData = {}.%FromJSON(responseData)
    } Else {
        Throw ##class(%Exception.General).%New("Unexpected HTTP status code: "_responseStatus)
    }

    Return responseData
}

Method GetMostRecentObservation(pCode As %String) As %DynamicObject
{
    Set patientId = ##class(dc.apps.pregsymptracker.restapi.impl).GetCurrentPatientId()
    Set path = "Observation?patient=%1&code=%2&_count=1&_sort=-_id"
    Set path = $$$FormatText(path, patientId, pCode)
    Return ..GetFHIRResource(path)
}

Method GetObservation(pId As %String) As %DynamicObject
{
    Set patientId = ##class(dc.apps.pregsymptracker.restapi.impl).GetCurrentPatientId()
    Set path = "Observation?_id=%1&patient=%2"
    Set path = $$$FormatText(path, pId, patientId)
    Return ..GetFHIRResource(path)
}

Method PostBMI(pWeight As %DynamicObject, pHeight As %DynamicObject, pEffectiveDateTime As %String)
{
    Set patientId = ##class(dc.apps.pregsymptracker.restapi.impl).GetCurrentPatientId()
    Set weightValue = pWeight.entry.%Get(0).resource.valueQuantity.value
    Set heightValue = pHeight.entry.%Get(0).resource.valueQuantity.value
    Set bmi = weightValue / (heightValue**2)
    Set observation = {
        "resourceType":"Observation",
        "status":"final",
        "category":[
            {
                "coding": [
                    {
                    "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                    "code": "vital-signs",
                    "display": "Vital Signs"
                    }
                ],
                "text": "Vital Signs"
            }
        ],
        "code":{
            "coding": [
                {
                    "system": "http://loinc.org",
                    "code": "39156-5",
                    "display": "Body mass index (BMI) [Ratio]"
                }
            ],
            "text": "BMI"
        },
        "subject":{
            "reference":("Patient/"_patientId)
        },
        "effectiveDateTime":(pEffectiveDateTime),
        "valueQuantity":{
            "value": (+$FNUMBER(bmi,,2)),
            "unit": "kg/m2",
            "system": "http://unitsofmeasure.org",
            "code": "kg/m2"
        },
        "derivedFrom": [
            {
                "reference": ("Observation/"_pWeight.entry.%Get(0).resource.id),
                "display": "Body Height"
            },
            {
                "reference": ("Observation/"_pHeight.entry.%Get(0).resource.id),
                "display": "Body Weight"
            }
        ]
    }
    #Dim response As %Net.HttpResponse 
    #Dim fhiraasClient As dc.apps.pregsymptracker.restapi.FHIRaaSClient = ##class(dc.apps.pregsymptracker.restapi.impl).GetFHIRaaSClient()
    Set response = fhiraasClient.HTTPPost("/Observation", observation)
    Return ..ProcessResponse(response)
}

}
