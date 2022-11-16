/// Business logic class defined by OpenAPI in dc.apps.pregsymptracker.restapi.spec<br/>
/// Updated Nov 16, 2022 18:59:16
Class dc.apps.pregsymptracker.restapi.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

/// Test endpoint!
ClassMethod test() As %Stream.Object
{
    //(Place business logic here)
    Do ..%SetStatusCode(200)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Return $ZDT($Now(), 3)
}

/// Used for patients to report their symptoms<br/>
/// The method arguments hold values for:<br/>
///     body, Patient symptom report<br/>
ClassMethod ReportSymptom(body As %DynamicObject) As %DynamicObject
{
    //(Place business logic here)
    //Do ..%SetStatusCode(<HTTP_status_code>)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Set returnObject = body
    Return returnObject
}

/// OpenAPI definition
ClassMethod GetOpenAPISpec() As %Stream.Object
{
    Do ..%SetStatusCode(200)
    Set xdataID = "dc.apps.pregsymptracker.restapi.spec||OpenAPI"
    Set compiledXdata = ##class(%Dictionary.CompiledXData).%OpenId(xdataID)
    Set tStream = compiledXdata.Data
    If '$IsObject(tStream) Set tSC=%objlasterror Quit
    Set dynObject = {}.%FromJSON(tStream)
    Return dynObject.%ToJSON()
}

}
