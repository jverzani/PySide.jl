##################################################
## Qt utilities


## connect a callback to clicked event
qconnect(callback::Function, object::PyObject, signal::Symbol) = object[signal][:connect](callback)
qconnect(object::PyObject, signal::Symbol, callback::Function) = object[signal][:connect](callback)
qconnect(object::PyObject, signal::Symbol, slot::PyObject) = object[signal][:connect](slot)

qemit(object::PyObject, signal::ASCIIString) = object[:emit](QtCore[:SIGNAL](signal))
qemit(object::PyObject, signal::Symbol) = qemit(object, "$signal()")

## o[:symbol](xs...) -> qcall(o, :symbol, xs...)
qcall(object::PyObject, member::Symbol, args...) = object[member](args...)

## get Qt.Qt.enum as pyobject (http://qt-project.org/doc/qt-4.8/qt.html)
## TODO: generelize to others by passing in second argument
qt_enum(attr::Symbol) = qt_enum(string(attr))
qt_enum(attr::ASCIIString) = QtCore["Qt"][attr] # want pyobject here, not :Qt

## combining enums require us to work in python:
PyCall.pyeval("execfile(x, globals())", x = Pkg.dir("PySide", "tpl", "imports.tpl"))
qt_enum(attr::Vector{ASCIIString}; how="|") = PyCall.pyeval(join(map(u -> "QtCore.Qt.$u", attr), " $how "))

## some converstion
## This seems unnecessary with PySide
## convert text to string ## this is python2 http://pyqt.sourceforge.net/Docs/PyQt4/gotchas.html#python-strings-qt-strings-and-unicode
### from_QString(o::PyObject)  = pyeval("str(x)", {:x => o})

qexec(object::PyObject) = convert(Function, object[:exec])()

##################################################
## Methods for extending classes. Hacky.
newclass_tpl = Mustache.template_from_file(Pkg.dir("PySide", "tpl", "newclass.tpl"))

## Create new class from parent
## qclass("Example", "QtGui.QWidget") ## not Qt.QWidget...
## can pass in methods as strings.
## e.g. qnew_class("Julia", "QtCore.QObject", meths=[{:meth_dfn => "evaluate = QtCore.Signal(str)"}])
## then can connect to evalute signal, qconnect(julia, :evaluate, (cmd) -> print(cmd))
function qnew_class(name::ASCIIString, parent::ASCIIString; meths=nothing)
    tmp = tempname() * ".py"
    io = open(tmp, "w")
    d = {:NewClass=>name, :OldClass=>parent}
    if !isa(meths, Nothing) d[:methods] = meths end
    out = Mustache.render(io, newclass_tpl, d)
    println(out)
    close(io)
    PyCall.pyeval("execfile('$tmp', globals())")
end

## make an instance of the new class
qnew_class_instance(name::ASCIIString) = PyCall.pyeval("$name()")
qnew_class_instance(name::ASCIIString, parent) = PyCall.pyeval("$name(x)", x=parent)

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
