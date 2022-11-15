Class dc.apps.pregsymptracker.restapi.HTTPClient Extends %RegisteredObject
{

Property Request As %Net.HttpRequest;

Property Server As %String;

Property Port As %String;

Property UseHttps As %Boolean;

Property SSLConfig As %String;

Property APIKeyCred As %String;

Method CreateRequest()
{
    Set ..Request = ##class(%Net.HttpRequest).%New()
    Set ..Request.Server = ..Server
    Set ..Request.Port = ..Port
    Set ..Request.Https = ..UseHttps
    If (..UseHttps) {
        Do ..Request.SSLConfigurationSet(..SSLConfig)
    }
}

Method SetHeaders(headers As %DynamicObject)
{
    Set headersIt = headers.%GetIterator()
    While (headersIt.%GetNext(.headerName, .headerValue)) {
        Do ..Request.SetHeader(headerName, headerValue)
    }
}

Method GetApiKeyFromEnsCredentials() As %String
{
    Set apiKeyCred = ..APIKeyCred
    $$$TOE(st, ##class(Ens.Config.Credentials).GetCredentialsObj(.apiKeyCredObj, "", "Ens.Config.Credentials", apiKeyCred))
    Return apiKeyCredObj.Password
}

Method HttpGet(path As %String) As %Net.HttpResponse
{
    Do ..CreateRequest()
    $$$TOE(st, ..Request.Get(path))
    Set response = ..Request.HttpResponse
    Return response
}

}
