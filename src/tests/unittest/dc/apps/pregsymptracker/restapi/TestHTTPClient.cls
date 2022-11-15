Class tests.unittest.dc.apps.pregsymptracker.restapi.TestHTTPClient Extends %UnitTest.TestCase
{

Method TestCreateRequest()
{
    // todo: this is just a dummy test... needs implementation
    Set o = ##class(dc.apps.pregsymptracker.restapi.HTTPClient).%New()
	Set tExpected = $CLASSNAME(##class(%Net.HttpRequest).%New())
    Do o.CreateRequest()
    Set tResults = $CLASSNAME(o.Request)
	Do $$$AssertEquals(tResults, tExpected, tExpected_" = "_tResults)
}

}
