## show an svg file
## reload(Pkg.dir("PySide", "examples", "svg.jl"))

using PySide
using Gadfly, Compose

w = Qt.QWidget()
lyt = Qt.QVBoxLayout(w)
w[:setLayout](lyt)

sv = QtSvg.QSvgWidget(w)
lyt[:addWidget](sv)

sl = Qt.QSlider(qt_enum("Horizontal"), w)
lyt[:addWidget](sl)

rng = 2:10
sl[:setMinimum](min(rng))
sl[:setMaximum](max(rng))
sl[:setValue](min(rng))

function draw_plot(n)
    p = plot(sin, 0, n * pi)
    nm = tempname() * ".svg"
    draw(SVG(nm, 5inch, 5inch), p)
    sv[:load](nm)
end

draw_plot(1)

qconnect(sl, :valueChanged, draw_plot) ## value changed passes in value to slot

raise(w)
