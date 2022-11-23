window.onload = (event) => {
    console.log("page is fully loaded");

    getSymptoms().then(symptoms => {
        console.log(symptoms);
        drawSymptoms(document.getElementById("divSymptoms"), symptoms);
    });
};

const BASE_URL = "/csp/preg-symp-tracker/api";

const httpGet = (url) => {
    return fetch(url).then(response => response.json());
}

const getSymptoms = () => {
    return httpGet(`${BASE_URL}/symptoms`)
        .then(response => Promise.resolve(
            getCodeArrayFromObservation(response)
        ));
}

const getCodeArrayFromObservation = (observation) => {
    return observation.entry.map(entry => entry.resource.code);
}

const drawSymptoms = (el, symptoms) => {
    el.innerHTML = `
    <table>
        ${symptoms.map(symptom => `<tr><td>${symptom.text}</td></tr>\n`).join('')}
    </table>
    `;
}