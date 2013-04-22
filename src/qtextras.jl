## Code to more easily create widgets

abstract QtWidget
abstract QtLayout <: QtWidget
AWidget = Union(QtWidget, PyObject)
Slot = Union(AWidget, Function)


## How to make these types programmatically?
type MainWindow <: QtWidget w::PyObject;  MainWindow(parent) = new(Qt.QMainWindow(project(parent))) end
type DockWidget <: QtWidget w::PyObject;  DockWidget(parent) = new(Qt.QDockWidget(project(parent))) end
type Widget     <: QtWidget w::PyObject;  Widget(parent)     = new(Qt.QWidget(project(parent)))     end
type Icon       <: QtWidget w::PyObject;  Icon(parent)       = new(Qt.QIcon(project(parent)))       end
type Label      <: QtWidget w::PyObject;  Label(parent)      = new(Qt.QLabel(project(parent)))      end
type PushButton <: QtWidget w::PyObject;  PushButton(parent) = new(Qt.QPushButton(project(parent))) end
type Slider     <: QtWidget w::PyObject;  Slider(parent)     = new(Qt.QSlider(project(parent)))     end
type SpinBox    <: QtWidget w::PyObject;  SpinBox(parent)    = new(Qt.QSpinBox(project(parent)))    end
type LineEdit   <: QtWidget w::PyObject;  LineEdit(parent)   = new(Qt.QLineEdit(project(parent)))   end
type TextEdit   <: QtWidget w::PyObject;  TextEdit(parent)   = new(Qt.QTextEdit(project(parent)))   end
type CheckBox   <: QtWidget w::PyObject;  CheckBox(parent)   = new(Qt.QCheckBox(project(parent)))   end
type RadioButton<: QtWidget w::PyObject;  RadioButton(parent)= new(Qt.QRadioButton(project(parent)))end    
type ComboBox   <: QtWidget w::PyObject;  ComboBox(parent)   = new(Qt.QComboBox(project(parent)))   end
## XXX

type VBoxLayout <: QtLayout w::PyObject;  VBoxLayout(parent) = new(Qt.QVBoxLayout(project(parent))) end
type HBoxLayout <: QtLayout w::PyObject;  HBoxLayout(parent) = new(Qt.QHBoxLayout(project(parent))) end
type FormLayout <: QtLayout w::PyObject;  FormLayout(parent) = new(Qt.QFormLayout(project(parent))) end
type GridLayout <: QtLayout w::PyObject;  GridLayout(parent) = new(Qt.QGridLayout(project(parent))) end
type TabWidget <: QtLayout w::PyObject;  TabWidget(parent) = new(Qt.QTabWidget(project(parent))) end
type Splitter <: QtLayout w::PyObject;  Splitter(parent) = new(Qt.QSplitter(project(parent))) end
type StackedLayout <: QtLayout w::PyObject;  StackedLayout(parent) = new(Qt.QStackedLayout(project(parent))) end

type ButtonGroup<: QtWidget w::PyObject;  ButtonGroup(parent)= new(Qt.QButtonGroup(project(parent)))end
type GroupBox   <: QtWidget w::PyObject;  GroupBox(parent)   = new(Qt.QGroupBox(project(parent)))   end


    

## inovke a method with args
## widget[:method](args)
qinvoke(widget::AWidget, method::Symbol, args...) = project(widget)[method](map(project, args)...)

import Base.getindex
getindex(widget::QtWidget, i::Symbol) = widget.w[i]

## We implement these methods for easier programming of common tasks
get_value(object::QtWidget) = XXX()
set_value(object::QtWidget, value) = XXX()
get_items(object::QtWidget) = XXX()
set_items(object::QtWidget, items) = XXX()
change_slot(object::QtWidget, slot::Slot) = XXX() ## we pass in a slot that expect the value to be passed (value) -> stuff or some PyObject

    
               
    

## does widget exist?
qt_exists(widget::QtWidget) = XXX()


qconnect(widget::QtWidget, signal::Symbol, slot::Slot) =
    PySide.qconnect(project(widget), signal, project(slot))
    qconnect(callback::Function, widget::QtWidget, signal::Symbol) = qconnect(widget, signal, callback)




## Maybes
MaybeQtWidget = Union(Nothing, QtWidget)
MaybeString = Union(Nothing, String)

