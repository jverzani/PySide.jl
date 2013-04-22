require("PyCall")


module PySide

##################################################
## initialize
using PyCall
using Mustache


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
## include("data-frame-model.jl")  ## XXX uncomment, but loads in DataFrames, so slow...

export Qt, QtCore, QtSvg, QtWebkit
export qconnect, qemit, qcall, qt_enum
export qexec
export qnew_class, qnew_class_instance, qset_method
export qinvoke
export get_value, set_value, get_items, set_items, change_slot
export Icon, Label, PushButton, Button, 
       Slider, SpinBox,
       LineEdit, TextEdit,   
       CheckBox, RadioButton, RadioGroup,
       ComboBox,
       MainWindow, DockWidget, Widget,
       VBoxLayout, HBoxLayout, FormLayout, GridLayout,
       TabWidget, StackedLayout, Splitter,
       ButtonGroup, GroupBox

#export Views...

export StandardItemModel
#export DataFrameModel ## XXX

export windowTitle, setWindowTitle, 
       text,setText,
       toPlainText, setPlainText,
       html, setHtml,
       setPlaceholderText,
       value, setValue,       
       setIcon,        
       setLayout,      
       addWidget, addLayout, addTab, addRow, insertRow, setWidget,
       setCentralWidget,
       setOrientation

export setFocus, raise 
















## from gtk_doevent, tk_doevent pattern
global initialized = false
function init()
    global initialized
    if initialized
        println("Already initialized PySide")
        return()
    end

    initialized = true
    app = Qt.QApplication(sys.argv)

    qt_doevent(::Int32) = qt_doevent()
    function qt_doevent()
        app[:processEvents]()
    end
    
    global timeout
    timeout = Base.TimeoutAsyncWork(qt_doevent)
    Base.start_timer(timeout,int64(20),int64(20))
end


init()
end
