window.onload = (event) => {
    windowOnLoad(event);
};

document.getElementById("symptomsSelector").onchange = (evt) => {
    symptomsSelectorOnChange(evt);
};

document.getElementById("btnSave").onclick = (evt) => {
    btnPostSymptomOnClick(evt);
}

document.getElementById("btnClear").onclick = (evt) => {
    clearForm();
}

// document.getElementById("btnGetSymptom").onclick = (evt) => {
//     btnGetSymptomOnClick(evt);
// }

// document.getElementById("btnPutSymptom").onclick = (evt) => {
//     btnPutSymptomOnClick(evt);
// }

// document.getElementById("btnDeleteSymptom").onclick = (evt) => {
//     btnDeleteSymptomOnClick(evt);
// }

// document.getElementById("btnFirst").onclick = (evt) => {
//     btnFirstOnClick(evt);
// }

// document.getElementById("btnPrevious").onclick = (evt) => {
//     btnPreviousOnClick(evt);
// }

// document.getElementById("btnNext").onclick = (evt) => {
//     btnNextOnClick(evt);
// }

// document.getElementById("btnLast").onclick = (evt) => {
//     btnLastOnClick(evt);
// }

const BASE_URL = "/csp/preg-symp-tracker/api";
const PAGE_SIZE = 10;
const relationLinks = {};
// todo: get via API
const SYMPTOMS_OPTIONS = {
    "Vomiting": {
        "coding": [
            {
                "system": "http://loinc.org",
                "code": "45708-5",
                "display": "Vomiting [Minimum Data Set]"
            }
        ],
        "text": "Vomiting"
    },
    "Fever": {
        "coding": [
            {
                "system": "http://snomed.info/sct",
                "code": "386661006",
                "display": "Fever (finding)"
            }
        ],
        "text": "Fever"
    },
    "Generic complaint": {
        "coding": [
            {
                "system": "http://snomed.info/sct",
                "code": "409586006",
                "display": "Complaint (finding)"
            }
        ],
        "text": "Generic complaint"
    }
};

class FHIRSearchParams {
    _count;
    _sort;
    page;
    queryId;

    getSearchExpression() {
        let filter = [];
        if (this._count) {
            filter.push(`_count=${this._count}`);
        }
        if (this._sort) {
            filter.push(`_sort=${this._sort}`);
        }
        if (this.page) {
            filter.push(`page=${this.page}`);
        }
        if (this.queryId) {
            filter.push(`queryId=${this.queryId}`);
        }
        return filter.join("&");
    }
}

const windowOnLoad = (evt) => {
    createSymptomsList();
    updateSymptomsGrid();
    clearForm();
}

const symptomsSelectorOnChange = (evt) => {
    const symptomId = evt.target.value;
    const genericSymptom = document.getElementById("genericSymptom");
    genericSymptom.value = "";
    genericSymptom.style.display = symptomId == "Generic complaint" ? "" : "none";
}

const btnPostSymptomOnClick = (evt) => {
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

const btnGetSymptomOnClick = (evt) => {
    const id = document.getElementById("txtSymptomID").value;
    getSymptom(id)
        .then((response) => {
            showMsg(JSON.stringify(response));
        })
        .catch((error) => defaultErrorhandling(error));
}

const btnPutSymptomOnClick = (evt) => {
    const id = document.getElementById("txtSymptomID").value;
    const symptom = getSymptomOption();
    const effectiveDateTime = getSymptomDateTime();
    putSymptom(id, symptom, effectiveDateTime)
        .then(() => defaultOkHandling())
        .catch((error) => defaultErrorhandling(error));
}

const btnDeleteSymptomOnClick = (evt) => {
    const id = document.getElementById("txtSymptomID").value;
    deleteSymptom(id)
        .then(() => defaultOkHandling())
        .catch((error) => defaultErrorhandling(error));
}

const showMsg = (msg) => {
    // const msgBox = document.getElementById("msgBox");
    // msgBox.innerText = msg;
    alert(msg);
}

const httpGet = (url) => {
    return fetch(url).then(response => {
        if (!response.ok) {
            return Promise.reject(response);
        }
        return response;
    });
}

const httpPost = (url, data) => {
    return fetch(url, {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    }).then(response => {
        if (!response.ok) {
            return Promise.reject(response);
        }
        return response;
    });
}

const httpPut = (url, data) => {
    return fetch(url, {
        method: "PUT",
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    }).then(response => {
        if (!response.ok) {
            return Promise.reject(response);
        }
        return response;
    });
}

const httpDelete = (url) => {
    return fetch(url, {
        method: "DELETE"
    }).then(response => {
        if (!response.ok) {
            return Promise.reject(response);
        }
        return response;
    });
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
            return Promise.resolve(
                getCodeArrayFromObservation(response)
            );
        });
}

