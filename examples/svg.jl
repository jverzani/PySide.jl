## show an svg file
## reload(Pkg.dir("PySide", "examples", "svg.jl"))

using PySide
using Gadfly, Compose

w = Widget()
lyt = VBoxLayout(w)
setLayout(w, lyt)

sv = QtSvg.QSvgWidget(w.w)
addWidget(lyt, sv)

sl = Slider(w, "Horizontal", 2:10)
push!(lyt, sl)

function draw_plot(n)
    p = plot(sin, 0, n * pi)
    nm = tempname() * ".svg"
    draw(SVG(nm, 5inch, 5inch), p)
    sv[:load](nm)
end

draw_plot(1)

qconnect(sl, :valueChanged, draw_plot) ## value changed passes in value to slot

raise(w)
