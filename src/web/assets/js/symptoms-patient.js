window.onload = (event) => {
    windowOnLoad(event);
};

document.getElementById("symptomsSelector").onchange = (evt) => {
    symptomsSelectorOnChange(evt);
};

document.getElementById("btnSave").onclick = (evt) => {
    btnSaveSymptomOnClick(evt);
}

document.getElementById("btnClear").onclick = (evt) => {
    clearForm();
}

const BASE_URL = "/csp/preg-symp-tracker/api";
const PAGE_SIZE = 10;
const relationLinks = {};
let SYMPTOMS_OPTIONS = {};
const GENERIC_SYMPTOM = "Generic complaint";
const BODY_WEIGHT = "Body weight";
const BODY_HEIGTH = "Body height";
const genericSymptomsList = [
    GENERIC_SYMPTOM,
    BODY_WEIGHT,
    BODY_HEIGTH
];

const windowOnLoad = (evt) => {
    loadSymptomsList()
    .then(() => createSymptomsList());
    updateSymptomsGrid();
    clearForm();
}

const symptomsSelectorOnChange = (evt) => {
    const symptomId = evt.target.value;
    const genericSymptom = document.getElementById("genericSymptom");
    genericSymptom.value = "";
    genericSymptom.style.display = genericSymptomsList.indexOf(symptomId) > -1 ? "" : "none";
}

const btnSaveSymptomOnClick = (evt) => {
    const symptom = getSymptomOption();
    const effectiveDateTime = getSymptomDateTime();
    if (!window.editingId) {
        postSymptom(symptom, effectiveDateTime)
            .then(() => {
                clearForm();
                defaultOkHandling();
            })
            .catch((error) => defaultErrorhandling(error));
    } else {
        putSymptom(window.editingId, symptom, effectiveDateTime)
            .then(() => {
                clearForm();
                defaultOkHandling();
            })
            .catch((error) => defaultErrorhandling(error));
    }
}

const showMsg = (msg) => {
    // const msgBox = document.getElementById("msgBox");
    // msgBox.innerText = msg;
    alert(msg);
}

const getRelationURL = (response, pRelationType) => {
    const link = response.link.filter(link => link.relation === pRelationType)
    return link.length > 0 ? link[0].url : "";
}

const getFHIRSearchParamsFromResponse = (response, pRelationType) => {
    const fhirSearchParams = new FHIRSearchParams();

    const url = getRelationURL(response, pRelationType);
    const qs = url.split("?")[1];

    if (!qs) return fhirSearchParams;

    const params = qs.split("&");
    params.forEach(param => {
        param = param.split("=");
        const paramKey = param[0];
        const paramValue = param[1];
        fhirSearchParams[paramKey] = paramValue;
    });

    return fhirSearchParams;
}

const getRelationsFHIRSearchParams = (response) => {
    relationLinks.first = getFHIRSearchParamsFromResponse(response, "first");
    relationLinks.previous = getFHIRSearchParamsFromResponse(response, "previous");
    relationLinks.next = getFHIRSearchParamsFromResponse(response, "next");
    relationLinks.last = getFHIRSearchParamsFromResponse(response, "last");
    console.log(relationLinks);
}

const getSymptoms = (fhirSearchParams) => {
    const filter = fhirSearchParams ? `?${fhirSearchParams.getSearchExpression()}` : "";
    return httpGet(`${BASE_URL}/symptoms${filter}`)
        .then(response => response.json())
        .then(response => {
            getRelationsFHIRSearchParams(response);
            return response.entry;
        });
}

const postSymptom = (symptom, effectiveDateTime) => {
    const payload = Object.assign({
        "code": symptom,
        "effectiveDateTime": effectiveDateTime || new Date().toISOString()
    }, getSymptomValue());
    return httpPost(`${BASE_URL}/symptom`, payload);
}

const getSymptom = (id) => {
    return httpGet(`${BASE_URL}/symptom?id=${id}`)
        .then(response => response.json());
}

const putSymptom = (id, symptom, effectiveDateTime) => {
    const payload = Object.assign({
        "id": id,
        "code": symptom,
        "effectiveDateTime": effectiveDateTime || new Date().toISOString()
    }, getSymptomValue());
    return httpPut(`${BASE_URL}/symptom?id=${id}`, payload);
}

const deleteSymptom = (id) => {
    return httpDelete(`${BASE_URL}/symptom?id=${id}`);
}

const drawLoading = (el, msg) => {
    el.innerHTML = `<span>${msg}</span>`
}

const getSymptomCodeDescription = (code) => code.text || code.coding[0].display;

const getSymptomDescription = (symptom) => {
    let complement = "";
    if (symptom.resource.valueString) {
        complement = `(${symptom.resource.valueString})`
    }
    if (symptom.resource.valueQuantity) {
        const valueQuantity = symptom.resource.valueQuantity;
        complement = `(${valueQuantity.value} ${valueQuantity.unit})`
    }
    const desc = `${symptom.resource.code.text || symptom.resource.code.coding[0].display} ${complement}`;
    return desc;
}

const drawSymptoms = (el, symptoms) => {
    el.innerHTML = symptoms.map(symptom => `
    <li>
       <div class="timeline-dots border-primary"></div>
       <h6 class="">${getSymptomDescription(symptom)}</h6>
       <small class="mt-1">${symptom.resource.effectiveDateTime}</small>
       <div>
          <a href="#void" onclick="editSymptom(${symptom.resource.id})" class="btn iq-bg-primary">Edit</a>
          <a href="#void" onclick="removeSymptom(${symptom.resource.id})" class="btn iq-bg-danger">Delete</a>
       </div>
    </li>
    </table>
    `).join('');
    // drawNavLabel();
}