const getCodeArrayFromObservation = (observation) => {
    return observation.entry.map(entry => ({
        "id": entry.resource.id,
        "code": entry.resource.code,
        "effectiveDateTime": new Date(entry.resource.effectiveDateTime).toLocaleString()
    }));
}

const postSymptom = (symptom, effectiveDateTime) => {
    return httpPost(`${BASE_URL}/symptom`, {
        "code": symptom,
        "effectiveDateTime": effectiveDateTime || new Date().toISOString()
    });
}

const getSymptom = (id) => {
    return httpGet(`${BASE_URL}/symptom?id=${id}`)
        .then(response => response.json());
}

const putSymptom = (id, symptom, effectiveDateTime) => {
    return httpPut(`${BASE_URL}/symptom?id=${id}`, {
        "id": id,
        "code": symptom,
        "effectiveDateTime": effectiveDateTime || new Date().toISOString()
    });
}

const deleteSymptom = (id) => {
    return httpDelete(`${BASE_URL}/symptom?id=${id}`);
}

const drawLoading = (el, msg) => {
    el.innerHTML = `<span>${msg}</span>`
}

const getSymptomDescription = (code) => code.text || code.coding[0].display;

const drawSymptoms = (el, symptoms) => {
    el.innerHTML = symptoms.map(symptom => `
    <li>
       <div class="timeline-dots border-primary"></div>
       <h6 class="">${getSymptomDescription(symptom.code)}</h6>
       <small class="mt-1">${symptom.effectiveDateTime}</small>
       <div>
          <a href="#void" onclick="editSymptom(${symptom.id})" class="btn iq-bg-primary">Edit</a>
          <a href="#void" onclick="removeSymptom(${symptom.id})" class="btn iq-bg-danger">Delete</a>
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

const createSymptomsList = () => {
    const symptomsList = document.getElementById("symptomsList");
    symptomsList.innerHTML = Object.keys(SYMPTOMS_OPTIONS).map(key =>
        `<option value="${getSymptomDescription(SYMPTOMS_OPTIONS[key])}"></option>`
    );
}

const updateSymptomsGrid = (fhirSearchParams) => {
    const divSymptoms = document.getElementById("patientTimeline");

    const filter = fhirSearchParams ? fhirSearchParams : new FHIRSearchParams();
    filter._count = PAGE_SIZE;
    filter._sort = "-date";
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
    error.text().then(msg => {
        showMsg(msg || `${error.statusText} (${error.status})`);
    });
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
    if (symptomId == "Generic complaint") {
        const genericSymptom = document.getElementById("genericSymptom");
        symptom.text = genericSymptom.value || symptom.text;
    }
    return symptom;
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

    const dateSymptom = document.getElementById("dateSymptom");
    dateSymptom.value = new Date().toISOString().split("T")[0];

    const timeSymptom = document.getElementById("timeSymptom");
    timeSymptom.value = new Date().toLocaleTimeString().split(":").slice(0,2).join(":");

    window.editingId = "";
}