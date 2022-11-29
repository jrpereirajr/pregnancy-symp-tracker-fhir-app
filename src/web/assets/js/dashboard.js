const Dashboard = (function(){
    'use strict';
    const BASE_URL = "/csp/preg-symp-tracker/api/symptoms";

    const BODY_WEIGHT = '29463-7';
    const BLOODPRESSURE = '85354-9';
    const PAGE_SIZE = 10;

    const httpGet = (url) => {
        return fetch(url).then(response => {
            if (!response.ok) {
                return Promise.reject(response);
            }
            return response;
        });
    }

    const getBloodPressure = () => {
        httpGet(`${BASE_URL}?code=${BLOODPRESSURE}`)
            .then(response => response.json())
            .then((pressure) => drawChart(pressure))
    }

    const drawChart = (data) => {
        const options = {
        series: [],
        chart: {
            height: 350,
            type: 'line',
            dropShadow: {
                enabled: true,
                color: '#000',
                top: 18,
                left: 7,
                blur: 10,
                opacity: 0.2
            },
            toolbar: {
                show: false
            }
            },
            colors: ['#77B6EA', '#545454'],
            dataLabels: {
            enabled: true,
        },
        stroke: {
            curve: 'smooth'
            },
            title: {
            text: '',
            align: 'left'
        },
        grid: {
            borderColor: '#e7e7e7',
            row: {
                colors: ['#f3f3f3', 'transparent'], 
                opacity: 0.5
            },
        },
        markers: {
            size: 1
            },
        xaxis: {
            categories: [],
            title: {
                text: 'Date'
            }
        },
            
        legend: {
            position: 'top',
            horizontalAlign: 'right',
            floating: true,
            offsetY: -25,
            offsetX: -5
        }
        };

        const datachart = {}, xaxis = [];
        data.entry.forEach((e) => {
            xaxis.push(e.resource.effectiveDateTime)
            e.resource.component.forEach(r => {
                if (!datachart[r.code.text]) datachart[r.code.text] = [];
                datachart[r.code.text].push(r.valueQuantity.value) 
            })
        });
        console.log(Date.parse(datachart));
        Object.keys(datachart).forEach(key => {
            options.series.push({name: key, data: datachart[key]})
        })

        options.xaxis.categories = xaxis;
        console.log(options);

        const chart = new ApexCharts(document.querySelector("#blood-pressure-chart"), options);
        chart.render();

    }

    getBloodPressure();
    
}());