## project down to PyObject space otherwise pass through
project(widget) = widget
project(widget::QtWidget) = widget.w

    
## make this from members ...
## Qt use camelCase with getters not having get. 
for nm in (:windowTitle,    
           :setWindowTitle, 
           :text,           
           :setText,
           :toPlainText,
           :setPlainText,
           :html,
           :setHtml,
           :value,          
           :setValue,       
           
           :setIcon,        
           
           :setLayout,      
           :addWidget,
           :addLayout,
           :addTab,
           :addRow,
           :insertRow,
           :setWidget      
           )
    meth = string(nm)
    @eval ($nm)(widget::AWidget, args...) = qinvoke(project(widget), symbol($meth), args...)
end

## set focus
setFocus(widget::AWidget, reason::String) = qinvoke(widget, :setFocus, qt_enum(reason))
setFocus(widget::AWidget) = qinvoke(widget, :setFocus, "OtherFocusReason")

## raise and show window                                     
function raise(widget::AWidget)
    qinvoke(widget, :show)
    convert(Function, project(widget)[:raise])()
end

##################################################
## Containers    
    
## MainWindow
MainWindow() = MainWindow(nothing)
setCentralWidget(widget::MainWindow, child::AWidget) = qinvoke(widget, :setCentralWidget, child)

## DockWidget Possible areas
## Qt::LeftDockWidgetArea	0x1
## Qt::RightDockWidgetArea	0x2
## Qt::TopDockWidgetArea	0x4
## Qt::BottomDockWidgetArea	0x8
## Qt::AllDockWidgetAreas	DockWidgetArea_Mask
## Qt::NoDockWidgetArea
addDockWidget(widget::MainWindow, area::String, child::DockWidget, orientation::String) =
    qinvoke(widget, :addDockWidget, qt_enum(area), child, qt_enum(orientation))
addDockWidget(widget::MainWindow, area::String, child::DockWidget) = qinvoke(widget, :addDockWidget, qt_enum(area), child)


## Widget
Widget() = Widget(nothing)
get_value(widget::Widget) = windowTitle(widget)
set_value(widget::Widget, value::String) = setWindowTitle(widget, value)


##################################################
## Layouts

## adjust spacing, layout of widget, layout
setAlignment(widget::AWidget, alignment::String) = qinvoke(widget, :setAlignment, qt_enum(alignment))
setSpacing(lyt::QtLayout, px::Integer) = qinvoke(lyt, :setSpacing, px)

## julia array-like interfaces for adding, inserting and deleting a widget
push!(lyt::QtLayout, widget::AWidget) = addWidget(lyt, widget)
setindex!(lyt::QtLayout, widget::AWidget, i::Int) = qinvoke(lyt, :insertWidget, i, widget)
function delete!(lyt::QtLayout, widget::AWidget)
    qinvoke(lyt, :removeWidget, widget)
    qinvoke(widget, :hide)
end

getindex!(lyt::QtLayout, i::Int) = qinvoke(qinvoke(lyt, :itemAt, i-1), :widget)
pop!(lyt::QtLayout) = delete!(lyt, lyt[qinvoke(lyt, :count)])
    



## VBoxLayout

## HBoxLayout

## FormLayout

## XXX need grid layout
function addWidget(lyt::GridLayout, widget::AWidget, row::Int, column::Int, rowSpan::Int, columnSpan::Int, alignment::String)
    qinvoke(lyt, :addWidget, widget, row, column, rowSpan, columnSpan, qt_enum(alignment))
end
addWidget(lyt::GridLayout, widget::AWidget, row::Int, column::Int, rowSpan::Int, columnSpan::Int) = addWidget(lyt, widget, row, column, rowSpan, columnSpan, "AlignLeft")
addWidget(lyt::GridLayout, widget::AWidget, row::Int, column::Int, alignment::String) = qinvoke(lyt, :addWidget, widget, row, column, qt_enum(alignment))
addWidget(lyt::GridLayout, widget::AWidget, row::Int, column::Int, alignment::String) = addWidget(lyt, widget, row, column, "AlignLeft")

## lyt[i,j:k] = widget interface
function setindex!(lyt::GridLayout, widget::AWidget, i::Union(Int, Range, Range1), j::Union(Int, Range, Range1)) 
    if isa(i, Union(Range, Range1)) | isa(j, Union(Range, Range1))
        addWidget(lyt, widget, min(i), min(j), max(i) - min(i) + 1, max(j) - min(j) + 1)
    else
        addWidget(lyt, widget, i, j)
    end
end

