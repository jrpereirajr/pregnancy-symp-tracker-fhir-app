/// Business logic class defined by OpenAPI in dc.apps.pregsymptracker.restapi.spec<br/>
/// Created Nov 15, 2022 15:39:15
Class dc.apps.pregsymptracker.restapi.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

/// Test endpoint!
ClassMethod test() As %Stream.Object
{
    //(Place business logic here)
    Do ..%SetStatusCode(200)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Return $ZDT($Now(), 3)
}

/// Used for patients to report their symptoms<br/>
/// The method arguments hold values for:<br/>
///     body, Patient symptom report<br/>
ClassMethod ReportSymptom(body As %DynamicObject) As %DynamicObject
{
    //(Place business logic here)
    //Do ..%SetStatusCode(<HTTP_status_code>)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Set returnObject = body
    Return returnObject
}

/// OpenAPI definition
ClassMethod GetOpenAPISpec() As %Stream.Object
{
    //(Place business logic here)
    Do ..%SetStatusCode(200)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Return {
        "swagger": "2.0",
        "info": {
            "title": "Pregnacy symptoms tracker",
            "version": "1.0"
        },
        "host": "",
        "basePath": "/preg-symp-tracker",
        "schemes": [
            "http",
            "https"
        ],
        "paths": {
            "/test": {
                "get": {
                    "description": "Test endpoint!",
                    "operationId": "test",
                    "parameters": [],
                    "responses": {
                        "200": {
                            "description": "OK"
                        }
                    }
                }
            },
            "/symptom": {
                "post": {
                    "operationId": "ReportSymptom",
                    "security": [{
                        "basicAuth": []
                    }],
                    "description": "Used for patients to report their symptoms",
                    "consumes": [
                        "application/json"
                    ],
                    "produces": [
                        "application/json"
                    ],
                    "parameters": [
                        {
                            "in": "body",
                            "name": "body",
                            "description": "Patient symptom report",
                            "required": true,
                            "schema": {
                                "$ref": "#/definitions/Symptom"
                            }
                        }
                    ],
                    "responses": {
                        "200": {
                            "description": "OK"
                        }
                    }
                }
            },
            "/_spec": {
                "get": {
                    "operationId": "GetOpenAPISpec",
                    "description": "OpenAPI definition",
                    "parameters": [],
                    "responses": {
                        "200": {
                            "description": "OK"
                        }
                    }
                }
            }
        },
        "definitions": {
            "Symptom": {
                "type": "object",
                "properties": {
                    "patientReport": {
                        "type": "string"
                    }
                }
            }
        },
        "securityDefinitions": {
            "basicAuth": {
                "type": "basic"
            }
        }
    }
}

}
