Class dc.apps.pregsymptracker.util.Setup
{

ClassMethod Main()
{
    Do ..CreateResources()
    Do ..CreateRoles()
    Do ##class(dc.apps.pregsymptracker.util.SymptomsList).Main()
}

ClassMethod Log(pMsg As %String)
{
    Write !, pMsg
}

ClassMethod CreateResources()
{
    Do ..Log("Creating application resources...")
    Set ns = $NAMESPACE
    Try {
        ZN "%SYS"
        Do $CLASSMETHOD("Security.Resources", "Delete", "AppSymptoms")
        Do $CLASSMETHOD("Security.Resources", "Delete", "AppAccessDoctorPatients")
        $$$TOE(st, $CLASSMETHOD("Security.Resources", "Create", "AppSymptoms", "Patient symptoms", "", ""))
        $$$TOE(st, $CLASSMETHOD("Security.Resources", "Create", "AppAccessDoctorPatients", "Patients access rights", "", ""))
    } Catch(e) {
        ZN ns
        Throw e
    }
    ZN ns
}

ClassMethod CreateRoles()
{
    Do ..Log("Creating application roles...")
    Set ns = $NAMESPACE
    Try {
        ZN "%SYS"
        Do $CLASSMETHOD("Security.Roles", "Delete", "AppPatient")
        Do $CLASSMETHOD("Security.Roles", "Delete", "AppDoctor")
        $$$TOE(st, $CLASSMETHOD("Security.Roles", "Create", "AppPatient", "Application Patient role", "AppSymptoms:RWU", ""))
        $$$TOE(st, $CLASSMETHOD("Security.Roles", "Create", "AppDoctor", "Application Doctor role", "AppAccessDoctorPatients:RWU", ""))
    } Catch(e) {
        ZN ns
        Throw e
    }
    ZN ns
}

}
