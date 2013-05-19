## module for pyqtgraph
## More tedious than needed as passing kwargs... through isn't working and don't know why
## must specify names so need f(key=value) = w[:meth](..., key=key) tediousness
module PyQtGraph

using PyCall
@pyimport pyqtgraph as pg
@pyimport numpy as np
using PySide
import PySide


export GraphicsWindow, GraphicsLayoutWidget, PlotWidget, ScatterPlotWidget
export ScatterPlotItem
export plot, addPlot, addViewBox, nextRow, removeItem

abstract GraphicsContainer <: PySide.QtWidget

import Base.getindex
getindex(x::GraphicsContainer, i::Symbol) = x.w[i]

type GraphicsWindow <: GraphicsContainer
    w::PyObject
    GraphicsWindow(args...) = new(pg.GraphicsWindow(args...))
end

# Used for laying out GraphicsWidgets in a grid.
type GraphicsLayoutWidget <: GraphicsContainer
    w::PyObject
    GraphicsLayoutWidget(parent) = new(pg.GraphicsLayoutWidget(PySide.project(parent)))
end



## these should be at QtWidget level
## http://www.pyqtgraph.org/documentation/graphicsItems/graphicslayout.html#pyqtgraph.GraphicsLayout.__init__
resize(widget::GraphicsWindow, width::Int, height::Int) = qinvoke(widget, :resize, width, height)
setWindowTitle(widget::GraphicsWindow, args...) = qinvoke(widget, :setWindowTitle, args...)

plot(widget::GraphicsContainer, args...; kwargs...) = GraphicsPlot(qinvoke(widget, :plot, args..., kwargs...))
addPlot(widget::GraphicsContainer; title="") = GraphicsPlot(PySide.project(widget)[:addPlot](title=title))
addViewBox(widget::GraphicsContainer) = GraphicsPlot(qinvoke(widget, :addViewBox))
## layout
nextRow(widget::GraphicsContainer, args...) = qinvoke(widget, :nextRow, args...)
removeItem(widget::GraphicsContainer, item) = qinvoke(widget, :removeItem, item)

## ??? addViewBox


## PyQtGraphicsPlotItem
## Here we make these methods so basically we have
## w, dev = PlotWidget()
## dev.plot(x=1:10, y=1:20)
type GraphicsPlot <: PySide.QtWidget
    w::PyObject
    plot
    addPoints                   # points? add to API for scatter plot
    addItem
    removeItem
    clear
    addLegend
    addLine
    showGrid
    showAxis
    hideAxis
    setLabel
    setXRange
    setYRange
    enableAutoRange
    setLogMode
    
    function GraphicsPlot(w) 
        self = new(PySide.project(w), nothing)

        ## no kwargs with anonymous functions? Here we have to define generic...
        ## cf. http://www.pyqtgraph.org/documentation/graphicsItems/plotdataitem.html#pyqtgraph.PlotDataItem.__init__
        ## x, x,y, [x y]
        ## http://www.pyqtgraph.org/documentation/graphicsItems/scatterplotitem.html#pyqtgraph.ScatterPlotItem.setData
        ## axis is in ["‘left’, ‘bottom’, ‘right’, or ‘top’]
        plot(args...; pen="b", 
             brush=nothing,
             symbol=nothing, symbolPen=nothing, symbolSize=nothing, symbolBrush=nothing,
             fillLevel=nothing) =
          w[:plot](args...,  pen=pg.mkPen(pen), 
                   brush=pg.mkBrush(brush),
                   symbol=symbol, symbolPen=symbolPen, symbolBrush=symbolBrush,
                   fillLevel=fillLevel)
        ## XXX change name; better defaults
        addPoints(args...;  symbol="o", symbolSize=5,   symbolBrush=(255,255,255, 50), pen=nothing, symbolPen=nothing) =
          plot(args...; symbol=symbol, symbolSize=symbolSize, symbolBrush=symbolBrush, pen=pen, symbolPen=symbolPen)
        addItem(item, args...; kwargs...) = w[:addItem](PySide.project(item), args..., kwargs...)
        removeItem(item, args...; kwargs...) = w[:removeItem](PySide.project(item), args..., kwargs...)
        addLegend(;size=nothing, offset=(30,30)) = w[:addLegend](size=size, offset=offset)
        addLine(;x=nothing, y=nothing, z=nothing, kwargs...) = w[:addLine](x=x,y=y,z=z, kwargs...)
        showGrid(; x=true, y=true, alpha=nothing)  = w[:showGrid](x=x, y=y, alpha=alpha)
        showAxis(where::String; visible::Bool=true, kwargs...) = w[:showAxis](where, visible, kwargs...)
        hideAxis(axis::String) = w[:hideAxis](axis)
        setLabel(axis::String; text=nothing, units=nothing, kwargs...) = w[:setLabel](axis, text=text, units=units, kwargs...)
        setLogMode(args...; x=true, y=true, kwargs...) = w[:setLogMode](args..., x=x, y=y, kwargs...)
        enableAutoRange(args...; kwargs...) = w[:enableAutoRange](args..., kwargs...)
        setXRange(args...; kwargs...) = w[:setXRange](args..., kwargs...)
        setYRange(args...; kwargs...) = w[:setYRange](args..., kwargs...)

        self.plot = plot
        self.addPoints = addPoints
        self.addItem = addItem
        self.removeItem = removeItem
        self.clear = () -> w[:clear]()
        self.addLegend = addLegend
        self.addLine = addLine
        self.showGrid = showGrid
        self.showAxis = showAxis
        self.hideAxis = hideAxis
        self.setLabel = setLabel
        self.setLogMode = setLogMode
        self.enableAutoRange = enableAutoRange
        self.setXRange = setXRange
        self.setYRange = setYRange

        self
    end
