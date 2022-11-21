Class tests.unittest.dc.apps.pregsymptracker.restapi.TestHTTPClient Extends %UnitTest.TestCase
{

Method TestCreateRequest()
{
	Set tExpected = $CLASSNAME(##class(%Net.HttpRequest).%New())
    Set Server = "my.cool.server"
    Set Port = "1234"
    Set UseHTTPS = 0
    Set SSLConfiguration = ""

    Set o = ##class(dc.apps.pregsymptracker.restapi.HTTPClient).%New()
    Set o.Server = Server
    Set o.Port = Port
    Set o.UseHTTPS = UseHTTPS
    Do o.CreateRequest()
    
    Set tResults = $CLASSNAME(o.Request)
	Do $$$AssertEquals(tResults, tExpected, tExpected_" = "_tResults)
	Do $$$AssertEquals(o.Request.Server, Server)
	Do $$$AssertEquals(o.Request.Port, Port)
	Do $$$AssertEquals(o.Request.Https, UseHTTPS)
	Do $$$AssertEquals(o.Request.SSLConfiguration, SSLConfiguration)
}

}
