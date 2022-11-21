Class dc.apps.pregsymptracker.restapi.FHIRaaSClient Extends dc.apps.pregsymptracker.restapi.HTTPClient
{

Method CreateRequest()
{
    Do ##super()
    Do ..SetHeaders({
        "x-api-key" : (..GetApiKeyFromEnsCredentials())
    })
}

ClassMethod Test()
{
    Set o = ..%New()
    Set o.Server = "fhir.fkwlwiygbul2.static-test-account.isccloud.io"
    Set o.Port = 443
    Set o.UseHTTPS = 1
    Set o.SSLConfig = "default"
    Set o.APIKeyCred = "fhiraas-apikey"

    #; Set response = o.HTTPGet("/Patient/1")
    #; Do response.OutputToDevice()

    Set body = {"resourceType":"Observation","id":"vomiting","text":{"status":"generated","div":"<div xmlns=\"http://www.w3.org/1999/xhtml\"><p><b>Generated Narrative: Observation</b><a name=\"vomiting\"> </a></p><div style=\"display: inline-block; background-color: #d9e0e7; padding: 6px; margin: 4px; border: 1px solid #8da1b4; border-radius: 5px; line-height: 60%\"><p style=\"margin-bottom: 0px\">Resource Observation &quot;vomiting&quot; </p></div><p><b>status</b>: final</p><p><b>category</b>: Signs and Symptoms <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> ()</span></p><p><b>code</b>: Vomiting [Minimum Data Set] <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"https://loinc.org/\">LOINC</a>#45708-5; <a href=\"https://browser.ihtsdotools.org/\">SNOMED CT</a>#249497008 &quot;Vomiting symptom (finding)&quot;)</span></p><p><b>subject</b>: <a href=\"broken-link.html\">Patient/infant</a></p><p><b>effective</b>: 2016-05-18T22:33:22Z</p><p><b>value</b>: Absent (qualifier value) <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"https://browser.ihtsdotools.org/\">SNOMED CT</a>#2667000)</span></p></div>"},"status":"final","category":[{"text":"Signs and Symptoms"}],"code":{"coding":[{"system":"http://loinc.org","code":"45708-5","display":"Vomiting [Minimum Data Set]"},{"system":"http://snomed.info/sct","code":"249497008","display":"Vomiting symptom (finding)"}]},"subject":{"reference":"Patient/infant"},"effectiveDateTime":"2016-05-18T22:33:22Z","valueCodeableConcept":{"coding":[{"system":"http://snomed.info/sct","code":"2667000","display":"Absent (qualifier value)"}]}}
    Set response = o.HTTPPost("/Observation", {})
    Do response.OutputToDevice()
    #; zw response
    #; read x

    #; Set obsId = $PIECE(response.Headers("LOCATION"), "/", 5)
    #; zw obsId
    #; read x

    #; Set response = o.HTTPGet("/Observation/"_obsId)
    #; zw response
    #; read x

    #; Set body = {"resourceType":"Observation","id":(obsId),"status":"final","category":[{"text":"Signs and Symptoms"}],"code":{"coding":[{"system":"http://loinc.org","code":"45708-5","display":"Vomiting [Minimum Data Set]"}]},"subject":{"reference":"Patient/infant"}}
    #; Set response = o.HTTPPut("/Observation/"_obsId, body)
    #; zw response
    #; read x

    #; Set response = o.HTTPGet("/Observation/"_obsId)
    #; zw response
    #; read x

    #; Set response = o.HTTPDelete("/Observation/"_obsId)
    #; zw response
    #; read x

    #; Set response = o.HTTPGet("/Observation/"_obsId)
    #; zw response
}

}