addLayout(lyt::GridLayout, widget::QtLayout, row::Int, column::Int, rowSpan::Int, columnSpan::Int) = addLayout(lyt, widget, row, column, rowSpan, columnSpan, "AlignLeft")
addLayout(lyt::GridLayout, widget::QtLayout, row::Int, column::Int, alignment::String) = qinvoke(lyt, :addLayout, widget, row, column, qt_enum(alignment))
addLayout(lyt::GridLayout, widget::QtLayout, row::Int, column::Int, alignment::String) = addLayout(lyt, widget, row, column, "AlignLeft")
## lyt[i,j:k] = lyt interface
function setindex!(lyt::GridLayout, widget::QtLayout, i::Union(Int, Range, Range1), j::Union(Int, Range, Range1)) 
    if isa(i, Union(Range, Range1)) | is(j, Union(Range, Range1))
        addLayout(lyt, widget, min(i), min(j), (max(i) - min(i)) + 1, max(j) - min(j) + 1)
    else
        addLayout(lyt, widget, i, j)
    end
end

## QTabWidget
addTab(lyt::TabWidget, widget::AWidget, label::String) = qinvoke(lyt, :addTab, widget, label)
addTab(lyt::TabWidget, widget::AWidget, icon::Icon, label::String) = qinvoke(lyt, :addTab, widget, icon, label)
get_value(lyt::TabWidget) = qinvoke(lyt, :currentIndex) + 1
set_value(lyt::TabWidget, i::Int) = qinvoke(lyt, :setCurrentIndex, i - 1)
change_slot(lyt::TabWidget, slot::Function) = qconnect(lyt, :currentChanged, (value) -> slot(value + 1))
change_slot(lyt::TabWidget, slot::AWidget) =  qconnect(lyt, :currentChanged, project(slot))
                                                                                              
## QStackedLayout
get_value(lyt::StackedLayout) = qinvoke(lyt, :currentIndex) + 1
set_value(lyt::StackedLayout, i::Int) = qinvoke(lyt, :setCurrentIndex, i - 1)
change_slot(lyt::StackedLayout, slot::Function) = qconnect(lyt, :currentChanged, (value) -> slot(value + 1))
change_slot(lyt::StackedLayout, slot::AWidget) =  qconnect(lyt, :currentChanged, project(slot))


## QSplitter
function Splitter(orientation::String, parent::AWidget)
    sp = Splitter(parent)
    qinvoke(sp, :setOrientation, qt_enum(orientation))
    sp
end
                                                                                              
##################################################    
## Controls
## Icon Icon("filename.gif")

## Label
function Label(parent, label::String)
    l = Label(parent)
    set_value(l, label)
    l
end
get_value(widget::Label) = text(widget)
set_value(widget::Label, value) = setText(widget, value)
change_slot(widget::Label, slot::Slot) = XXX() #  nothing doing
                     
## Button (PushButton alias)
Button(parent::QtWidget) = PushButton(parent) # alias
function Button(parent::QtWidget, text::MaybeString, image::Union(Nothing, Icon))
    btn = Button(parent)
    if isa(text, String) set_value(btn, text) end
    if isa(image, Icon) setIcon(btn, image) end
    btn
end
Button(parent::QtWidget, text::String) = Button(parent, text, nothing)
Button(parent::QtWidget, icon::Icon) = Button(parent, nothing, icon)
get_value(widget::PushButton) = text(widget)
set_value(widget::PushButton, value::String) = setText(widget, value)
change_slot(widget::PushButton, slot::Function) = qconnect(widget, :pressed, () -> slot(get_value(widget)))
    
## Slider
## Need integers here
function Slider{T <: Integer}(parent::QtWidget, orientation::String, range::Union(Range{T}, Range1{T}))
    sl = Slider(parent)
    setOrientation(sl, orientation)
    set_items(sl, range)
    set_value(sl, min(range))
    sl
end
Slider(parent::QtWidget,  range::Union(Range, Range1)) = Slider(parent, "Horizontal", range)
setOrientation(widget::Slider, orientation::String) = qinvoke(widget, :setOrientation, qt_enum(orientation)) ## Horizontal, Vertical

get_value(widget::Slider) = value(widget)
set_value(widget::Slider, value) = setValue(widget, value)
function set_items(widget::Slider, items::Union(Range, Range1))
    qinvoke(widget, :setRange, min(items), max(items))
    qinvoke(widget, :setPageStep, step(items))
end
change_slot(widget::Slider, slot::Slot) = qconnect(widget, :valueChanged, project(slot))
                     
