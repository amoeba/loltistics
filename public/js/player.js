$(function(){
  var createEloChart = function(ele) {
    var chart = $(ele).children(".chart")[0]
    
    // Grab the data
    var labels = []
      , data = [];
  
    $(ele).children("table").children("tbody").children("tr").each(function () {
      var cells = $(this).children("td")
        , label = $(cells[0]).html()
        , datum = $(cells[1]).html()
      
      labels.push(label)
      data.push(datum)
    });

    console.log(labels, data);
    
    var width = 200
      , height = 100
      , r = Raphael($(ele).children(".chart")[0], width, height)
      , txt = { font: "10px Sans-serif", fill: "#000" }
      , ymin = 0
      , ymax = 3000
      , topgutter = 0
      , bottomgutter = 0
      , leftgutter = 0
      , colorhue = .6 || Math.random()
      , color = "hsb(" + [colorhue, .5, 1] + ")"
    
    r.rect(leftgutter, topgutter, width - leftgutter, height - topgutter - bottomgutter)
    
    //r.text(leftgutter - 15, topgutter , "3000")
    //r.text(leftgutter - 15, height - bottomgutter - 2, "0")
    
    for(var i = 0, ii = data.length; i < ii; i++) {
      var x = leftgutter + Math.round(((width - leftgutter * 2) / (data.length + 1)) * (i))
        , y = Math.round(topgutter + (height - topgutter) * ( data[i] / ymax))
      
      r.circle(x, y, 5).attr({fill: color, stroke: "#fff"})
      //r.text(x, y - 15, data[i]).attr(txt)
    
    }
  }
  
  //$(".history").each(function() {
  //  createEloChart(this);
  //});
});