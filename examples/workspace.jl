## simple workspace browser for julia, not the prettiest of things.
using PySide
using DataFrames

## Some functions to work with a module
function get_names(m::Module)
    sort!(map(string, names(m)))
end

unique_id(v::Symbol, m::Module) = isdefined(m,v) ? unique_id(eval(m,v)) : ""
unique_id(x) = string(object_id(x))

## short_summary
## can customize description here
short_summary(x) = summary(x)
short_summary(x::String) = "A string"

## update ids, returning false if the same, true if not
__ids__ = Array(String, 0)
function update_ids(m::Module)
    global __ids__
    nms = get_names(m)
    nms = filter(u -> u != "__ids__", nms)
    a_ids = map(u -> unique_id(symbol(u), m), nms)
    if __ids__ == a_ids
        false
    else
        __ids__ = a_ids
        true
    end
end


MaybeFunction = Union(Nothing, Function)

## get array of names and summaries
## m module
## name_filter Function to filter names by  u -> ismatch(r"^A", u)
## obj_filter Function to filter objects by u -> isa(u, Function)
function get_names_summaries(m::Module, name_filter::MaybeFunction, obj_filter::MaybeFunction)
    nms = get_names(m)

    ## filter by name
    if !isa(name_filter, Nothing)
        nms = filter(name_filter, nms)
    end

    if !isa(obj_filter, Nothing)
        f(nm) = begin
            if !isdefined(m, symbol(nm)) return(false) end
            obj = eval(m, symbol(nm))
            obj_filter(obj)
        end
        nms = filter(f, nms)
    end
    
    summaries = map(u -> isdefined(m, symbol(u)) ? short_summary(eval(m,symbol(u))) : "undefined", nms)
    
    if length(nms) == length(summaries)
        return [nms summaries]
    else
        return nothing                  #  didn't match
    end
end

## we use globals to record the filters
global nm_filter = nothing
global obj_filter = nothing


function make_dataframe()
    d = get_names_summaries(Main, nm_filter, obj_filter)
    d = DataFrames.DataFrame(Variable=d[:,1],
                  Variable__BackgroundRole= DataFrames.rep("goldenrod", size(d)[1]),
                  Description=d[:,2])
    d
end

## Simple interface
w = Widget()
w[:resize](500, 400)
setWindowTitle(w, "Workspace browser")
lyt = VBoxLayout(w)
setLayout(w, lyt)

## View of objects
view = TableView(w)
addWidget(lyt, view)

m = DataFrameModel(make_dataframe(), view)
setModel(view, m)



header = view[:horizontalHeader]()
header[:setStretchLastSection](true)

header = view[:verticalHeader]()
header[:hide]()

view[:resizeColumnToContents](0)

function update(view)
    m = DataFrameModel(make_dataframe(), view)
    setModel(view, m)
end


## Name Filter combobox
ed = LineEdit(w)
qconnect(ed, :editingFinished) do
  val = text(ed)
  global nm_filter
  nm_filter = length(val) > 0 ? u -> ismatch(Regex(val), u) : nothing
  update(view)
end
## Object Filter combobox
cb = ComboBox(w)
set_items(cb, ["none", "Function", "PyObject", "Module"])
qconnect(cb, :activated) do idx
   di = {"none" => nothing,
         "Function" => u -> isa(u, Function),
         "PyObject" => u -> isa(u, PyCall.PyObject),
         "Module" => u -> isa(u, Module)
         }

    val = get_value(cb)

    global obj_filter
    obj_filter = di[val]
    update(view)
end

flyt = FormLayout(w)
flyt[:setAlignment](qt_enum(["AlignLeft", "AlignTop"], how="|"))
addLayout(lyt, flyt)

addRow(flyt, "Name filter:", ed)
addRow(flyt, "Type filter:", cb)



raise(w)


## Or run in timer
## run_timer(::Int32) = run_timer()
## run_timer() = update(view)

## global timer
## timer = Base.TimeoutAsyncWork(run_timer)
## Base.start_timer(timer,int64(200),int64(200))
