require("PyCall")


module PySide

##################################################
## initialize
using PyCall
using Mustache
using DataFrames

## 
@pyimport PySide.QtGui    as Qt
@pyimport PySide.QtCore   as QtCore
@pyimport PySide.QtSvg    as QtSvg
@pyimport PySide.QtWebKit as QtWebKit
@pyimport sys

import Base.getindex, Base.setindex!, Base.push!, Base.pop!, Base.delete!







include("utils.jl")
include("qtutils.jl")
include("qtextras.jl")
include("data-frame-model.jl")  ##  requires DataFrames, so slow to load...
include("pyqtgraph.jl")  

export Qt, QtCore, QtSvg, QtWebkit
export qconnect, qemit, qcall, qt_enum
export qexec
export qnew_class, qnew_class_instance, qset_method
export qinvoke
export get_value, set_value, get_items, set_items, change_slot
export get_width, get_height, get_size, set_size

## widgets/controls
export Icon, Pixmap, Label, PushButton, Button, 
       Slider, SpinBox,
       LineEdit, TextEdit,   
       CheckBox, RadioButton, RadioGroup,
       ComboBox,
       Action, ActionGroup, MenuBar, Menu,
       GraphicsScene, GraphicsView

## models
export StandardItemModel, DataFrameModel

## views
export TableView   

## container like
export MainWindow, DockWidget, Widget,
       VBoxLayout, HBoxLayout, FormLayout, GridLayout,
       TabWidget, StackedLayout, Splitter,
       ButtonGroup, GroupBox

## dialogs
export MessageBox, InputDialog, FileDialog

## methods
export windowTitle, setWindowTitle, 
       text,setText,
       toPlainText, setPlainText,
       html, setHtml,
       setPlaceholderText,
       value, setValue,
       setModel,
       setIcon, setPixmap, load,       
       setLayout,      
       addWidget, addLayout, addTab, addRow, insertRow, setWidget,
       addAction, addMenu, addSeparator,
       setCentralWidget,
       setOrientation

export setFocus, raise 






## use PyCall's start gui
pygui(:qt)
PyCall.eventloops[:qt] = PyCall.qt_eventloop("PySide", 50e-3)
app = Qt.QApplication(sys.argv)




end
