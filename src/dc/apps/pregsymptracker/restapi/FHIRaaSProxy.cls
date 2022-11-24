Class dc.apps.pregsymptracker.restapi.FHIRaaSProxy Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean
{
    Set st = $$$OK
    Try {
        Do ..FowardToFHIRaaS()
    } Catch(e) {
        Set ^myerror($ZDT($H, 3)) = e.AsStatus()
        Set st = e.AsStatus()
    }
	Quit st
}

ClassMethod OnPage() As %Status
{
    Write ..GetResponse()
    Do ..SetResponse("")
    Return $$$OK
}

ClassMethod FowardToFHIRaaS()
{
    #Dim %request As %CSP.Request
    #Dim %response As %CSP.Response
    #Dim fhirResponse As %Net.HttpResponse
    
    Set fhiraasClient = ..GetFHIRaaSClient()

    Set path = %request.CgiEnvs("PATH_INFO")
    Set httpMethod = $ZCVT(%request.Method, "U")
    If (httpMethod = "GET") {
        Set fhirResponse = fhiraasClient.HTTPGet(path)
    } ElseIf (httpMethod = "POST") {
        Set body = ..GetBody()
        Set fhirResponse = fhiraasClient.HTTPPost(path, body)
    } ElseIf (httpMethod = "PUT") {
        Set body = ..GetBody()
        Set fhirResponse = fhiraasClient.HTTPPut(path, body)
    } ElseIf (httpMethod = "DELETE") {
        Set fhirResponse = fhiraasClient.HTTPDelete(path)
    } Else {
        Throw ##class(%Exception.General).%New("HTTP verb not implemented: "_httpMethod)
    }

    Do ..CopyHeaders(fhirResponse)
    Do ..CopyResponse(fhirResponse)
}

ClassMethod SetResponse(pResponseData As %String)
{
    Set ^restapi.FHIRaaSProxy(%session.SessionId) = pResponseData
}

ClassMethod GetResponse() As %String
{
    Return $G(^restapi.FHIRaaSProxy(%session.SessionId))
}

ClassMethod GetFHIRaaSClient() As dc.apps.pregsymptracker.restapi.FHIRaaSClient
{
    Set fhiraasClient = ##class(dc.apps.pregsymptracker.restapi.FHIRaaSClient).%New()
    Set fhiraasClient.Server = "fhir.fkwlwiygbul2.static-test-account.isccloud.io"
    Set fhiraasClient.Port = 443
    Set fhiraasClient.UseHTTPS = 1
    Set fhiraasClient.SSLConfig = "default"
    Set fhiraasClient.APIKeyCred = "fhiraas-apikey"
    Return fhiraasClient
}

ClassMethod CopyHeaders(pFHIRResponse As %Net.HttpResponse)
{
    Set header = ""
    Do {
        Set header = pFHIRResponse.GetNextHeader(header)
        Do:(header '= "") %response.SetHeader(header, pFHIRResponse.Headers(header))
    } While (header '= "")
}

ClassMethod CopyResponse(pFHIRResponse As %Net.HttpResponse)
{
    While ('pFHIRResponse.Data.AtEnd) {
        Set tmp = pFHIRResponse.Data.Read(1024, .st)
        $$$TOE(st, st)
        Do ..SetResponse(..GetResponse()_tmp)
    }
}

ClassMethod GetBody() As %DynamicObject
{
    Set body = ""
    While ('%request.Content.AtEnd) {
        Set body = body_%request.Content.Read(1024, .st)
        $$$TOE(st, st)
    }
    Set body = {}.%FromJSON(body)
    Return body
}

}
