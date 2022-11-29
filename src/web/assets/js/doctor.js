window.onload = (event) => {
    windowOnLoad(event);
};

const BASE_URL = "/csp/preg-symp-tracker/api";

const windowOnLoad = (evt) => {
    getPatientsList().then(response => drawPatientList(response));
}

const getPatientsList = () => 
    httpGet(`${BASE_URL}/doctor/patients`)
    .then(resp => resp.json());

const drawPatientList = (patients) => {
    const patientList = document.getElementById("patientList");
    const rows = patients.entry.map(patient => {
        return `
        <tr>
           <td class="text-center">
                <img class="rounded-circle img-fluid avatar-40" src="images/user/02.jpg" alt="profile">
            </td>
           <td>${patient.resource.name[0].given[0]}</td>
           <td>Cataract surgery</td>
        </tr>
        `;
    }).join("");

    patientList.innerHTML = `
    <table class="table mb-0 table-borderless">
        <thead>
        <tr>
           <th scope="col" class="col-lg-1">Patient</th>
           <th scope="col" class="col-lg-2">Name</th>
           <th scope="col">Symptoms</th>
        </tr>
        </thead>
        <tbody>
            ${rows}
        </tbody>
    </table>
    `
}