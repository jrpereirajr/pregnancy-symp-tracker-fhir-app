Class dc.apps.pregsymptracker.data.PatientDoctor Extends %Persistent
{

Property PatientId As %String [ Required ];

Property DoctorId As %String [ Required ];

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
