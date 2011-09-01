$(document).ready(function() {
    formatUptime(false);
    $('header.topbar .twipsy.goto_overview').hide();
    $('header.topbar h3').mouseenter(function() {
        $('header.topbar .twipsy.goto_overview').show();
    });
    $('header.topbar h3').mouseout(function() {
        $('header.topbar .twipsy.goto_overview').hide();
    });
});


var formatUptime = function(use_effects) {
    var options = {
        div_hours: "h ",
        div_minutes: "m ",
        div_seconds: "s ",
    }

    $('input.uptime').each(function() {
        $(this).showTime($.extend(options, { load_into: $(this).prev() }));
    });
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
                server.find('input.uptime').val(value.uptime);
                drawCharts();
                formatUptime(true);
            }
        });
    });
    doCountdown(true);
}

