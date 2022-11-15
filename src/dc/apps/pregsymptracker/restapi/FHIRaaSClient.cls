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
    Set o.UseHttps = 1
    Set o.SSLConfig = "default"
    Set o.APIKeyCred = "fhiraas-apikey"

    Set response = o.HttpGet("/Patient/1")
    zw response
}

}
