## PySide 


A `julia` package connecting `julia` to the `Qt` UI framework via
Steven G. Johnson's PyCall connection to `Python`
(https://github.com/stevengj/PyCall.jl) and the `PySide` libraries of
the Qt Project (http://qt-project.org/wiki/PySide).

(An alternative could be to use `PyQt`, but `PySide` proved easy to
install and does a better job with the seamless conversion of `python`
objects into `julia` objects.)


This package doesn't provide much beyond:

* configures `PyCall`'s event loop integration

* a few convenience functions

* some examples illustrating the basic usage.


### A basic "hello world" example

This example illustrates how to use the `PyCall` interface to produce a basic GUI with a
parent container, layout, button, callback and dialog:

```
using PySide			# imports Qt, QtCore (Qt is QtGui)

w = Qt.QWidget()		# constructors
w[:setWindowTitle]("Hello world example") # w.setWindowTitle() is w[:setWindowTitle] in PyCall
lyt = Qt.QVBoxLayout(w)
w[:setLayout](lyt)

btn = Qt.QPushButton("Click me", w)
lyt[:addWidget](btn)

qconnect(btn, :clicked) do	# qconnect convenience to connect to a signal
  msg = Qt.QMessageBox(btn)
  msg[:setWindowTitle]("A message for you...")
  msg[:setText]("Hello world!")
  msg[:setInformativeText]("Thanks for clicking.")
  msg[:setIcon](Qt.QMessageBox()[:Information])   # how to pick out Qt::QMessageBox::Information enumeration
  convert(Function, msg[:exec])()       # Sometimes, one must must convert to a function (or call qexec(msg))
end

raise(w)			# show and raise widget
```

`PyCall` objects have many methods accessible through `.`, but not all. The `[:symbol'` notation can access the remainder. This allows access to most of the functionality of `PySide`.


### A (slightly) more convenient interface

We also provide a slightly more convenient interface for common tasks. For example, the "hello world" example could be written as:

```

using PySide			# imports Qt, QtCore (Qt is QtGui)

w = Widget()
setWindowTitle(w, "Hello world example (redux)") # methodName(object, args...)
lyt = VBoxLayout(w)		# we require a parent for all but Widget, MainWindow
setLayout(w, lyt)

btn = Button(w)
setText(btn, "Click me")
push!(lyt, btn)			# alternative to addWidget(lyt, btn)

qconnect(btn, :clicked) do	# also change_slot(btn, () -> MessageBox(...))
  MessageBox(btn, "Hi there", :Information)
end

raise(w)
```	

The constructors have some conveniences. As un-parented objects can go
out of scope, we require a parent to be passed in to all but the
top-level objects (`Widget` or `MainWindow`).

The methods have the basic signature `methodName(object,
args...)`. Alternatively, one can call as
`object[:methodName](args...)`. The latter is possible even if a
convenience method is not created.


The main point of this is to simplify some tasks, but also to give
each widget a type so we can write some generic methods, these being:

* `get_value` and `set_value` to retrieve the main value for selection

* `get_items` and `set_items` to get/set the items to select from

* `change_slot` to connect a slot to the most typical event.


There are other examples in the _examples_ directory.
