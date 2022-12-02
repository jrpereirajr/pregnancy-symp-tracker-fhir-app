/// Business logic class defined by OpenAPI in dc.apps.pregsymptracker.restapi.spec<br/>
/// Updated Nov 29, 2022 23:57:33
Class dc.apps.pregsymptracker.restapi.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 1;

ClassMethod ConfigTest()
{
    Set ^restapi.FHIRaaSClient = {"config": {
        "Server": "fhir.b36p2oiewusx.workload-prod-fhiraas.isccloud.io",
        "Port": 443,
        "UseHTTPS": 1,
        "SSLConfig": "default",
        "APIKeyCred": "fhirserver-apikey"
    }}.%ToJSON()
}

ClassMethod GetFHIRaaSClient() As dc.apps.pregsymptracker.restapi.FHIRaaSClient
{
    Set config = {}.%FromJSON($GET(^restapi.FHIRaaSClient, "{}")).config
    If ('config) {
        Throw ##class(%Exception.General).%New("No config found in ^restapi.FHIRaaSClient global; check out the method ConfigTest() for details.")
    }
    
    Set fhiraasClient = ##class(dc.apps.pregsymptracker.restapi.FHIRaaSClient).%New()
    Set fhiraasClient.Server = config.Server
    Set fhiraasClient.Port = config.Port
    Set fhiraasClient.UseHTTPS = config.UseHTTPS
    Set fhiraasClient.SSLConfig = config.SSLConfig
    Set fhiraasClient.APIKeyCred = config.APIKeyCred
    Return fhiraasClient
}

ClassMethod CopyHeaders(pFHIRResponse As %Net.HttpResponse)
{
    Set header = ""
    Do {
        Set header = pFHIRResponse.GetNextHeader(header)
        Do:(header '= "") ..%SetHeader(header, pFHIRResponse.Headers(header))
    } While (header '= "")
}

ClassMethod GetObservationPath(pId As %String = "", pPatientId As %String = "") As %String
{
    Set querystring = %request.CgiEnvs("QUERY_STRING")

    // remove invalid Observation parameters
    Set re = ##class(%Regex.Matcher).%New("PatientId=.*?&", querystring)
    Set querystring = re.ReplaceFirst("")
    Set re = ##class(%Regex.Matcher).%New("&PatientId=.*?", querystring)
    Set querystring = re.ReplaceFirst("")

    Set path = "/Observation"
    Set:(pId '= "") path = path_"/"_pId
    Set:(pPatientId = "") pPatientId = ..GetCurrentPatientId()
    Set path = path_"?patient="_pPatientId
    Set:(querystring '= "") path = path_"&"_querystring
    return path
}

ClassMethod FHIRaaSCall(pMethod As %String, pArgs...)
{
    #Dim response As %Net.HttpResponse 
    Set fhiraasClient = ..GetFHIRaaSClient()
    Set response = $METHOD(fhiraasClient, pMethod, pArgs...)
    Do ..%SetStatusCode(response.StatusCode)
    Do ..CopyHeaders(response)
    Return response.Data
}

ClassMethod GetObservationFromBody(body As %DynamicObject) As %DynamicObject
{
    Set observation = {
        "resourceType":"Observation",
        "status":"final",
        "category":[
            {
                "text":"Signs and Symptoms"
            }
        ],
        "code":{},
        "subject":{
            "reference":""
        },
        "effectiveDateTime":""
    }
    Set observation.code = body.code
    Set observation.subject.reference = "Patient/"_..GetCurrentPatientId()
    Set observation.effectiveDateTime = body.effectiveDateTime
    Return observation
}

ClassMethod GetCurrentPatientId() As %String
{
    Set userId = $USERNAME
    Return ##class(dc.apps.pregsymptracker.data.FHIRRelation).GetFHIRResourceId(userId, "Patient")
}

/// OpenAPI definition
ClassMethod GetOpenAPISpec() As %Stream.Object
{
    Set xdataID = "dc.apps.pregsymptracker.restapi.spec||OpenAPI"
    Set compiledXdata = ##class(%Dictionary.CompiledXData).%OpenId(xdataID)
    Set tStream = compiledXdata.Data
    If '$IsObject(tStream) Set tSC=%objlasterror Quit
    Set dynObject = {}.%FromJSON(tStream)
    Return dynObject.%ToJSON()
}

/// Used for patients report their symptoms<br/>
/// The method arguments hold values for:<br/>
///     body, Patient symptom report<br/>
ClassMethod PostSymptom(body As %DynamicObject) As %DynamicObject
{
    Set observation = ..GetObservationFromBody(body)
    Return ..FHIRaaSCall("HTTPPost", ..GetObservationPath(), observation)
}

/// Retrieves specific symptom from the logged patient<br/>
/// The method arguments hold values for:<br/>
///     id<br/>
ClassMethod GetSymptom(id As %Integer) As %DynamicObject
{
    Return ..FHIRaaSCall("HTTPGet", ..GetObservationPath(id))
}

/// Edit a patient symptom<br/>
/// The method arguments hold values for:<br/>
///     id<br/>
///     body, Patient symptom report<br/>
ClassMethod PutSymptom(id As %Integer, body As %DynamicObject) As %DynamicObject
{
    Set observation = ..GetObservationFromBody(body)
    Set observation.id = id
    Return ..FHIRaaSCall("HTTPPut", ..GetObservationPath(id), observation)
}

/// (provide functional description here)<br/>
/// The method arguments hold values for:<br/>
///     id<br/>
ClassMethod DeleteSymptom(id As %Integer) As %Stream.Object
{
    Return ..FHIRaaSCall("HTTPDelete", ..GetObservationPath(id))
}

/// Get the patientes of the current logged doctor
ClassMethod GetDoctorPatientsList() As %Stream.Object
{
    Set doctorId = $USERNAME
    Set patientsIdList = ##class(dc.apps.pregsymptracker.data.PatientDoctor).GetPatientsFromDoctor(doctorId)
    Return ..FHIRaaSCall("HTTPGet", "/Patient?_id="_patientsIdList)
}

/// Get the symptoms of the doctor's patients<br/>
/// The method arguments hold values for:<br/>
///     PatientId<br/>
ClassMethod GetDoctorPatientSymptomsList(PatientId As %Integer) As %Stream.Object
{
    // todo: validate if pPatientId is a current doctor's patient
    Return ..FHIRaaSCall("HTTPGet", ..GetObservationPath("", PatientId))
}

/// Retrieves a list with the Patient symptoms handled by the application
ClassMethod GetSymptomsList() As %Stream.Object
{
    Set symptomsList = ##class(dc.apps.pregsymptracker.data.SymptomsList).GetSymptomList()
    Return symptomsList
}

/// Retrives current patient symptoms
ClassMethod GetSymptoms() As %Stream.Object
{
    Return ..FHIRaaSCall("HTTPGet", ..GetObservationPath())
}

}
