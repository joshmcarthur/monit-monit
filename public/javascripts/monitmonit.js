$(document).ready(function() {
    $('section.server .uptime').each(function() {
        $(this).showTime({
            div_hours: "h ",
            div_minutes: "m ",
            div_seconds: "s "
        });
    });
});


var secondsToHuman = function(seconds_int) {
    var seconds = seconds_int;
    seconds_int /= 60;
    var minutes = seconds_int % 60;
    seconds_int /= 60;
    var hours = seconds_int % 24;
    seconds_int /= 24;
    var days = seconds_int;

    var human = ""
    if (days > 0) { human += (days + " days "); }
    if (hours > 0) { human += (hours + " hours "); }
    if (minutes > 0) { human += (minutes + " minutes "); }
    if (seconds > 0) { human += (seconds + " seconds"); }
    return human;
}

var doCountdown = function() {
    alert('Hit countdown');
    $('.countdown').countdown({until: '60S', layout: '&#8635;&nbsp;&nbsp;Refreshing in {sn} seconds.', onExpiry: refreshOverview});
}

var refreshOverview = function() {
    $.getJSON('/overview.json', function(data) {
        $.each(data, function(key, value) {
            var server = $("section#" + value.id);
            if(server.length > 0) {
                server.find('input.cpu').val(value.cpu);
                server.find('input.memory').val(value.memory);
                server.find('input.load').val(value.load);
                server.find('h2.uptime').val(value.uptime);
                drawCharts();
            }
        });
    });
    alert("Done refresh")
    doCountdown();
}

