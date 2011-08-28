$(document).ready(function() {
    formatUptime(false);
});


var formatUptime = function(use_effects) {
    var options = {
        div_hours: "h ",
        div_minutes: "m ",
        div_seconds: "s "
    }
    
    if (use_effects) {
        $('h2.uptime').fadeOut(function() {  
            $(this).showTime(options);
            $(this).fadeIn();
        });
    }
    else {
        $('h2.uptime').showTime(options);
    }
}

var doCountdown = function(already_run) {
    if (already_run) {
        $('.countdown').countdown('change', {until: '60S'});
    }
    else {
        setTimeout(function() {
            $("<div class='alert-message warning countdown'>Countdown initializing...</div>").hide().insertAfter('div#welcome').slideDown();
            $('.countdown').countdown({until: '60S', layout: '&#8635;&nbsp;&nbsp;Refreshing in {sn} seconds.', onExpiry: refreshOverview});
        }, 5000);
    }
}

var refreshOverview = function() {
    $.getJSON('/overview.json', function(data) {
        $.each(data, function(key, value) {
            var server = $("section#" + value.id);
            if(server.length > 0) {
                server.find('input.cpu').val(value.cpu);
                server.find('input.memory').val(value.memory);
                server.find('input.load').val(value.load);
                server.find('h2.uptime').text(value.uptime);
                drawCharts();
                formatUptime(true);
            }
        });
    });
    doCountdown(true);
}

