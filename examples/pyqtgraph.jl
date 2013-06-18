## using the PyQtGraph submodule
## Examples from pyqtgraphs plotting.py
## translated into julia style

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

## addPlot adds a plot device in next column over and returns a plot object
p1 = addPlot(win, title="Basic array plotting")
p1.plot(randn(100))

p2 = addPlot(win, title="Multiple curves")
p2.plot(randn(100), pen=(255,0,0))
p2.plot(randn(100) + 5, pen=(0, 255, 0))
p2.plot(randn(100) + 10, pen=(0,0,255))


p3 = addPlot(win, title="Drawing with points")
p3.plot(randn(100), pen=(200, 200, 200), symbolBrush=(255,0,0), symbolPen="w")

nextRow(win)

p4 = addPlot(win, title="Parametric, grid enabled")
p4.plot(sin(linspace(0, 2pi, 1000)), cos(linspace(0, 2pi, 1000)))
p4.showGrid()                   # defaults x=true, y=true

p5 = addPlot(win, title="Scatter plot, axis labels, log scale")
x = 1e-5 * rand(1000)
y = x*1000 + 0.005 * randn(1000)
y -= min(y)-1.0
mask = x .> 1e-15
x = x[mask]
y = y[mask]
p5.plot(x, y, pen=nothing, symbol="t", symbolPen=nothing, symbolSize=10, symbolBrush=(100, 100, 255, 50))
p5.setLabel("left", text="Y Axis", units="A")
p5.setLabel("bottom", text="Y Axis", units="s")
p5.setLogMode(x=true, y=false)



p6 = addPlot(win, title="Updating plot")

curve = p6.plot(pen="y")
data = randn(10000, 10)
ptr = 0
function update()
    global curve, data, ptr, p6
    qinvoke(curve, :setData, 1:10_000, data[:, 1 + ptr]) # had to fix this
    if ptr == 0
        p6.enableAutoRange("xy", false)  ## stop auto-scaling after the first data set is plotted
    end
    ptr = (ptr + 1) % 10
end


timer = QtCore.QTimer()
qconnect(timer, :timeout, update)
qinvoke(timer, :start, 50)


nextRow(win)


p7 = addPlot(win, title="Filled plot, axis disabled")
y = sin(linspace(0.0, 10, 1000)) + randn(1000)*0.1
p7.plot(y, fillLevel=-0.3, brush=(50,50,200,100))
p7.showAxis("bottom", visible=false)



p8 = addPlot(win, title="Region Selection")

x2 = linspace(-100, 100, 1000)
data2 = sin(x2) ./ x2
p8.plot(data2, pen=(255,255,255,200))

## no special functions for LinearRegionItem
lr = pyqtgraph[:LinearRegionItem]([400,700])
qinvoke(lr, :setZValue, -10)
p8.addItem(lr)

p9 = addPlot(win, title="zoom")
p9.plot(data2)

function updatePlot()
    p9.setXRange(lr[:getRegion]()..., padding=0)
end
function updateRegion()
    view_range = qinvoke(p9, [:getViewBox, :viewRange]) # 2x2 array
    x_range = Int[view_range[1,j] for j in 1:2]         # a vector, not just view_range[1,:]'
    qinvoke(lr, :setRegion, x_range)
end
qconnect(lr, :sigRegionChanged, updatePlot)
qconnect(p9, :sigXRangeChanged, updateRegion)
updatePlot()

 #raise(w)