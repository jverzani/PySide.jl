## PySide 


A `julia` package connecting `julia` to the `Qt` UI framework via
Steven G. Johnson's PyCall connection to `Python`
(https://github.com/stevengj/PyCall.jl) and the `PySide` libraries of
the Qt Project (http://qt-project.org/wiki/PySide).

(An alternative could be to use `PyQt`, but `PySide` proved easy to
install and does a better job with the seamless conversion of `python`
objects into `julia` objects.)


This package doesn't provide much beyond:

* a means to integrate the `Qt` event loop within a `julia` session, shamelessly lifted from the `Tk` and `Gtk` packages

* a few convenience functions

* some examples illustrating the basic usage.


### A basic "hello world" example with a parent container, layout, button, callback and dialog illustrated:

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
  msg[:setIcon](Qt[:QMessageBox]()[:Information])   # how to pick out Qt::QMessageBox::Information enumeration
  convert(Function, msg[:exec])()       # Sometimes, one must must convert to a function (or call qexec(msg))
end

raise(w)			# show and raise widget
```


### TODO

* the data frame example is really slow. Need to speed this up.
* more examples
* check if this works on other setups.