## SpinBox
function SpinBox{T <: Integer}(parent::QtWidget, range::Union(Range{T}, Range1{T}))
    sp = SpinBox(parent)
    set_items(sp, range)
    set_value(sp, min(range))
    sp
end

get_value(widget::SpinBox) = value(widget)
set_value(widget::SpinBox, value) = setValue(widget, value)
function set_items{T <: Integer}(widgets::SpinBox, items::Union(Range{T}, Range1{T})) 
    qinvoke(widget, :setRange, min(items), max(items))
    qinvoke(widget, :setSingleStep, step(items))
end
change_slot(widget::SpinBox, slot::Slot) = qconnect(widget, :valueChanged, project(slot))
                     
## LineEdit
function LineEdit(parent::QtWidget, text::String)
    e = LineEdit(parent)
    set_value(text)
    e
end
setPlaceholderText(widget::LineEdit, value::String) = qinvoke(widget, :setPlaceHolderText, value)
## icons, validator,

get_value(widget::LineEdit) = text(widget)
set_value(widget::LineEdit, value) = setText(Widget, string(value))
function get_items(widget::LineEdit)    #  for completion
    completer = qinvoke(widget, :completer)
    model = qinvoke(completer, :model)  # StandardItemModel
    get_items(StandardItemModel(model))
end
function set_items(widget::LineEdit, items=Vector)
    completer = qinvoke(widget, :completer)
    if isa(completer, Nothing)
        completer = Qt.QCompleter(project(widget))
        qinvoke(widget, :setCompleter, completer)
    end

    model = qinvoke(completer, :model)
    if isa(model, Nothing)
        model = StandardItemModel(completer)
        qinvoke(completer, :setModel, model)
    else
        model = StandardItemModel(model)
    end
    set_items(model, items)
end
    
change_slot(widget::LineEdit, slot::Slot) = qconnect(widget, :textChanged, project(slot))                     



## TextEdit
## XXX Issues here as properties are not what are advertised: no text, html, plainText
get_value(widget::TextEdit) = qinvoke(widget, :toPlainText)
set_value(widget::TextEdit, value::String) = qinvoke(widget, :setPlainText, value)
change_slot(widget::TextEdit, slot::Function) = qconnect(widget, :textChanged, () -> slot(get_value(widget)))


## Check
get_value(widget::CheckBox) = qinvoke(widget, :isChecked)    
set_value(widget::CheckBox, value::Bool) = qinvoke(widget, :setCheckState, qt_enum(value ? "Checked" : "Unchecked"))
get_items(widget::CheckBox) = text(widget)
set_items(widget::CheckBox, value::String) = setText(widget, value)

    
## RadioButton
get_value(widget::RadioButton) = qinvoke(widget, :isChecked)
set_value(widget::RadioButton, value::Bool) = qinvoke(widget, :setChecked, value)
get_items(widget::RadioButton) = text(widget)
set_items(widget::RadioButton, value::String) = setText(widget, value)    

## Make a Radio Group instance
## an exclusive colletion of radio buttons, packed horizontally or vertically
## Not a Qt Widget, but made of GroupBox, ButtonGroup and RadioButtons    
type RadioGroup <: QtWidget
    w
    button_group
end
function RadioGroup{T <: String}(w::Widget, labels::Vector{T}, selected::Integer, orientation::String)
    bgp = ButtonGroup(w)
    gp = Qt.QGroupBox(project(w))
    rg = RadioGroup(gp, bgp)
    
    lyt = orientation == "Horizontal" ? HBoxLayout(gp) : VBoxLayout(gp)
    qinvoke(gp, :setLayout, lyt)
       btns = [begin r = RadioButton(w); set_items(r, label); r end for label in labels]
    set_items(bgp, btns)
    map(u -> addWidget(lyt, u), btns)
    set_value(bgp, selected)
    rg
end
RadioGroup{T <: String}(w::Widget, labels::Vector{T}, selected::Integer) = RadioGroup(w, labels, selected, "Horizontal")
RadioGroup{T <: String}(w::Widget, labels::Vector{T}, orientation::String) = RadioGroup(w, labels, 1, orientation)
RadioGroup{T <: String}(w::Widget, labels::Vector{T}) = RadioGroup(w, labels, 1, "Horizontal")    
    
get_value(widget::RadioGroup) = get_value(widget.button_group)
set_value(widget::RadioGroup, value) = set_value(widget.button_group, value)
get_items(widget::RadioGroup) = get_items(widget.button_group)
## XX set_items
change_slot(widget::RadioGroup, slot::Slot) = change_slot(widget.button_group, slot)    
    
