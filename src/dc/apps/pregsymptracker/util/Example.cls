Class dc.apps.pregsymptracker.util.Example
{

ClassMethod Main()
{
    Do ..CreateUsers()
    Do ..CreateFHIRRelations()
    Do ..CreatePatientDoctorRelations()
}

ClassMethod CreateUsers()
{
    Do ##class(dc.apps.pregsymptracker.util.Setup).Log("Creating example users...")

    // a patient
    &SQL(drop user MarySmith)
    &SQL(create user MarySmith identified by 'marysmith')
    &SQL(grant %DB_IRISAPP, %DB_IRISAPPSECONDARY, AppPatient to MarySmith)
    &SQL(grant select on schema dc_apps_pregsymptracker_data to MarySmith)

    // another patient
    &SQL(drop user SuzieMartinez)
    &SQL(create user SuzieMartinez identified by 'suziemartinez')
    &SQL(grant %DB_IRISAPP, %DB_IRISAPPSECONDARY, AppPatient to SuzieMartinez)
    &SQL(grant select on schema dc_apps_pregsymptracker_data to SuzieMartinez)

    // a doctor
    &SQL(drop user PeterMorgan)
    &SQL(create user PeterMorgan identified by 'petermorgan')
    &SQL(grant %DB_IRISAPP, %DB_IRISAPPSECONDARY, AppDoctor to PeterMorgan)
    &SQL(grant select on schema dc_apps_pregsymptracker_data to PeterMorgan)

    // a doctor who is also a partient
    &SQL(drop user AnneJackson)
    &SQL(create user AnneJackson identified by 'annejackson')
    &SQL(grant %DB_IRISAPP, %DB_IRISAPPSECONDARY, AppDoctor, AppPatient to AnneJackson)
    &SQL(grant select on schema dc_apps_pregsymptracker_data to AnneJackson)
}

ClassMethod CreateFHIRRelations()
{
    Do ##class(dc.apps.pregsymptracker.util.Setup).Log("Creating example users relations to existing FHIR resources...")

    &SQL(truncate table dc_apps_pregsymptracker_data.FHIRRelation)

    Set relations = ""
    Set relations($I(relations)) = $LB("MarySmith", "Patient/1")
    Set relations($I(relations)) = $LB("SuzieMartinez", "Patient/972")
    Set relations($I(relations)) = $LB("AnneJackson", "Practitioner/3")
    Set relations($I(relations)) = $LB("AnneJackson", "Patient/1223")
    Set relations($I(relations)) = $LB("PeterMorgan", "Practitioner/13")

    Set key = $O(relations(""))
    While (key '= "") {
        Set userId = $LG(relations(key), 1)
        Set fhirInfo = $LG(relations(key), 2)
        Set fhirResourceId = $PIECE(fhirInfo, "/", 2)
        Set fhirResourceType = $PIECE(fhirInfo, "/", 1)
        
        Set o = ##class(dc.apps.pregsymptracker.data.FHIRRelation).%New()
        Set o.UserId = userId
        Set o.FHIRResourceId = fhirResourceId
        Set o.FHIRResourceType = fhirResourceType
        $$$TOE(st, o.%Save())

        Set key = $O(relations(key))
    }
}

ClassMethod CreatePatientDoctorRelations()
{
    Do ##class(dc.apps.pregsymptracker.util.Setup).Log("Creating example patients and doctors relation...")

    &SQL(truncate table dc_apps_pregsymptracker_data.PatientDoctor)

    Set relations = ""
    Set relations($I(relations)) = $LB("MarySmith", "AnneJackson")
    Set relations($I(relations)) = $LB("SuzieMartinez", "PeterMorgan")
    Set relations($I(relations)) = $LB("AnneJackson", "PeterMorgan")

    Set key = $O(relations(""))
    While (key '= "") {
        Set patientId = $LG(relations(key), 1)
        Set doctorId = $LG(relations(key), 2)
        
        Set o = ##class(dc.apps.pregsymptracker.data.PatientDoctor).%New()
        Set o.PatientId = patientId
        Set o.DoctorId = doctorId
        $$$TOE(st, o.%Save())

        Set key = $O(relations(key))
    }
}

}