end

getindex(x::GraphicsPlot, i::Symbol) = x.w[i]

## A GraphicsViewItem with a single plot
## return (container, device)
## XXX doesn't workPlotWidget(parent) = GraphicsPlot(pg.PlotWidget(PySide.project(parent))[:getPlotItem]())
function PlotWidget(parent)
    lyt = GraphicsLayoutWidget(parent)
    plot = addPlot(lyt)
    (lyt, plot)
end
    

ScatterPlotWidget(parent) = GraphicsPlot(pg.ScatterPlotWidget(PySide.project(parent)))

type ScatterPlotItem <: PySide.QtWidget
    w
    clear
    addPoints
    setBrush
    setData
    setPen
    setSize
    setSymbol
    function ScatterPlotItem(args...; pxMode::Bool=true, symbol="o", pen=nothing, brush=nothing, size=10, data=nothing) 

        self = new(pg.ScatterPlotItem(args..., pxMode=pxMode, symbol=symbol, pen=pen, brush=brush, size=size, data=data))
        
        addPoints(args...;kwargs...) = w[:addPoints](args..., kwargs...)
        setBrush(args...;kwargs...) = w[:setBrush](args..., kwargs...)
        setData(args...;kwargs...) = w[:setData](args..., kwargs...)
        setPen(args...;kwargs...) = w[:setPen](args..., kwargs...)
        setSize(size; update=true, dataSet=nothing, mask=nothing) = w[:setSize](size, update=update, dataSet=dataSet, mask=mask)
        setSymbol(symbol; update=true, dataSet=nothing, mask=nothing) = w[:setSymbol](symbol, update=update, dataSet=dataSet, mask=mask)
        self.clear = () -> w[:clear]()
        self.addPoints = addPoints
        self.setBrush = setBrush
        self.setData = setData
        self.setPen = setPen
        self.setSize = setSize
        self.setSymbol = setSymbol
        self
    end
end

    
    

## PlotCurveItem




## signals sigRegionChagned, sigRangeChanged, sigXRangeChangeed, sigYRangeChangeed, ...

## Pen http://www.pyqtgraph.org/documentation/functions.html#pyqtgraph.mkPen
# mkPen(color)
# mkPen(color, width=2)
# mkPen(cosmetic=False, width=4.5, color='r')
# mkPen({'color': "FF0", width: 2})
# mkPen(None)   # (no pen)
mkPen(args...) = pg.mkPen(args...)

## Brush: http://www.pyqtgraph.org/documentation/functions.html#pyqtgraph.mkColor
# ‘c’	one of: r, g, b, c, m, y, k, w
# R, G, B, [A]	integers 0-255
# (R, G, B, [A])	tuple of integers 0-255
# float	greyscale, 0.0-1.0
# int	see intColor()
# (int, hues)	see intColor()
# “RGB”	hexadecimal strings; may begin with ‘#’
# “RGBA”	 
# “RRGGBB”	 
# “RRGGBBAA”	 
# QColor	QColor instance; makes a copy.
mkBrush(args...) = pg.mkBrush(args...)



end