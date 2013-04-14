## check that signal's and slots work

using PySide



## test it with a Qt example
w = Qt.QWidget()
w[:setWindowTitle]("Example")


lcd = Qt.QLCDNumber(w)
sld = Qt.QSlider(w)
btn = Qt.QPushButton(w)
btn[:setText]("click me")


vbox = Qt.QVBoxLayout()
map(u -> vbox[:addWidget](u), (lcd, sld, btn))


w[:setLayout](vbox)


## connect valueChanged signal of sld with display slot of lcd
qconnect(sld, :valueChanged, lcd[:display])
qconnect(btn, :clicked) do
  println("clicked button")
end


raise(w)
