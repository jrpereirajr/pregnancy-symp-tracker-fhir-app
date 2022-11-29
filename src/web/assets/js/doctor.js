window.onload = (event) => {
    windowOnLoad(event);
};

const BASE_URL = "/csp/preg-symp-tracker/api";
const PAGE_SIZE = 5;

const windowOnLoad = (evt) => {
    getPatientsList().then(response => drawPatientList(response));
}

const getPatientsList = () => 
    httpGet(`${BASE_URL}/doctor/patients`)
    .then(resp => resp.json());

const getPatientSymptoms = (patientId) => {
    const filter = new FHIRSearchParams();
    filter._count = PAGE_SIZE;
    filter._sort = "-date";
    return httpGet(`${BASE_URL}/doctor/patient/symptoms?PatientId=${patientId}&${filter.getSearchExpression()}`)
    .then(resp => resp.json());
}

const drawPatientList = (patients) => {
    const promises = patients.entry.map(patient => {
        return getPatientSymptoms(patient.resource.id)
            .then(resp => {
                return `
                <tr>
                   <td class="text-center">
                        <img class="rounded-circle img-fluid avatar-40" src="images/user/02.jpg" alt="profile">
                    </td>
                   <td>${patient.resource.name[0].given[0]}</td>
                   <td>${resp.entry.map(symptom => symptom.resource.code.text).join(", ")}</td>
                </tr>
                `;
            });
    });
    Promise.all(promises).then((rows) => {
        const patientList = document.getElementById("patientList");
        patientList.innerHTML = `
        <table class="table mb-0 table-borderless">
            <thead>
            <tr>
               <th scope="col" class="col-lg-1">Patient</th>
               <th scope="col" class="col-lg-2">Name</th>
               <th scope="col">Last ${PAGE_SIZE} symptoms</th>
            </tr>
            </thead>
            <tbody>
                ${rows.join("")}
            </tbody>
        </table>
        `
    })
}