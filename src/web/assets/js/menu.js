const createMenu = () => {
    const menuContainer = document.getElementById("iq-sidebar-toggle");
    const menu = [
        /// Patient
        {
            type: "menu-title",
            cssClass: "ri-subtract-line",
            label: "Patient"
        },{
            type: "menu-item",
            href: "patient.csp",
            cssClass: "ri-group-fill",
            label: "My symptoms"
        },{
            type: "menu-item",
            href: "dashboardpatient.csp",
            cssClass: "ri-group-fill",
            label: "My dashboard"
        },
        /// Doctor
        {
            type: "menu-title",
            cssClass: "ri-subtract-line",
            label: "Doctor"
        },{
            type: "menu-item",
            href: "doctor.csp",
            cssClass: "ri-hospital-fill",
            label: "Doctor Dashboard"
        }
    ];
    menuContainer.innerHTML = menu.map(item => {
        if (item.type === "menu-title") {
            return `
            <li class="iq-menu-title"><i class="${item.cssClass}"></i><span>${item.label}</span></li>
            `
        } else if (item.type === "menu-item") {
            return `
            <li>
            <a href="${item.href}" class="iq-waves-effect"><i class="${item.cssClass}"></i><span>${item.label}</span></a>
            </li>
            `
        }
    }).join("");
}

createMenu();