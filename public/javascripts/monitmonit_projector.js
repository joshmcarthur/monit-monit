$(document).ready(function() {
  drawCharts();
});

var drawCharts = function() {
  var servers = $('section.server');
  servers.each(function(index) {
    var cpu = parseFloat(servers.eq(index).find('input.cpu').val());
    var memory = parseFloat(servers.eq(index).find('input.memory').val());
    var load = parseFloat(servers.eq(index).find('input.load').val());
    drawCpuTable($(this), cpu);
    drawMemoryTable($(this), memory);
    drawLoadTable($(this), load);
  });
}

var drawCpuTable = function(elem, val, max) {
  if (max == null) { max = 100; }
  chart = elem.find('#cpu_chart')
  table = $("<table id='cpu_chart' class='cpu chart'><tr></tr></table>");
  row = table.find("tr");
  val = Math.round(val);
  for(var i = 0; i < max; i++) {
    if (i < val) { row.append("<td class='tick'></td>"); }
    else { row.append("<td></td>"); }
  }
  chart.replaceWith(table);
}

var drawMemoryTable = function(elem, val, max) {
  if (max == null) { max = 100; }
  chart = elem.find('#memory_chart')
  table = $("<table id='memory_chart' class='memory chart'><tr></tr></table>");
  row = table.find("tr");
  val = Math.round(val);
  for(var i = 0; i < max; i++) {
    if (i < val) { row.append("<td class='tick'></td>"); }
    else { row.append("<td></td>"); }
  }
  chart.replaceWith(table);
}

var drawLoadTable = function(elem, val, max) {
  if (max == null) { max = 100; }
  chart = elem.find('#load_chart')
  table = $("<table id='load_chart' class='load chart'><tr></tr></table>");
  row = table.find("tr");
  val = Math.round(val);
  for(var i = 0; i < max; i++) {
    if (i < val) { row.append("<td class='tick'></td>"); }
    else { row.append("<td></td>"); }
  }
  chart.replaceWith(table);
}
