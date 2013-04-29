## Example of menus with Qt
## add a top-level menu and submenu to which we add
## action, checkable action, radio-actions, separators
## and a popup menu

using PySide

w = Widget()
setWindowTitle(w, "Menu example")
lyt = VBoxLayout(w)
btn = Button(w, "Click for popup")
setLayout(w, lyt); push!(lyt, btn)

## main menubar
mb = MenuBar(w)


## add subment
submenu = Menu("File", mb)
addMenu(mb, submenu)

## add action
act = Action("Action", w)
change_slot(act, () -> print("action triggered"))
addAction(submenu, act)


## add action with icon
act = Action("Icon",  w)
setIcon(act, Icon("/tmp/julia.gif"))   # nothing on the Mac
change_slot(act, () -> print("icon action"))
addAction(submenu, act)


## add separator
addSeparator(submenu)

## add checkbutton
cb = Action("checkable", w)
cb[:setCheckable](true)
change_slot(cb, () -> println("checkable", cb[:isChecked]() ? "is checked" : "is not checked"))
addAction(submenu, cb)


## add separator
addSeparator(submenu)

## add radio group
ag = ActionGroup(w)
ag[:setExclusive](true)
rbs = [Action(i, w) for i in ["Regular", "Medium", "Large"]]
map(rbs) do i
  addAction(ag, i)
  addAction(submenu, i)
  i[:setCheckable](true)
end
rbs[1][:setChecked](true)
qconnect(ag, :triggered, (action) -> println(text(action)))


## do popup on obtn
popup = Menu(btn)
act = Action("fred", w)
change_slot(act, () -> print("fred"))
addAction(popup, act)

qconnect(btn, :customContextMenuRequested, (pt) ->  popup[:exec_](Qt.QCursor()[:pos]()))
btn[:setContextMenuPolicy](qt_enum("CustomContextMenu"))


raise(w)
