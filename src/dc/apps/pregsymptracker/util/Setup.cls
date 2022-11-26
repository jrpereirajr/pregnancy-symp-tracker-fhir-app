Class dc.apps.pregsymptracker.util.Setup
{

ClassMethod Main()
{
    Do ..CreateResources()
    Do ..CreateRoles()
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
        $$$TOE(st, $CLASSMETHOD("Security.Resources", "Create", "AppSymptoms", "Patient symptoms", "RU", ""))
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
        $$$TOE(st, $CLASSMETHOD("Security.Roles", "Create", "AppPatient", "Application Patient role", "AppSymptoms:RU", ""))
        $$$TOE(st, $CLASSMETHOD("Security.Roles", "Create", "AppDoctor", "Application Doctor role", "AppSymptoms:RU", ""))
    } Catch(e) {
        ZN ns
        Throw e
    }
    ZN ns
}

}