const editSymptom = (id) => {
    getSymptom(id).then(response => {
        console.log(response)

        const symptomsSelector = document.getElementById("symptomsSelector");
        symptomsSelector.value = response.code.text;

        const event = new Event('change');
        symptomsSelector.dispatchEvent(event);
        setSymptomValue(response);

        const dateSymptom = document.getElementById("dateSymptom");
        dateSymptom.value = response.effectiveDateTime.split("T")[0];

        const timeSymptom = document.getElementById("timeSymptom");
        timeSymptom.value = response.effectiveDateTime.split("T")[1].split("Z")[0];

        window.editingId = id;
    })
};

const removeSymptom = (id) => {
    deleteSymptom(id)
        .then(() => {
            clearForm();
            defaultOkHandling();
        })
        .catch((error) => defaultErrorhandling(error));
};

const loadSymptomsList = () => {
    return httpGet(`${BASE_URL}/symptoms-list`)
    .then(response => response.json())
    .then(response => {
        SYMPTOMS_OPTIONS = response;
    });
}

const createSymptomsList = () => {
    const symptomsList = document.getElementById("symptomsList");
    symptomsList.innerHTML = Object.keys(SYMPTOMS_OPTIONS).map(key =>
        `<option value="${getSymptomCodeDescription(SYMPTOMS_OPTIONS[key])}"></option>`
    );
}

const updateSymptomsGrid = (fhirSearchParams) => {
    const divSymptoms = document.getElementById("patientTimeline");

    const filter = fhirSearchParams ? fhirSearchParams : new FHIRSearchParams();
    filter._count = PAGE_SIZE;
    filter._sort = "-_id";
    getSymptoms(filter).then(symptoms => {
        console.log(symptoms);
        drawSymptoms(divSymptoms, symptoms);
    }).catch((error) => defaultErrorhandling(error));

    // drawLoading(divSymptoms, "Loading patient symptoms...");
}

const defaultOkHandling = () => {
    showMsg("Ok!");
    updateSymptomsGrid();
}

const defaultErrorhandling = (error) => {
    // error.text().then(msg => {
    //     showMsg(msg || `${error.statusText} (${error.status})`);
    // });
    console.error(error)
}

const getSymptomOption = () => {
    const symptomId = document.getElementById("symptomsSelector").value;
    if (!symptomId) {
        throw new Error("Select a symptom")
    }
    const symptom = SYMPTOMS_OPTIONS[symptomId];
    if (!symptom) {
        throw new Error(`Symptom unknow: ${symptomId}`)
    }
    return symptom;
}

const setSymptomValue = (observation) => {
    const symptomId = document.getElementById("symptomsSelector").value;
    const genericSymptom = document.getElementById("genericSymptom");
    if (symptomId == GENERIC_SYMPTOM) {
        genericSymptom.value = observation.valueString;
    } else if (symptomId == BODY_WEIGHT) {
        genericSymptom.value = observation.valueQuantity.value;
    } else if (symptomId == BODY_HEIGTH) {
        genericSymptom.value = observation.valueQuantity.value;
    }
}

const getSymptomValue = () => {
    const symptomId = document.getElementById("symptomsSelector").value;
    const genericSymptom = document.getElementById("genericSymptom");
    if (symptomId == GENERIC_SYMPTOM) {
        return {
            "valueString": genericSymptom.value
        };
    } else if (symptomId == BODY_WEIGHT) {
        return {
            "valueQuantity": {
                "value": parseFloat(genericSymptom.value),
                "unit": "kg",
                "system": "http://unitsofmeasure.org",
                "code": "kg"
            }
        };
    } else if (symptomId == BODY_HEIGTH) {
        return {
            "valueQuantity": {
                "value": parseFloat(genericSymptom.value),
                "unit": "m",
                "system": "http://unitsofmeasure.org",
                "code": "m"
            }
        };
    }
    return;
}

const getSymptomDateTime = () => {
    let dateSymptom = document.getElementById("dateSymptom").value;
    let timeSymptom = document.getElementById("timeSymptom").value;
    dateSymptom = dateSymptom || new Date().toISOString().substring(0, 10)
    timeSymptom = timeSymptom  || new Date().toISOString().substring(11, 19)
    if (timeSymptom.split(":").length < 3) {
        timeSymptom = `${timeSymptom}:00`;
    }
    return `${dateSymptom}T${timeSymptom}Z`;
}

const btnFirstOnClick = (evt) => {
    updateSymptomsGrid(relationLinks.first);
}

const btnPreviousOnClick = (evt) => {
    updateSymptomsGrid(relationLinks.previous);
}

const btnNextOnClick = (evt) => {
    updateSymptomsGrid(relationLinks.next);
}

const btnLastOnClick = (evt) => {
    updateSymptomsGrid(relationLinks.last);
}

const drawNavLabel = () => {
    const navLabel = document.getElementById("navLabel");
    const currentPage = relationLinks.next.page ? 
        parseInt(relationLinks.next.page) - 1 : parseInt(relationLinks.last.page)
    navLabel.innerText = `Page ${currentPage}/${relationLinks.last.page}`;
}

const clearForm = () => {
    const symptomsSelector = document.getElementById("symptomsSelector");
    symptomsSelector.value = "";
    
    const genericSymptom = document.getElementById("genericSymptom");
    genericSymptom.value = "";

    const dateSymptom = document.getElementById("dateSymptom");
    dateSymptom.value = new Date().toISOString().split("T")[0];

    const timeSymptom = document.getElementById("timeSymptom");
    timeSymptom.value = new Date().toLocaleTimeString().split(":").slice(0,2).join(":");

    window.editingId = "";
}