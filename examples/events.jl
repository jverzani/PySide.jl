## How to reimplement event handler. In Qt we would subclass. Do the same in PySide

using PySide

## we have a hack to create a new class and add methods to an instance.
## (You would need to write python code to create a new class with methods for all instances.)

## we call enter when we enter a widget

qnew_class("Example", "QtGui.QWidget") ## QtGui -- not just Qt.
o = qnew_class_instance("Example")
qset_method(o, :enterEvent) do e
  println("Welcome stranger.")
end

qset_method(o, :leaveEvent) do e
  println("Bye bye. Y'all come back now.")
end  

raise(o)