## ButtonGroup
function get_value(widget::ButtonGroup)
    ## qinvoke(widget, :checkedId)   ## doesn't work
    btns = qinvoke(widget, :buttons)
    checked = map(u -> qinvoke(u, :isChecked), btns) | bool
    get_items(widget)[findfirst(checked)] ## return value not index
end
set_value(widget::ButtonGroup, i::Integer) = qinvoke(qinvoke(widget, :buttons)[i], :setChecked, true)
set_value(widget::ButtonGroup, value::String) = set_value(widget, findfirst(value .== get_items(widget)))
get_items(widget::ButtonGroup) = String[qinvoke(u, :text) for u in  qinvoke(widget, :buttons)]  # return labels, not buttons
set_items(widget::ButtonGroup, items) = map(u -> addButton(widget, u), items)
change_slot(widget::ButtonGroup, slot::PyObject) = qconnect(widget, :buttonReleased, slot)
change_slot(widget::ButtonGroup, slot::Function) = qconnect(widget, :buttonReleased, btn -> slot(get_value(widget)))
addButton(widget::ButtonGroup, child::AWidget) = qinvoke(widget, :addButton, child)    

##################################################
## Models    
    
## ComboBox
## items can be a vector -- or a DataFrame with (label, value, [icon])
function ComboBox{T <: String}(parent, items::Vector{T}, selected::Integer)
    cb = ComboBox(parent)
    set_items(cb, items)
    set_value(cb, selected)
    cb
end
ComboBox{T <: String}(parent, items::Vector{T}) = ComboBox(parent, items, 1)

function get_items(widget::ComboBox)
    m = qinvoke(widget, :model)
    get_items(StandardItemModel(m))
end

function set_items{T <: String}(widget::ComboBox, items::Vector{T})
    model = qinvoke(widget, :model)
    if isa(model, Nothing) 
        model = StandardItemModel(widget)
        qinvoke(widget, :setModel, model)
    else
        model = StandardItemModel(model)
    end
    set_items(model, items)
end



function get_value(widget::ComboBox; idx=nothing)
    if idx == nothing idx = qinvoke(widget, :currentIndex) end
    m = qinvoke(widget,:model)
    cur_index = qinvoke(m, :index, idx, 0)
    qinvoke(cur_index, :data)
end
set_value(widget::ComboBox, value::Integer) = qinvoke(widget, :setCurrentIndex, value-1)
function set_value(widget::ComboBox, value::String)
    items = get_items(widget)
    if contains(items, value)
        idx = findin(items, [value])[1]
    else
        idx = 0
    end
    set_value(widget, idx)
end
## How to get in activated(int)
change_slot(widget::ComboBox, slot::Function) = qconnect(widget, :activated, (idx) -> slot(get_value(widget; idx=idx)))
change_slot(widget::ComboBox, slot::Widget) = qconnect(widget, :activated, widget)

## Tables...





##################################################
## Standard Item Model

type StandardItemModel <: QtWidget
    w::PyObject
    function StandardItemModel(parent)
        isaStandardItemModel(parent) = ismatch(r"StandardItemModel", string(qinvoke(parent, :__class__)))
        isaStandardItemModel(parent) ? new(project(parent)) : new(Qt.QStandardItemModel(project(parent)))
    end
end

function get_items(model::StandardItemModel)
    m = project(model)
    indexes = map(i -> qinvoke(m, :index, i-1, 0), 1:qinvoke(m, :rowCount))
    String[qinvoke(u, :data) for u in indexes]
end


function set_items{T <: String}(model::StandardItemModel, items::Vector{T})
    qinvoke(model, :clear)
    map(i -> qinvoke(model, :setItem, i-1, Qt.QStandardItem(items[i])),  1:length(items))
end

## set icon with label, value, icon
function set_items{S <: String, T<:String}(model::StandardItemModel, items::Vector{S}, labels::Vector{T}, icon::Vector{Icon})
    qinvoke(model, :clear)
    for i in 1:length(items)
        item = Qt.QStandardItem(labels[i])
        ## set data value from items[i]
        qinvoke(item, :setData, items[i])
        qinvoke(item, :setIcon, icon[i]) ## XXX Does this work?
        qinvoke(model, :setItem, i-1, item)
    end
end
    
set_items{T<:String}(model::StandardItemModel, items::Vector{T}, icon::Vector{Icon}) = set_items(model, items, items, icon)

    
