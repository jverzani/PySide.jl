## check that signal's and slots work

using PySide



## test it with a Qt example
w = Widget()
setWindowTitle(w, "Example")


lcd = Qt.QLCDNumber(w.w)
sld = Slider(w)
btn = Button(w)
setText(btn, "click me")


vbox = VBoxLayout(w)
map(u -> addWidget(vbox, u), (lcd, sld, btn))


setLayout(w, vbox)


## connect valueChanged signal of sld with display slot of lcd
qconnect(sld, :valueChanged, lcd[:display])
qconnect(btn, :clicked) do
  println("clicked button")
end


raise(w)
