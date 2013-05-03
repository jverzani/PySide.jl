using PySide
require(Pkg.dir("PySide", "examples", "DThree.jl"))

## This is an attempt to integrate D3 graphics with julia via QtWebView.
## The performance is *surpringly* poor due to really slow passing of JavaScript
## from julia to QtWebView via its evaluateJavaScript method. Oh well. Using the
## webstack being developed by the hacker school is the right place for this type
## of work anyways, as it is more general and does not rely on Qt, Python, PySide
## installations

using DThree
using JSON

## Two examples

## Follow example on bar charts: http://mbostock.github.io/d3/tutorial/bar-1.html
w = Widget()


style = "
.chart div {
  font: 10px sans-serif;
  background-color: steelblue;
  text-align: right;
  padding: 3px;
  margin: 1px;
  color: white;
}
"

d3 = D3(w.w, style)

push!(w, d3.web)
raise(w)

data = [4, 8, 15, 16, 23, 42]
d3.eval_js("var data = $(to_json(data));")
d3.select("body").append("div").attr("class", "chart").render("chart")
## initial part of demo
#d3.receiver("chart").selectAll("div").data(I("data")).enter().append("div").style("width", I("function(d) { return d * 10 + \"px\"; }")).text(I("function(d) { return d; }")).render()
## using a scale instead
d3.scale_linear().domain([0, max(data)]).range(["0px", "420px"]).render("x")
d3.receiver("chart").selectAll("div").data(I("data")).enter().append("div").style("width",I("x")).text(I("String")).render()


## A scatterplot example following http://ofps.oreilly.com/titles/9781449339739/
## not quite right, but not worth fixing up

style = "
.axis path,
.axis line {
    fill: none;
    stroke: black;
    shape-rendering: crispEdges;
}

.axis text {
    font-family: sans-serif;
    font-size: 11px;
}
"

    
    ## Make scatter plot
    x = linspace(0, 2*pi, 250)
    y = cos(x)
    dataset = "[" * join(["[$x,$y]" for (x,y) in zip(x,y)], ", ") * "]"

        
        width, height = 600, 400
        padding = 30

    d3.select("body").append("svg").attr("width", width).attr("height", height).render("svg")
    ## scales
    d3.scale_linear().domain([min(x),max(x)]*1.1).range([0, width]).render("xScale")
    d3.scale_linear().domain([min(y),max(y)]*1.1).range([height, 0]).render("yScale")
    ## axes
    d3.svg_axis().scale(I"xScale").orient("bottom").render("xAxis")
    d3.receiver("svg").append("g").attr("class", "axis").attr("transform", "translate(0,$(height - padding))").call(I"xAxis").render()
    d3.svg_axis().scale(I"yScale").orient("left").ticks(5).render("yAxis")
    d3.receiver("svg").append("g").attr("class", "axis").attr("transform", "translate($padding, 0)").call(I"yAxis").render()

        ## add points. This takes seconds for even 250 points....
                                                                        
    d3.receiver("svg").selectAll("circle").data(I(dataset)).enter().append("circle").
       attr("cx", I("function(d) {return xScale(d[0])}")).
       attr("cy", I("function(d) {return yScale(d[1])}")).
       attr("r", 5).render()
