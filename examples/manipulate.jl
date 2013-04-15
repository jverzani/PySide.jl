## This is an example mimicking RStudio's `manipulate` package (inspired by Mathematica's no doubt)
## The manipulate function makes it easy to create "interactive" GUIs. In this case, we can
## dynamically control parameters of a `Winston` graph.
## To add a control is easy. There are just a few: slider, picker, checkbox, button, and entry

## Load me with: reload(Pkg.dir("PySide", "examples", "manipulate.jl")


using Winston
using PySide                            # winston first! PySide and Winston have issues, likely with event loop

## We render output into a label. Here are some different renderers...
function render(parent, p::String)
    parent[:setText](p)
end
function render(parent::PyCall.PyObject, p::Winston.FramedPlot)
    nm = tempname() * ".png"
    file(p, nm)
    px = Qt.QPixmap()
    px[:load](nm)
    parent[:setPixmap](px)
end

function render(parent::PyCall.PyObject, p::Winston.FramedPlot)
    nm = tempname() * ".png"
    file(p, nm)
    px = Qt.QPixmap()
    px[:load](nm)
    parent[:setPixmap](px)
end

## do a manipulate type thing

## context to store dynamic values
module ManipulateContext
using Winston
end


abstract ManipulateWidget
get_label(widget::ManipulateWidget) = widget.label

##################################################

type SliderWidget <: ManipulateWidget
    w
    nm
    label
    initial
    rng
end
function make_widget(parent, widget::SliderWidget)
    sl = Qt.QSlider(qt_enum("Horizontal"), parent)
    sl[:setMinimum](min(widget.rng))
    sl[:setMaximum](max(widget.rng))
    sl[:setValue](min(widget.initial))
    widget.w = sl
end
function change_handler(widget::SliderWidget, callback::Function)
    qconnect(widget.w, :valueChanged) do value
      callback()
    end
end
get_value(widget::SliderWidget) = widget.w[:value]()


slider(nm::String, label::String, rng::Range1, initial::Integer) = SliderWidget(nothing, nm, label, initial, rng)
slider(nm::String, label::String, rng::Range1) = slider(nm, label, rng, min(rng))
slider(nm::String,  rng::Range1) = slider(nm, nm, rng, min(rng))

##################################################

type PickerWidget <: ManipulateWidget
    w
    nm
    label
    initial
    vals
end

function make_widget(parent, widget::PickerWidget)
    cb = Qt.QComboBox(parent)
    m = Qt.QStringListModel(widget.vals, cb)
    cb[:setModel](m)
## XXX    set_value(cb, widget.initial) 
    widget.w = cb
end
function change_handler(widget::PickerWidget, callback::Function)
    qconnect(widget.w, :activated) do index
       callback()
    end
end
function get_value(widget::PickerWidget)
    idx = widget.w[:currentIndex]()
    m = widget.w[:model]()
    cur_index = m[:index](idx, 0)
    cur_index[:data]()
end
    

    
picker{T <: String}(nm::String, label::String, vals::Vector{T}, initial) = PickerWidget(nothing, nm, label, initial, vals)
picker{T <: String}(nm::String, label::String, vals::Vector{T}) = picker(nm, label, vals, vals[1])
picker{T <: String}(nm::String, vals::Vector{T}) = picker(nm, nm, vals)
picker(nm::String, label::String, vals::Dict, initial) = PickerWidget(nm, label, vals, initial)
picker(nm::String, label::String, vals::Dict) = PickerWidget(nm, label, vals, [string(k) for (k,v) in vals][1])
picker(nm::String, vals::Dict) = picker(nm, nm, vals)

##################################################

type CheckboxWidget <: ManipulateWidget
    w
    nm
    label
    initial
end
function make_widget(parent, widget::CheckboxWidget)
    w = Qt.QCheckBox(parent)
    w[:setText](widget.label)
    w[:setCheckState](QtCore["Qt"][widget.initial ? "Checked" : "Unchecked"])
    widget.w = w
end
function change_handler(widget::CheckboxWidget, callback::Function)
    qconnect(widget.w, :stateChanged) do state
       callback()
    end
