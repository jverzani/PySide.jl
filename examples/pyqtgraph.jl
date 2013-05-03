## Using basic pyqtgraph installed as follows:
## download source from http://www.pyqtgraph.org/
## installed globally with sudo python setup.py install

# Basic interface for a `plot` command

using PyCall
@pyimport pyqtgraph as pg
@pyimport numpy as np
using PySide

module PyQtGraph
using PyCall
type PyQtDevice 
    graph
end
end

function new_device(title::String)
    win = pg.GraphicsWindow(title=title)
    win[:resize](1000,600)
    win[:setWindowTitle](title)
    p1 = win[:addPlot](title=title)
    PyQtGraph.PyQtDevice(p1)
end


function plot(f::Function, a::Real, b::Real, device::PyQtGraph.PyQtDevice; pen=pg.mkPen(nothing), brush=pg.mkBrush(255, 255,255,120))
    x = linspace(float(a), b, 25000)
    y = [f(x) for x in x]

    dev = device.graph
    
    curve = dev[:plot](pen=pen, brush=brush)
    grid(device)
    data = [float(x) float(y)]
    curve[:setData](data)
end


plot(x::Vector, device::PyQtGraph.PyQtDevice; pen=pg.mkPen(nothing), brush=pg.mkBrush(255, 255,255,120), size=10) =
    plot([1:length(x)], x, device, pen=pen, brush=brush, size=size)
function plot(x::Vector, y::Vector, device::PyQtGraph.PyQtDevice; pen=pg.mkPen(nothing), brush=pg.mkBrush(255, 255,255,120), size=10)

    sp = pg[:ScatterPlotItem](size=size, pen=pen, brush=brush)
    
    spots = [{"pos" => [x, y], "data" => 1} for (x,y) in zip(x,y)]
    sp[:addPoints](spots)
    device.graph[:addItem](sp)

    device.graph[:enableAutoRange](pg.ViewBox()[:XYAxes], true)
end
  

clear(device::PyQtGraph.PyQtDevice) = device.graph[:clear]()
grid(device::PyQtGraph.PyQtDevice) = device.graph[:showGrid](x=true, y=true)

## test it
device = new_device("Title")
plot(sin, 0, 2pi, device, pen=(255,0,0))
plot(cos, 0, 2pi, device, pen=(0,255,0))


clear(device)
x = randn(1000)
plot(x, device)
grid(device)    

 
clear(device)
x = randn(1000)
y = 2*x + 3 + randn(1000) * 0.1
plot(x, y, device)   
