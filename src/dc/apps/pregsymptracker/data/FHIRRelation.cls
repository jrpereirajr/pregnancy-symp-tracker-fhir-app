Class dc.apps.pregsymptracker.data.FHIRRelation Extends %Persistent
{

Property UserId As %String [ Required ];

Property FHIRResourceId As %String [ Required ];

Property FHIRResourceType As %String [ Required ];

ClassMethod GetFHIRResourceId(pUserId As %String, pFHIRResourceType As %String) As %String
{
    Set fhirResourceId = ""
    &SQL(
    select FHIRResourceId into :fhirResourceId 
    from dc_apps_pregsymptracker_data.FHIRRelation 
    where UserId = :pUserId and FHIRResourceType = :pFHIRResourceType
    )
    If SQLCODE < 0 {
        Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE, %msg)
    }
    If SQLCODE = 100 {
        Throw ##class(%Exception.General).%New($$$FormatText("No FHIR resource %1 related to user %2", pFHIRResourceType, pUserId))
    }
    Return fhirResourceId
}

Storage Default
{
<Data name="FHIRRelationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>UserId</Value>
</Value>
<Value name="3">
<Value>FHIRResourceId</Value>
</Value>
<Value name="4">
<Value>FHIRResourceType</Value>
</Value>
</Data>
<DataLocation>^dc.apps.pregsC548.FHIRRelationD</DataLocation>
<DefaultData>FHIRRelationDefaultData</DefaultData>
<IdLocation>^dc.apps.pregsC548.FHIRRelationD</IdLocation>
<IndexLocation>^dc.apps.pregsC548.FHIRRelationI</IndexLocation>
<StreamLocation>^dc.apps.pregsC548.FHIRRelationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
