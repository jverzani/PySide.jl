## Using basic pyqtgraph installed as follows:
## download source from http://www.pyqtgraph.org/
## installed globally with sudo python setup.py install

## From Plot.py example

using PyCall
@pyimport pyqtgraph as pg
@pyimport numpy as np
using PySide


win = pg.GraphicsWindow(title="Basic plotting examples")
win[:resize](1000,600)
win[:setWindowTitle]("pyqtgraph example: Plotting")


p1 = win[:addPlot](title="Basic array plotting", y=np.random[:normal](size=100))

p2 = win[:addPlot](title="Multiple curves")
p2[:plot](np.random[:normal](size=100), pen=(255,0,0))
p2[:plot](np.random[:normal](size=100)+5, pen=(0,255,0))
p2[:plot](np.random[:normal](size=100)+10, pen=(0,0,255))

p3 = win[:addPlot](title="Drawing with points")
p3[:plot](np.random[:normal](size=100), pen=(200,200,200), symbolBrush=(255,0,0), symbolPen="w")






win[:nextRow]()

p4 = win[:addPlot](title="Parametric, grid enabled")
x = cos(linspace(0, 2*pi, 1000))
y = sin(linspace(0, 4*pi, 1000))
p4[:plot](x, y)
p4[:showGrid](x=true, y=true)

p5 = win[:addPlot](title="Scatter plot, axis labels, log scale")
x = 1e-5 * rand(1000)
y = x*1000 + 0.005 * randn(1000)
y -= min(y)-1.0
mask = x .> 1e-15
x = x[mask]
y = y[mask]
p5[:plot](x, y, pen=nothing, symbol="t", symbolPen=nothing, symbolSize=10, symbolBrush=(100, 100, 255, 50))
p5[:setLabel]("left", "Y Axis", units="A")
p5[:setLabel]("bottom", "Y Axis", units="s")
p5[:setLogMode](x=true, y=false)

p6 = win[:addPlot](title="Updating plot")
curve = p6[:plot](pen="y")
data = randn(10, 10000)
ptr = 0
function update()
    global curve, data, ptr, p6
    curve[:setData]([1:10_000 data[1 + ptr%10,:]']) # had to fix this
    if ptr == 0
        p6[:enableAutoRange]("xy", false)  ## stop auto-scaling after the first data set is plotted
    end
    ptr += 1
end

timer = QtCore.QTimer()
qconnect(timer, :timeout, update)
timer[:start](50)




win[:nextRow]()

p7 = win[:addPlot](title="Filled plot, axis disabled")
y = sin(linspace(0.0, 10, 1000)) + randn(1000)*0.1
p7[:plot](y, fillLevel=-0.3, brush=(50,50,200,100))
p7[:showAxis]("bottom", false)


x2 = linspace(-100, 100, 1000)
data2 = sin(x2) ./ x2
p8 = win[:addPlot](title="Region Selection")
p8[:plot](data2, pen=(255,255,255,200))
lr = pg[:LinearRegionItem]([400,700])
lr[:setZValue](-10)
p8[:addItem](lr)

p9 = win[:addPlot](title="Zoom on selected region")
p9[:plot](data2)
function updatePlot()
    p9[:setXRange](lr[:getRegion](), padding=0)
end
function updateRegion()
    lr[:setRegion](p9[:getViewBo]x()[:viewRange]()[0 + 1])
end
qconnect(lr, :sigRegionChanged, updatePlot)
qconnect(p9, :sigXRangeChanged, updateRegion)
updatePlot()
