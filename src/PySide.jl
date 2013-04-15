require("PyCall")


module PySide

##################################################
## initialize
using PyCall
using Mustache


## 
#@pyimport PySide ## need new name if this is needed
@pyimport PySide.QtGui as  Qt
@pyimport PySide.QtCore as QtCore
@pyimport PySide.QtSvg as QtSvg
@pyimport PySide.QtWebKit as QtWebKit
@pyimport sys

export Qt, QtCore, QtSvg, QtWebkit
export qconnect, qemit, qcall, qt_enum
export raise, qexec
export qnew_class, qnew_class_instance, qset_method



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

include("utils.jl")

init()
end
