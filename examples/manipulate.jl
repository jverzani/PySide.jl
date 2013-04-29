## A manipuate like widget
## this follows the interface of RStudio's manipulate, which is likely following that of
## Mathematica's

using Winston ## Winston *must* load before PySide, this is flaky
using PySide

## We render output into a label. Here are some different renderers...
function render(parent, p::String)
    setText(parent, p)
end
function render(parent::Label, p::Winston.FramedPlot)
    nm = tempname() * ".png"
    file(p, nm)
    setPixmap(parent, Qt.QPixmap(nm))
end

function render(parent::Label, p::Winston.FramedPlot)
    nm = tempname() * ".png"
    file(p, nm)
    setPixmap(parent, Qt.QPixmap(nm))    
end


## context to store dynamic values
module ManipulateContext
using Winston
end


abstract ManipulateWidget

##################################################

type SliderWidget <: ManipulateWidget
    w
    nm
    label
    initial
    rng
end


slider(nm::String, label::String, rng::Range1, initial::Integer) = SliderWidget(nothing, nm, label, initial, rng)
slider(nm::String, label::String, rng::Range1) = slider(nm, label, rng, min(rng))
slider(nm::String,  rng::Union(Range, Range1)) = slider(nm, nm, rng, min(rng))

function make_widget(parent, widget::SliderWidget)
    sl = Slider(parent, "Horizontal", widget.rng)
    set_value(sl, widget.initial)
    widget.w = sl
end


type PickerWidget <: ManipulateWidget
    w
    nm
    label
    initial
    vals
end

function make_widget(parent, widget::PickerWidget)
    cb = ComboBox(parent)
    set_items(cb, widget.vals)
    set_value(cb, widget.initial)
    widget.w = cb
end


    
picker{T <: String}(nm::String, label::String, vals::Vector{T}, initial) = PickerWidget(nothing, nm, label, initial, vals)
picker{T <: String}(nm::String, label::String, vals::Vector{T}) = picker(nm, label, vals, vals[1])
picker{T <: String}(nm::String, vals::Vector{T}) = picker(nm, nm, vals)
picker(nm::String, label::String, vals::Dict, initial) = PickerWidget(nm, label, vals, initial)
picker(nm::String, label::String, vals::Dict) = PickerWidget(nm, label, vals, [string(k) for (k,v) in vals][1])
picker(nm::String, vals::Dict) = picker(nm, nm, vals)



type CheckboxWidget <: ManipulateWidget
    w
    nm
    label
    initial
end
function make_widget(parent, widget::CheckboxWidget)
    cb = CheckBox(parent)
    set_items(cb, widget.label)
    set_value(cb, widget.initial)
    widget.w = cb
end


checkbox(nm::String, label::String, initial::Bool) = CheckboxWidget(nothing, nm, label, initial)
checkbox(nm::String, label::String) = checkbox(nm, label, false)



type ButtonWidget <: ManipulateWidget
    w
    label
    nm
end
function make_widget(parent, widget::ButtonWidget)
    btn = Button(parent)
    set_value(btn, widget.label)
    widget.w = btn
end


button(label::String) = ButtonWidget(nothing, label, nothing)



## Add text widget to gather one-line of text
type EntryWidget <: ManipulateWidget
    w
    nm
    label
    initial
end
function make_widget(parent, widget::EntryWidget)
    e = LineEdit(parent)
    set_value(e, widget.initial)
    widget.w = e
end


entry(nm::String, label::String, initial::String) = EntryWidget(nothing, nm, label, initial)
entry(nm::String, initial::String) = EntryWidget(nm, nm, initial)
entry(nm::String) = EntryWidget(nm, nm, "")


## Expression returns a plot object. Use names as values
function manipulate(ex::Union(Symbol,Expr), w::Widget, controls...)

    lyt = HBoxLayout(w)
    setLayout(w, lyt)
    
    pg = Splitter(w)
    addWidget(lyt, pg)
    
    control_pane = Widget(pg)
    graph =Label(pg)               # This would be QtSvg.QSvgWidget if using Gadfly
    addWidget(pg, control_pane)
    addWidget(pg, graph)
    
    form_lyt = FormLayout(control_pane)
    setLayout(control_pane, form_lyt)
    
    ## create, layout widgets
    for widget in controls
        make_widget(control_pane, widget)
        addRow(form_lyt, widget.label, widget.w)
    end

    get_values() = [get_value(i.w) for i in  controls]
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
    
    map(u -> change_slot(u.w, make_graphic), controls)
    make_graphic()
    controls
end



### How this is employed:
ex = quote
    x = linspace( 0, n * pi, 100 )
    c = cos(x)
    s = sin(x)
    p = FramedPlot()
    setattr(p, "title", title)
    if fillbetween
        add(p, FillBetween(x, c, x, s) )
    end
    add(p, Curve(x, c, "color", color) )
    add(p, Curve(x, s, "color", "blue") )
    p
end

w = Widget()
obj = manipulate(ex, w, 
                 slider("n", "[0, n*pi]", 1:10)
                 ,entry("title", "Title", "title")
                 ,checkbox("fillbetween", "Fill between?", true)
                 ,picker("color", "Cos color", ["red", "green", "yellow"])
                 ,button("update")
                 )
raise(w)
