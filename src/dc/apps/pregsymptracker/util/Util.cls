Class dc.apps.pregsymptracker.util.Util
{

ClassMethod ChangePassword(pUserId As %String, pNewPassword As %String)
{
  Set ns = $NAMESPACE
  ZN "%SYS"
  Try {
    Set pUserId = $ZCONVERT(pUserId, "L")
    Set o = ##class(Security.Users).%OpenId(pUserId)
    Set o.PasswordExternal = pNewPassword
    $$$TOE(st, o.%Save())
    Write "Password changed for user: "_pUserId,!
  } Catch(e) {
    Write e.DisplayString()
  }
  ZN ns
}

ClassMethod DisabledUser(pUserId As %String)
{
  Set ns = $NAMESPACE
  ZN "%SYS"
  Try {
    Set pUserId = $ZCONVERT(pUserId, "L")
    Set o = ##class(Security.Users).%OpenId(pUserId)
    Set o.Enabled = 0
    $$$TOE(st, o.%Save())
    Write "User disabled: "_pUserId,!
  } Catch(e) {
    Write e.DisplayString()
  }
  ZN ns
}

ClassMethod AssertRole(pRole As %String)
{
    If ('$Find($ROLES, pRole)){
        //Throw ##class(%Exception.General).%New("Insufficient privileges to access this page.")
        #; Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERR(940))
        Set %response.Redirect = "NoPrivilegesPage.csp"
    }
}

}
