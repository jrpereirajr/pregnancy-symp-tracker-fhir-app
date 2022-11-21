Class dc.apps.pregsymptracker.restapi.HTTPClient Extends %RegisteredObject
{

Property Request As %Net.HttpRequest;

Property Server As %String;

Property Port As %String;

Property UseHTTPS As %Boolean;

Property SSLConfig As %String;

Property APIKeyCred As %String;

Method CreateRequest()
{
    Set ..Request = ##class(%Net.HttpRequest).%New()
    Set ..Request.Server = ..Server
    Set ..Request.Port = ..Port
    Set ..Request.Https = ..UseHTTPS
    If (..UseHTTPS) {
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

Method HTTPGet(pPath As %String) As %Net.HttpResponse
{
    Do ..CreateRequest()
    $$$TOE(st, ..Request.Get(pPath))
    Set response = ..Request.HttpResponse
    Return response
}

Method HTTPPost(pPath As %String, pBody As %DynamicObject) As %Net.HttpResponse
{
    Do ..CreateRequest()
    Do ..Request.EntityBody.Clear()
    Do ..Request.EntityBody.Write(pBody.%ToJSON())
    $$$TOE(st, ..Request.Post(pPath))
    Set response = ..Request.HttpResponse
    Return response
}

Method HTTPPut(pPath As %String, pBody As %DynamicObject) As %Net.HttpResponse
{
    Do ..CreateRequest()
    Do ..Request.EntityBody.Clear()
    Do ..Request.EntityBody.Write(pBody.%ToJSON())
    $$$TOE(st, ..Request.Put(pPath))
    Set response = ..Request.HttpResponse
    Return response
}

Method HTTPDelete(pPath As %String) As %Net.HttpResponse
{
    Do ..CreateRequest()
    $$$TOE(st, ..Request.Delete(pPath))
    Set response = ..Request.HttpResponse
    Return response
}

}
