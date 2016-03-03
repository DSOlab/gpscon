var margin = {top: 20, right: 80, bottom: 30, left: 50},
    width  = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S");

var x = d3.time.scale().range([0, width]);

var y = d3.scale.linear().range([height, 0]);

var xAxis = d3.svg.axis().scale(x).orient("bottom");

var yAxis = d3.svg.axis().scale(y).orient("left");

var line = d3.svg.line()
    .x(function(d) { return x(dateFormat.parse(d.epoch)); })
    .y(function(d) { return y(d.size); });

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    
d3.json("akyr.json", function(error, data) {
    if (error) throw error;
    
    var index = 0;
    for (var i=0; i<data.length; i++) {
        // console.log(data[i].info.official_name);
        index = i;
        break;
    }
    var obj = data[index];
    // console.log(obj.data);

    var epoch_array = [],
        sizes_array = [];

    for (var pt = 0; pt < obj.data.length; pt++) {
        epoch = ( dateFormat.parse(obj.data[pt].epoch) );
        val   = obj.data[pt]["size"];
        epoch_array.push(epoch);
        sizes_array.push(val);
    }
    
    x.domain(d3.extent(epoch_array));
    y.domain(d3.extent(sizes_array));
    
    svg.append("g")
       .attr("class", "x axis")
       .attr("transform", "translate(0," + height + ")")
       .call(xAxis);

    svg.append("g")
       .attr("class", "y axis")
       .call(yAxis)
       .append("text")
       .attr("transform", "rotate(-90)")
       .attr("y", 6)
       .attr("dy", ".71em")
       .style("text-anchor", "end")
       .text("File Size (Kb)");
    
    svg.append("path")
      .datum(obj.data)
      .attr("class", "line")
      .attr("d", line);

});
