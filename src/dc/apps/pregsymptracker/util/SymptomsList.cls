Class dc.apps.pregsymptracker.util.SymptomsList Extends %RegisteredObject
{

ClassMethod Main()
{
    Write !, "Creating symptoms list..."

    $$$TOE(st, ##class(dc.apps.pregsymptracker.data.SymptomsList).%KillExtent())
    #Dim classDef As %Dictionary.ClassDefinition = ##class(%Dictionary.ClassDefinition).%OpenId(..%ClassName(1))
    Set lenMethods = classDef.Methods.Count()
    For iMethod = 1:1:lenMethods {
        #Dim method As %Dictionary.MethodDefinition = classDef.Methods.GetAt(iMethod)
        If ($MATCH(method.Name, "^Symptom.*")) {
            Do $CLASSMETHOD(..%ClassName(1), method.Name)
        }
    }
}

ClassMethod CreateSymptom(pKey As %String, pJSONDef As %String)
{
    Set symptom = ##class(dc.apps.pregsymptracker.data.SymptomsList).%New()
    Set symptom.Key = pKey
    Set symptom.JSONDef = pJSONDef
    $$$TOE(st, symptom.%Save())
}

ClassMethod SymptomVomiting()
{
    Do ..CreateSymptom(
        "Vomiting", {
            "coding": [
                {
                    "system": "http://loinc.org",
                    "code": "45708-5",
                    "display": "Vomiting [Minimum Data Set]"
                }
            ],
            "text": "Vomiting"
        }.%ToJSON()
    )
}

ClassMethod SymptomFever()
{
    Do ..CreateSymptom(
        "Fever", {
            "coding": [
                {
                    "system": "http://snomed.info/sct",
                    "code": "386661006",
                    "display": "Fever (finding)"
                }
            ],
            "text": "Fever"
        }.%ToJSON()
    )
}

ClassMethod SymptomGeneric()
{
    Do ..CreateSymptom(
        "Generic complaint", {
            "coding": [
                {
                    "system": "http://snomed.info/sct",
                    "code": "409586006",
                    "display": "Complaint (finding)"
                }
            ],
            "text": "Generic complaint"
        }.%ToJSON()
    )
}

ClassMethod SymptomBodyWeight()
{
    Do ..CreateSymptom(
        "Body weight", {
            "coding": [
                {
                    "system": "http://loinc.org",
                    "code": "29463-7",
                    "display": "Body Weight"
                },
                {
                    "system": "http://snomed.info/sct",
                    "code": "27113001",
                    "display": "Body weight"
                }
            ],
            "text": "Body weight"
        }.%ToJSON()
    )
}

ClassMethod SymptomBodyHeight()
{
    Do ..CreateSymptom(
        "Body height", {
            "coding": [
                {
                    "system": "http://loinc.org",
                    "code": "8302-2",
                    "display": "Body height"
                }
            ],
            "text": "Body height"
        }.%ToJSON()
    )
}

}