end
get_value(widget::CheckboxWidget) = widget.w[:isChecked]()
get_label(widget::CheckboxWidget) = nothing

checkbox(nm::String, label::String, initial::Bool) = CheckboxWidget(nothing, nm, label, initial)
checkbox(nm::String, label::String) = checkbox(nm, label, false)

##################################################

type ButtonWidget <: ManipulateWidget
    w
    label
    nm
end
function make_widget(parent, widget::ButtonWidget)
    btn = Qt.QPushButton(parent)
    btn[:setText](widget.label)
    widget.w = btn
end
function change_handler(widget::ButtonWidget, callback::Function)
    qconnect(widget.w, :pressed) do 
       callback()
    end
end 
get_value(widget::ButtonWidget) = widget.w[:text]()
get_label(widget::ButtonWidget) = nothing


button(label::String) = ButtonWidget(nothing, label, nothing)


## Add text widget to gather one-line of text
type EntryWidget <: ManipulateWidget
    w
    nm
    label
    initial
end
function make_widget(parent, widget::EntryWidget)
    e = Qt.QLineEdit(parent)
    e[:setText](widget.initial)
    widget.w = e
end
function change_handler(widget::EntryWidget, callback::Function)
    qconnect(widget.w, :editingFinished) do
      callback()
    end
end
get_value(widget::EntryWidget) = widget.w[:text]()

entry(nm::String, label::String, initial::String) = EntryWidget(nothing, nm, label, initial)
entry(nm::String, initial::String) = EntryWidget(nm, nm, initial)
entry(nm::String) = EntryWidget(nm, nm, "")


## Expression returns a plot object. Use names as values
function manipulate(ex::Union(Symbol,Expr), w, controls...)

    lyt = Qt.QHBoxLayout(w)
    w[:setLayout](lyt)
    
    pg = Qt.QSplitter(w)
    lyt[:addWidget](pg)
    
    control_pane = Qt.QWidget(pg)
    graph = Qt.QLabel(pg)               # This would be QtSvg.QSvgWidget if using Gadfly
    pg[:addWidget](control_pane)
    pg[:addWidget](graph)
    
    form_lyt = Qt.QFormLayout(control_pane)
    control_pane[:setLayout](form_lyt)
    
    ## create, layout widgets
    for widget in controls
        make_widget(control_pane, widget)
        form_lyt[:addRow](get_label(widget), widget.w)
    end

    get_values() = [get_value(i) for i in  controls]
    get_nms() = map(u -> u.nm, controls)
    function get_vals()
        d = Dict()                      # return Dict of values
        vals = get_values(); keys = get_nms()
        for i in 1:length(vals)
            if !isa(keys[i], Nothing)
                d[keys[i]] = vals[i]
            end
        end
        d
    end

    function dict_to_module(d::Dict) ## stuff values into Manipulate Context
        for (k,v) in d
            eval(ManipulateContext, :($(symbol(k)) = $v))
        end
    end
    
    function make_graphic(x...)
        d = get_vals()
        dict_to_module(d)
        p = eval(ManipulateContext, ex)
        render(graph, p)
    end
    
    map(u -> change_handler(u, make_graphic), controls)
    make_graphic()
    controls
end




## we need to make an expression
## here we need to
## * return p, the FramedPlot object to draw

ex = quote
    x = linspace( 0, n * pi, 100 )
    c = cos(x)
    s = sin(x)
    p = FramedPlot()
    setattr(p, "title", title)
    if
        fillbetween add(p, FillBetween(x, c, x, s) )
    end
    add(p, Curve(x, c, "color", color) )
    add(p, Curve(x, s, "color", "blue") )
    file(p, "example1.png")
    p
end

w = Qt.QWidget()
 obj = manipulate(ex, w, 
                  slider("n", "[0, n*pi]", 1:10)
                  ,entry("title", "Title", "title")
                  ,checkbox("fillbetween", "Fill between?", true)
                  ,picker("color", "Cos color", ["red", "green", "yellow"])
                  ,button("update")
                  )
           
w[:show](); raise(w)
