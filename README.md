## PySide 


A `julia` package connection `julia` to the `Qt` UI framework via
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
