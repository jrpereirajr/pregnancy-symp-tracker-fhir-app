Class dc.apps.pregsymptracker.data.SymptomsList Extends %Persistent
{

Property Key As %String [ Required ];

Property JSONDef As %String(MAXLEN = "") [ Required ];

Index idxKey On Key [ Unique ];

ClassMethod GetSymptomList()
{
    // todo: pagination
    Set sql = 
    "select '{'||list(symptom)||'}' as list from ("_
        "select top all symptom from ("_
            "select top all '""'||Key||'"":'||JSONDef as symptom "_
            "from dc_apps_pregsymptracker_data.SymptomsList "_
            "order by Key"_
        ") where %vid > 0"_
    ")"
    Set params = ""
    #Dim rs As %SQL.StatementResult = ##class(%SQL.Statement).%ExecDirect(, sql, params...)
    Set list = {}
    If (rs.%Next()) {
        Set list = {}.%FromJSON(rs.%Get("list"))
    }
    Return list
}

Storage Default
{
<Data name="SymptomsListDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Key</Value>
</Value>
<Value name="3">
<Value>JSONDef</Value>
</Value>
</Data>
<DataLocation>^dc.apps.pregsC548.SymptomsListD</DataLocation>
<DefaultData>SymptomsListDefaultData</DefaultData>
<IdLocation>^dc.apps.pregsC548.SymptomsListD</IdLocation>
<IndexLocation>^dc.apps.pregsC548.SymptomsListI</IndexLocation>
<StreamLocation>^dc.apps.pregsC548.SymptomsListS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
