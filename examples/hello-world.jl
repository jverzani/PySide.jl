## Simple hello world showing
## * window
## * layout
## * button
## * callback
## * dialog

## This is done twice: first with PyCall syntax, then with qtextras

using PySide


w = Qt[:QWidget]()
w[:setWindowTitle]("Hello world example")
lyt = Qt[:QVBoxLayout](w)
w[:setLayout](lyt)

btn = Qt[:QPushButton]("Click me", w)
lyt[:addWidget](btn)

qconnect(btn, :clicked) do
  msg = Qt[:QMessageBox](btn)
  msg[:setWindowTitle]("A message for you...")
  msg[:setText]("Hello world!")
  msg[:setInformativeText]("Thanks for clicking.")
  msg[:setIcon](Qt[:QMessageBox]()[:Information]) # how to pick out Qt::QMessageBox::Informatino enumeration
  convert(Function, msg[:exec])()       # Must convert to a function
end

raise(w)


## Or in the qtextras style (not so different here)
w = Widget()
setWindowTitle(w, "Hello world example (redux)")
lyt = VBoxLayout(w)
setLayout(w, lyt)

btn = Button(w)
setText(btn, "Click me")
push!(lyt, btn)

qconnect(btn, :clicked) do
    println("Hi htere")
  MessageBox(btn, "Hi there", icon=:Information)
end

raise(w)
