## Using basic pyqtgraph installed as follows:
## download source from http://www.pyqtgraph.org/
## installed globally with sudo python setup.py install

## Mostly From ScatterPlot.py example

using PySide
using PySide.PyQtGraph

w = Widget()
lyt = VBoxLayout(w)
setLayout(w, lyt)

## Graphics Layout Widget make grid of plot devices
win = GraphicsLayoutWidget(w)
addWidget(lyt, win)
set_size(w, 800, 600)

raise(w)

## Here we create plot objects and lay them out first:
w0 = addPlot(win)
nextRow(win)

w1 = addPlot(win)

## add an API for this?
w2 = addViewBox(win)
w2[:setAspectLocked](true)

nextRow(win)

w3 = addPlot(win)
w4 = addPlot(win)

raise(win)

## This follows the `pyqtgraph` example that this example is taken from:

## There are a few different ways we can draw scatter plots; each is optimized for different types of data:
## 0) The easiest way, using addPoints addtion to GraphicsPlot objects
x = 1:10; y = rand(10)
w0.addPoints(x, y)
w0.addLine(x=0, y=1)



## 1) All spots identical and transform-invariant (top-left plot). 
## In this case we can get a huge performance boost by pre-rendering the spot 
## image and just drawing that image repeatedly.

n = 300
x = randn(n); y = randn(n)
s1 = ScatterPlotItem(x, y, size=10, pen=nothing, brush=(255, 255,255,120))
w1.addItem(s1)

## Make all plots clickable
lastClicked = nothing
function clicked(plot, points)
    global lastClicked
    println(typeof(lastClicked))
    if !isa(lastClicked, Nothing)
        map(u -> u[:resetPen](), lastClicked)
    end
    map(u -> u[:setPen]("b", width=2), points)
    lastClicked = points
end

function get_lastclicked()
    x = map(i -> qinvoke(i, [:pos, :x]), lastClicked) |> float
    y = map(i -> qinvoke(i, [:pos, :y]), lastClicked) |> float
    [x y]
end

qconnect(s1, :sigClicked, clicked)

  
## 2) Spots are transform-invariant, but not identical (top-right plot). 
## In this case, drawing is as fast as 1), but there is more startup overhead
## and memory usage since each spot generates its own pre-rendered image.

scale = 1e-5
x = rand(n)*scale; y = rand(n)*scale
s2 = ScatterPlotItem(x, y, size=[5 + (1:n)/10], pen="w", pxMode=true)
w2.addItem(s2)
qconnect(s2, :sigClicked, clicked)
#s2.sigClicked.connect(clicked)


## 3) Spots are not transform-invariant, not identical (bottom-left). 
## This is the slowest case, since all spots must be completely re-drawn 
## every time because their apparent transformation may have changed.

## Set pxMode=False to allow spots to transform with the win

x = [1e-6*i for  i in 1:10, j in 1:10] |> u -> reshape(u, 100)
y = [1e-6*j for  i in 1:10, j  in 1:10] |> u -> reshape(u, 100)
brush = [pyqtgraph.intColor(i*10+j, 100) for i in 1:10, j in 1:10] |> u -> reshape(u, 100)

s3 = ScatterPlotItem(x, y, pxMode=false, size=1e-6, pen={:color => "w", :width=>2}, brush=brush)

w3.addItem(s3)
qconnect(s3, :sigClicked,clicked)


     

## Test performance of large scatterplots
## This gets slow. Could not call as in exmaple
     ## addPoints(x=pos[0], y=pos[1])
n = 10^3                         # 1e4 is slow to respond
s4 = ScatterPlotItem(randn(n), randn(n), data=string(1:n), size=10, pen=nothing, brush=(255, 255, 255, 20))
w4.addItem(s4)
qconnect(s4, :sigClicked, clicked)

