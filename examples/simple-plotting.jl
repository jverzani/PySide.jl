## An example of how to add points, lines to a Graphics Scene and have them displayed in a GraphicsView.
## This follows some of the code of the qtpaint package from the R world by Michael Lawrence

using PySide


## copy qtpaint style
## We return graphics items generated
graphic_item_flag(item, flags) = PyCall.pyeval(join(["item.$u" for u in flags], " | "), item=item)
set_flags(item, flags) = item[:setFlags](graphic_item_flag(item, flags))



## Two constructors, on vectorized
function addPoint(sc::GraphicsScene, xs::Vector, ys::Vector, r;
                  lwd::Integer=1, pen_style::String="SolidLine", color::String="Black")
    function add_point(x, y, r, pen, brush)
        item = sc[:addEllipse](0, 0, r, r, pen, brush)
        item[:setPos](x, y)
        set_flags(item, ["ItemIsSelectable", "ItemIgnoresTransformations"])
        item
    end
    pen = Qt.QPen(Qt.QColor(color))
    pen[:setStyle](qt_enum(pen_style))
    pen[:setWidth](lwd)
    brush = Qt.QBrush(qt_enum("SolidPattern"))
    [add_point(xs[i], ys[i], r, pen, brush) for i in 1:length(xs)]
end
    
function addLine(sc::GraphicsScene, xs, ys;
                  lwd::Integer=1, pen_style::String="SolidLine", color::String="Black")
    pen = Qt.QPen(Qt.QColor(color))
    pen[:setStyle](qt_enum(pen_style))
    pen[:setWidth](lwd)
    brush = Qt.QBrush(qt_enum("SolidPattern"))
    [sc[:addLine](xs[i-1], ys[i-1], xs[i], ys[i], pen, brush) for i in 2:length(x)]
end

function addSegment(sc::GraphicsScene,  xs, ys, x1s, y1s;
                     lwd::Integer=1, pen_style::String="SolidLine", color::String="Black")
    pen = Qt.QPen(Qt.QColor(color))
    pen[:setStyle](qt_enum(pen_style))
    pen[:setWidth](lwd)
    brush = Qt.QBrush(qt_enum("SolidPattern"))
    [sc[:addLine](xs[i], ys[i], x1s[i], y1s[i], pen, brush) for i in 1:length(xs)]
end

function addPolygon(sc::GraphicsScene, xs, ys,
                     lwd::Integer=1, pen_style::String="SolidLine", color::String="Black")
    pen = Qt.QPen(Qt.QColor(color))
    pen[:setStyle](qt_enum(pen_style))
    pen[:setWidth](lwd)
    brush = Qt.QBrush()
    
    pts = [QtCore.QPoint(xs[i], ys[i]) for i in 1:length(xs)]
    item = sc[:addPolygon](pts, pen, brush)
   item
end
    
function addRect(sc::GraphicsScene,  xs, ys, ws, hs,
                 lwd::Integer=1, pen_style::String="SolidLine", color::String="Black")
    pen = Qt.QPen(Qt.QColor(color))
    pen[:setStyle](qt_enum(pen_style))
    pen[:setWidth](lwd)
    brush = Qt.QBrush(qt_enum("SolidPattern"))
    
    [sc[:addRect](x[i], y[i], w[i], h1[i], pen, brush) for i in 1:length(xs)]
end


function addText(sc::GraphicsScene, xs, ys, labels, html::Bool; font::String="Arial")
    function add_text(sc, x, y, label, html, font)
        item = sc[:addText]("")
        item[:setFont](Qt.QFont(font))
        if html
            item[:setHtml](label)
            item[:setOpenExternalLinks](true)
        else
            item[:setPlainText](label)
        end
        item[:setPos](x, y)
        set_flags(item, ["ItemIsMovable", "ItemIsSelectable", "QGraphicsItem::ItemIsFocusable", "ItemIgnoresTransformations"])
        item
    end
    [add_text(sc, xs[i], ys[i], labels[i], html, font) for i in 1:length(xs)]
end


## Return (view, scene)    
function PlotView(parent)
    qnew_class("PlotViewWidget", "QtGui.QGraphicsView")

    o = qnew_class_instance("PlotViewWidget")
    qinvoke(o, :setParent, parent)
    scene = GraphicsScene(parent)
    
    qinvoke(scene, :setSceneRect, 0,0, 1000, 1000)
    qinvoke(o, :setScene, scene)

    ## qtpaint has other options for resizing that may be better suited.
    function resize_event(event)
        osize = qinvoke(event, :oldSize)
        size =  qinvoke(o, [:viewport, :size])

        owidth = qinvoke(osize, :width); oheight = qinvoke(osize, :height)
        width = qinvoke(size, :width);   height = qinvoke(size, :height)

        if owidth < 0
            qinvoke(o, :fitInView, qinvoke(o, :sceneRect))
        else
            sx = width / owidth
            sy = height / oheight

            anchor = qinvoke(o, :transformationAnchor)
            qinvoke(o, :setTransformationAnchor, o[:NoAnchor])
            qinvoke(o, :scale, sx, sy)
            qinvoke(o, :setTransformationAnchor, anchor)
      
        end
    end
    o[:resizeEvent] = resize_event
    
    (o, scene)
end


## Some constants, best to be elsewhere
    xpx = 1000
    ypx = 1000
    xlim = [0, 10]
    ylim = [0, 10]

    
function scale_xy_px(xs, ys)
    width = xpx; height = ypx
    newxs = width*(xs - xlim[1])/(xlim[2] - xlim[1])
    newys = height - height * (ys - ylim[1]) / (ylim[2] - ylim[1])
    ([newxs], [newys])                  #  make vectors
end

    ## R-like interface to adding points and lines
function points(scene, xs, ys)
    newxs, newys = scale_xy_px(xs, ys)
    addPoint(scene, newxs, newys, 5)
end

function lines(scene, xs, ys)
    newxs, newys = scale_xy_px(xs, ys)
    addLine(scene, newxs, newys, 4)
end

##################################################


## https://groups.google.com/forum/?fromgroups=#!topic/julia-users/g9dp5fypJ88
## Example of stepping through graphics
t = linspace(0, 4pi, 512);
x = sin(t);
y = 0.1t.*cos(t);

xlim = [minimum(x), maximum(x)] * 1.05
ylim = [minimum(y), maximum(y)] * 1.05

w = Widget()
view, scene = PlotView(w)
push!(w, view)
raise(w)

i = 1
timer = QtCore[:QTimer]()
qconnect(timer, :timeout) do
global i
if i == 512
    qinvoke(timer, :stop)
else
    i = i + 1
    points(scene, x[i], y[i])
end
end
qinvoke(timer, :start, 20)
