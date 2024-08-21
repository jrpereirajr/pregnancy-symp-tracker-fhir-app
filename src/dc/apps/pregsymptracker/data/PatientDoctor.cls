Class dc.apps.pregsymptracker.data.PatientDoctor Extends %Persistent
{

Property PatientId As %String [ Required ];

Property DoctorId As %String [ Required ];

ClassMethod GetPatientsFromDoctor(pDoctorId As %String) As %String
{
    Set sql = 
        "select list(r.FHIRResourceId) as list "_
        "from dc_apps_pregsymptracker_data.PatientDoctor pd "_
        "inner join dc_apps_pregsymptracker_data.FHIRRelation r "_
            "on r.UserId = pd.PatientId and r.FHIRResourceType = 'Patient' "_
        "where pd.DoctorId = ?"
    Set params = ""
    Set params($I(params)) = pDoctorId
    #Dim rs As %SQL.StatementResult = ##class(%SQL.Statement).%ExecDirect(, sql, params...)
    Do rs.%Next()
    Return rs.%Get("list")
}

Storage Default
{
<Data name="PatientDoctorDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientId</Value>
</Value>
<Value name="3">
<Value>DoctorId</Value>
</Value>
</Data>
<DataLocation>^dc.apps.pregC548.PatientDoctorD</DataLocation>
<DefaultData>PatientDoctorDefaultData</DefaultData>
<IdLocation>^dc.apps.pregC548.PatientDoctorD</IdLocation>
<IndexLocation>^dc.apps.pregC548.PatientDoctorI</IndexLocation>
<StreamLocation>^dc.apps.pregC548.PatientDoctorS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
