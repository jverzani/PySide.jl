
##################################################
## Utils

## connect a callback to clicked event
qconnect(callback::Function, object::PyObject, signal::Symbol) = object[signal][:connect](callback)
qconnect(object::PyObject, signal::Symbol, callback::Function) = object[signal][:connect](callback)
qconnect(object::PyObject, signal::Symbol, slot::PyObject) = object[signal][:connect](slot)

qemit(object::PyObject, signal::ASCIIString) = object[:emit](QtCore[:SIGNAL](signal))
qemit(object::PyObject, signal::Symbol) = qemit(object, "$signal()")

## o[:symbol](xs...) -> qcall(o, :symbol, xs...)
qcall(object::PyObject, member::Symbol, args...) = object[member](args...)

pluck(xs, key) = map(x -> x[key], xs)
function members(object::PyObject)
    convert(Vector{(String,PyObject)}, 
            pycall(PyCall.inspect["getmembers"], PyObject, object))
end
has_member(object::PyObject, key) = contains(pluck(members(object),1), key)

## get Qt.Qt.enum as pyobject (http://qt-project.org/doc/qt-4.8/qt.html)
## TODO: generelize to others by passing in second argument
qt_enum(attr::Symbol) = qt_enum(string(attr))
qt_enum(attr::ASCIIString) = QtCore["Qt"][attr] # want pyobject here

## some converstion
## This seems unnecessary with PySide
## convert text to string ## this is python2 http://pyqt.sourceforge.net/Docs/PyQt4/gotchas.html#python-strings-qt-strings-and-unicode
### from_QString(o::PyObject)  = pyeval("str(x)", {:x => o})

## show and raise a widget
function raise(object::PyObject)
    object[:show]()
    convert(Function, object[:raise])()
end
function qexec(object::PyObject) = convert(Function, object[:exec])()

## Make a standard item model from a data frame. SLOW!!!
qdataframemodel(df) = qdataframemodel(df, nothing)
function qdataframemodel(df, parent)
    model = Qt.QStandardItemModel(parent)
    for row in 1:nrow(df), col in 1:ncol(df)
        item = Qt.QStandardItem(string(df[row, col]))
            qcall(model,:setItem, row-1, col-1, item)
    end
    model
end


newclass_tpl = Mustache.template_from_file(Pkg.dir("PySide", "tpl", "newclass.tpl"))

## Create new class from parent
## qclass("Example", "QtGui.QWidget") ## not Qt.QWidget...
function qnew_class(name::ASCIIString, parent::ASCIIString)
    tmp = tempname() * ".py"
    io = open(tmp, "w")
    out = Mustache.render(io, newclass_tpl, {:NewClass=>name, :OldClass=>parent})
    close(io)
    PyCall.pyeval("execfile('$tmp', globals())")
end

## make an instance of the new class
qnew_class_instance(name::ASCIIString) = PyCall.pyeval("$name()")

## add a method to the class.
## qnew_class("Example", "QtGui.QWidget")
## o = qnew_class_instance("Example")
## qset_method(o, :enterEvent, e -> println("enter"))
## or
## qset_method(o, :enterEvent) do e
##    println("enter")
## end
qset_method(object::PyObject, meth::Symbol, callback::Function) = object[meth] = callback
qset_method(callback::Function, object::PyObject, meth::Symbol) = qset_method(object, meth, callback)
