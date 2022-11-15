Class dc.apps.pregsymptracker.restapi.spec Extends %REST.Spec [ ProcedureBlock ]
{

XData OpenAPI [ MimeType = application/json ]
{
{
  "swagger":"2.0",
  "info":{
    "title":"Pregnacy symptoms tracker",
    "version":"1.0"
  },
  "basePath":"/preg-symp-tracker",
  "schemes":[
    "http",
    "https"
  ],
  "paths":{
    "/test":{
      "get":{
        "description":"Test endpoint!",
        "operationId":"test",
        "parameters":[
        ],
        "responses":{
          "200":{
            "description":"OK"
          }
        }
      }
    },
    "/symptom":{
      "post":{
        "operationId":"ReportSymptom",
        "security":[
          {
            "basicAuth":[
            ]
          }
        ],
        "description":"Used for patients to report their symptoms",
        "consumes":[
          "application/json"
        ],
        "produces":[
          "application/json"
        ],
        "parameters":[
          {
            "in":"body",
            "name":"body",
            "description":"Patient symptom report",
            "required":true,
            "schema":{
              "$ref":"#/definitions/Symptom"
            }
          }
        ],
        "responses":{
          "200":{
            "description":"OK"
          }
        }
      }
    },
    "/_spec":{
      "get":{
        "operationId":"GetOpenAPISpec",
        "description":"OpenAPI definition",
        "parameters":[
        ],
        "responses":{
          "200":{
            "description":"OK"
          }
        }
      }
    }
  },
  "definitions":{
    "Symptom":{
      "type":"object",
      "properties":{
        "patientReport":{
          "type":"string"
        }
      }
    }
  },
  "securityDefinitions":{
    "basicAuth":{
      "type":"basic"
    }
  }
}
}

}
