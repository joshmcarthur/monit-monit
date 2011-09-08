google.load('visualization', '1', {packages:['corechart', 'gauge']});
google.setOnLoadCallback(drawCharts);


var drawResourceUtilization = function(chart_div, label, value, is_load) {
    try {
        var resource_data = new google.visualization.DataTable();
        resource_data.addColumn('string', 'Label');
        resource_data.addColumn('number', 'Value');

        resource_data.addRows(1);
        resource_data.setValue(0, 0, label);
        resource_data.setValue(0, 1, value);

        var resource_chart = new google.visualization.Gauge(chart_div);
        var options = {width: 200, height: 200, redFrom: 90, redTo: 100,
                yellowFrom:75, yellowTo: 90, minorTicks: 5};
        if (is_load == true) {
            $.extend(options, {redFrom: 10, redTo: 20, yellowFrom: 5, yellowTo: 10, max: 20});
        }
        resource_chart.draw(resource_data, options);
    }
    catch(err) {

    }
}


var drawDiskPie = function(chart_div, filesystem, used, total) {
    try {
        var disk_data = new google.visualization.DataTable();
        disk_data.addColumn("string", "Description");
        disk_data.addColumn("number", "Percentage");
        disk_data.addRows(2);

        disk_data.setValue(0, 0, "Used");
        disk_data.setValue(0, 1, used);
        disk_data.setValue(1, 0, "Total");
        disk_data.setValue(1, 1, total);

        var disk_chart = new google.visualization.PieChart(chart_div);
        disk_chart.draw(disk_data, {width: 450, height: 300});
    }
    catch(err) {

    }
}

var drawTrendLine = function(chart_div, array_of_values) {
    var trend_data = new google.visualization.DataTable();
    trend_data.addColumn("string", "Index");
    trend_data.addColumn("number", "Value");
    trend_data.addRows(array_of_values.length);
    var row_count = 0;
    $.each(array_of_values, function(index, value) {
        trend_data.setValue(row_count, 0, index.toString());
        trend_data.setValue(row_count, 1, value);
        row_count++;
    });

    var trend_chart = new google.visualization.LineChart(chart_div);
    options = { width: 280, height: 240, legend: 'none', vAxis: { viewWindowMode: "explicit", viewWindow: { max: 100.00, min: 0.00 } }}
    trend_chart.draw(trend_data, options);
}

var drawLoadBar = function(load_value, chart_div) {
    //We need to make some wild stabs in the dark here, and just use some numbers
    var value = 0;
    if (load_value > 0.25 && load_value < 1) {
        value = 15;
    } else if (load_value > 1 && load_value < 5) {
        value = 25;
    } else if (load_value > 5 && load_value < 10) {
        value = 50;
    } else if (load_value > 10 && load_value < 15) {
        value = 75;
    } else if (load_value > 15) {
        value = 100;
    }

    drawResourceBar(value, chart_div);
}

var drawResourceBar = function(resource_value, chart_div) {
    var table = $("<table class='resource'><tr></tr></table>");
    //Make the 'utilized' resource bar
    var value = Math.ceil(resource_value);
    for (var i = 0; i < value; i++) {
        $("<td class='used'></td>").appendTo(table.find('tr'));
    }

    //Fill up the rest
    for (var i = 0; i < (100 - value); i++) {
        $("<td></td>").appendTo(table.find('tr'));
    }
    chart_div.empty();
    table.appendTo(chart_div);
}

var serverDetailCharts = function() {
        var servers = $('section.server.detail');
        servers.each(function(index) {
            var cpu = parseFloat(servers.eq(index).find('input.cpu').val());
            var memory = parseFloat(servers.eq(index).find('input.memory').val());
            var load = parseFloat(servers.eq(index).find('input.load').val());

            drawResourceUtilization($(this).find('#cpu_chart')[0], 'CPU %', cpu, false);
            drawResourceUtilization($(this).find('#memory_chart')[0], 'Memory %', memory, false);
            drawResourceUtilization($(this).find('#load_chart')[0], 'Load', load, true);

            if ($('fieldset.filesystem').length > 0) {
                $('fieldset.filesystem').each(function() {
                    var name = $(this).find('input.name').val();
                    var usage = parseFloat($(this).find('input.usage').val());
                    var total = parseFloat($(this).find('input.total').val());
                    var chart_div = $("#" + name + "_chart")[0];
                    drawDiskPie(chart_div, name, usage, total);
                });
            }

            if ($('section.server div.trends').length > 0) {
                $('section.server div.trends input[type=hidden]').each(function() {
                    var name = $(this).attr('id');
                    var values = $(this).val().split(',');
                    $.each(values, function(index, value) {
                        values[index] = parseInt(value);
                    });
                    var chart_div = $(this).next('div')[0];
                    drawTrendLine(chart_div, values);
                });
            }
        });
}

var serverOverviewCharts = function() {
    var servers = $('section.server.overview');
    servers.each(function(index, item) {
        drawResourceBar(parseFloat($(this).find('h3.cpu').text()), $(this).find('.cpu_chart'));
        drawResourceBar(parseFloat($(this).find('h3.memory').text()), $(this).find('.memory_chart'));
        drawLoadBar(parseFloat($(this).find('h3.load').text()), $(this).find('.load_chart'));
    });
}

function drawCharts() {
    if ($('section.server.detail').length == 1)
    {
        serverDetailCharts();
    }

    if ($('section.server.overview').length > 0)
    {
        serverOverviewCharts();
    }
}

