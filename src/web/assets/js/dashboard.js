
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
            .then((pressure) => prepareBloodPressureChart(pressure))
    }

    const getBodyWeight = () => {
        httpGet(`${BASE_URL}?code=${BODY_WEIGHT}`)
            .then(response => response.json())
            .then((bodyweight) => prepareBodyWeightChart(bodyweight))
    }

    const prepareBloodPressureChart = (data) => {
        const datachart = {}, xaxis = [], series = [];
        data.entry.forEach((e) => {
            xaxis.push(e.resource.effectiveDateTime)
            e.resource.component.forEach(r => {
                if (!datachart[r.code.text]) datachart[r.code.text] = [];
                datachart[r.code.text].push(r.valueQuantity.value) 
            })
        });

        Object.keys(datachart).forEach(key => {
            series.push({name: key, data: datachart[key]})
        })

        drawChart({
            chartId: "#blood-pressure-chart",
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
            series: series, 
            xaxis: xaxis})
    }

    const prepareBodyWeightChart = (data) => {
        const xaxis = [], series = [];
        data.entry.forEach((e) => {
            xaxis.push(e.resource.effectiveDateTime)
            series.push(e.resource.valueQuantity.value) 
        });

        drawChart({
            chartId: "#body-weight-chart",
            chart: {
                height: 350,
                type: 'area',
                zoom: {
                    enabled: false
                }
            },
            series: {name: 'Body Weight', data: series}, 
            xaxis: xaxis})
    }

    const drawChart = (data) => {
        const options = {
        stroke: {
            curve: 'smooth'
            },
            title: {
            text: '',
            align: 'left'
        },
        xaxis: {
            categories: [],
            title: {
                text: 'Date'
            }
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
        legend: {
            position: 'top',
            horizontalAlign: 'right',
            floating: true,
            offsetY: -25,
            offsetX: -5
        }
        };

        options.series = data.series;
        options.chart = data.chart;
        options.xaxis.categories = data.xaxis;
        if (!!!data.dataLabels) options.dataLabels = data.dataLabels
        if (!!!data.colors) options.colors = data.colors

        const chart = new ApexCharts(document.querySelector(data.chartId), options);
        chart.render();

    }

    getBloodPressure();
    getBodyWeight();

    
}());