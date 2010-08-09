$(function(){
  var createEloChart = function(ele) {
    // Data
    var data = [];

    $(ele).find("tbody > tr").each(function() {
      var cells = $(this).children("td");
      var label = parseInt($(cells[0]).html());
      var datum = parseInt($(cells[1]).html());
      
      data.push([label, datum]);
    });
    
    if(data.length == 0) { return; }
    
    
      
    function showTooltip(x, y, contents) {
      $("#tooltip").css({top: y, left: x}).html(contents).show();
    }
    
    var previousIndex = null;
    $($(ele).children(".chart")[0]).bind("plothover", function (event, pos, item) { 
      if (item) {
        if (previousIndex != item.dataIndex) {
          previousIndex = item.dataIndex;
          $("#tooltip").hide()
          showTooltip(item.pageX, item.pageY, 
            item.datapoint[1].toString() + ' ELO @ ' + new Date(item.datapoint[0]).toUTCString())
        }
      } else {
        $("#tooltip").hide();
        previousIndex = null;            
      }
    });
    

    
    // Chart
    var options = {
        series: { 
          points: { show: true },
          lines: { show: true}
        },
        grid: {
          hoverable: true
        },
        xaxis: { 
          mode: "time",
          timeformat: "%m/%d",
          minTickSize: [1, "day"]
        }
    };

    var plot = $.plot($(ele).children(".chart")[0], [data], options) 
  }
  
  // Tooltip
    $('<div id="tooltip"></div>').css({
        position: 'absolute',
        display: 'none',
        top: 0,
        left: 0,
        border: '1px solid #fdd',
        padding: '2px',
        'font-size': '12px',
        'background-color': '#fee',
        opacity: 0.80
      }).appendTo('body');
  $(".history").each(function() {
    createEloChart(this);
  });
});