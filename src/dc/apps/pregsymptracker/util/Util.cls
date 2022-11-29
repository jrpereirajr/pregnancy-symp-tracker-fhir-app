Class dc.apps.pregsymptracker.util.Util
{

ClassMethod AssertRole(pRole As %String)
{
    If ('$Find($ROLES, pRole)){
        //Throw ##class(%Exception.General).%New("Insufficient privileges to access this page.")
        #; Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERR(940))
        Set %response.Redirect = "NoPrivilegesPage.csp"
    }
}

}
