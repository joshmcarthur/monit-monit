google.load('visualization', '1', {packages:['gauge']});
google.setOnLoadCallback(drawCharts);


var drawResourceUtilization = function(chart_div, label, value) {
    var resource_data = new google.visualization.DataTable();
    resource_data.addColumn('string', 'Label');
    resource_data.addColumn('number', 'Value');

    resource_data.addRows(1);
    resource_data.setValue(0, 0, label);
    resource_data.setValue(0, 1, value);

    var resource_chart = new google.visualization.Gauge(chart_div);
    var options = {width: 200, height: 200, redFrom: 90, redTo: 100,
            yellowFrom:75, yellowTo: 90, minorTicks: 5};
    resource_chart.draw(resource_data, options);
}



function drawCharts() {
    var servers = $('section.server');
    servers.each(function(index) {
        var cpu = parseFloat(servers.eq(index).find('input.cpu').val());
        var memory = parseFloat(servers.eq(index).find('input.memory').val());
        var load = parseFloat(servers.eq(index).find('input.load').val());

        drawResourceUtilization($(this).find('#cpu_chart')[0], 'CPU %', cpu);
        drawResourceUtilization($(this).find('#memory_chart')[0], 'Memory %', memory);
        drawResourceUtilization($(this).find('#load_chart')[0], 'Load', load);
    });
}

