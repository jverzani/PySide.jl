## Using basic pyqtgraph installed as follows:
## download source from http://www.pyqtgraph.org/
## installed globally with sudo python setup.py install

## From ScatterPlot.py example

using PyCall
@pyimport pyqtgraph as pg
@pyimport numpy as np
using PySide



win = Widget()
setWindowTitle(win, "A graphics window")

lyt = VBoxLayout(win)
setLayout(win, lyt)

# no qinvoke here with pg, np so we use the [:meth] style for non-pyside widgets
view = pg[:GraphicsLayoutWidget](win.w) 
push!(lyt, view)

w1 = view[:addPlot]()
w2 = view[:addViewBox]()
w2[:setAspectLocked](true)
view[:nextRow]()
w3 = view[:addPlot]()
w4 = view[:addPlot]()

raise(win)
## There are a few different ways we can draw scatter plots; each is optimized for different types of data:


## 1) All spots identical and transform-invariant (top-left plot). 
## In this case we can get a huge performance boost by pre-rendering the spot 
## image and just drawing that image repeatedly.

n = 300
s1 = pg[:ScatterPlotItem](size=10, pen=pg[:mkPen](nothing), brush=pg[:mkBrush](255, 255,255,120))

pos = np[:random][:normal](size=(2,n), scale=1e-5) # from numpy
spots = [{"pos" => pos[:,i], "data"=>1} for i in 1:n ]  
    s1[:addPoints](spots)
    w1[:addItem](s1)

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
qconnect(s1, :sigClicked, clicked)

  
## 2) Spots are transform-invariant, but not identical (top-right plot). 
## In this case, drawing is as fast as 1), but there is more startup overhead
## and memory usage since each spot generates its own pre-rendered image.

s2 = pg.ScatterPlotItem(size=10, pen=pg.mkPen('w'), pxMode=true)
pos = np.random[:normal](size=(2,n), scale=1e-5)
#    spots = [{"pos"=>pos[:,i], "data" => 1, "brush"=>pg.intColor(i, n), "symbol" => i % 5, "size"=> 5 + i/10.} for i in 1:n]
 spots = [{"pos"=>pos[:,i], "data" => 1,  "symbol" => i % 5, "size"=> 5 + i/10.} for i in 1:n]
s2[:addPoints](spots)
w2[:addItem](s2)
        qconnect(s2, :sigClicked, clicked)
#s2.sigClicked.connect(clicked)


## 3) Spots are not transform-invariant, not identical (bottom-left). 
## This is the slowest case, since all spots must be completely re-drawn 
## every time because their apparent transformation may have changed.

s3 = pg.ScatterPlotItem(pxMode=false)   ## Set pxMode=False to allow spots to transform with the view
spots3 = [{"pos" => (1e-6*i, 1e-6*j), "size" => 1e-6, "pen" => {"color"=>"w", "width"=>2}, "brush"=> pg.intColor(i*10+j, 100)} for i in 1:10, j in 1:10] | u -> reshape(u, 100)
s3[:addPoints](spots3)
w3[:addItem](s3)
qconnect(s3, :sigClicked,clicked)


     

## Test performance of large scatterplots
## This gets slow. Could not call as in exmaple
     ## addPoints(x=pos[0], y=pos[1])
n = 10000
s4 = pg.ScatterPlotItem(size=10, pen=pg.mkPen(nothing), brush=pg.mkBrush(255, 255, 255, 20))
     pos = np.random[:normal](size=(2,n), scale=1e-9)
  spots4 = [{"pos" => pos[:,i], "data"=>1} for i in 1:n ]     
s4[:addPoints](spots4)
w4[:addItem](s4)
qconnect(s4, :sigClicked, clicked)

