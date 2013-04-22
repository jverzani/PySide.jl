## An example showing how the QtWebKit functionality can be used within julia
## This sets up two web view, one holding an editor and one for output
## The output command can be clicked on which calls back into julia to update the
## code in the editor.


module SG
using PySide

type SimpleGui
    block
    ace
    output
    function SimpleGui(parent)
        parent = PySide.project(parent)
        ace = PySide.QtWebKit.QWebView(parent)
        f = "file:///" * Pkg.dir("PySide", "tpl", "ace.html")
        qinvoke(ace, :load, QtCore.QUrl(f))

        output =  PySide.QtWebKit.QWebView(parent)
        f = "file:///" * Pkg.dir("PySide", "tpl", "output.html")
        qinvoke(output, :load, QtCore.QUrl(f))

        sp = Splitter("Vertical", parent)
        addWidget(sp, ace)
        addWidget(sp, output)
        new(sp, ace, output)
        end
end

function call_ace(x::SimpleGui, cmd, args)
    page = x.ace[:page]()
    frame = page[:currentFrame]()
    el = frame[:findFirstElement]("#editor")
    el[:evaluateJavaScript]("ace.edit('editor').$cmd($args)")
end

getValue(x::SimpleGui) = call_ace(x, "getValue", "")
setValue(x::SimpleGui, value::String) = call_ace(x, "setValue", "'$value', 0")
getSelection(x::SimpleGui) = call_ace(x, "getSelection", "")

function prependOutput(x::SimpleGui, txt)
    outel = x.output[:page]()[:currentFrame]()[:findFirstElement]("#output")
    outel[:prependInside](txt)
end
function execJsOutput(x::SimpleGui, cmd)
    if cmd == nothing return() end
    outel = x.output[:page]()[:currentFrame]()[:findFirstElement]("#output")
    outel[:evaluateJavaScript](cmd)
end

end

 ## using QtWebKit to make a simple interface
using Mustache, GoogleCharts, JSON
using PySide
reload(Pkg.dir("PySide", "examples", "evaluate.jl"))
using Evaluate
using SG


##
##################################################
prepare_out(x::Any) = ("<div class=\"alert alert-error\">$(x)</div>", nothing)
prepare_out(x::Nothing) = ("", nothing)
prepare_out(x::Function) = prepare_out(nothing)

function prepare_out(x::GoogleCharts.CoreChart)
    d = {:id => x.id, :width => 400, :height => 300, :chart_data => x.data,
          :chart_options => to_json(x.options), :chart_type => x.chart_type}
     (Mustache.render("<div id=\"{{:id}}\" style=\"width: {{:width}}px; height:{{:height}}px;\"></div>", d),
      Mustache.render("var {{:id}}_data = {{{:chart_data}}};var {{:id}}_options = {{{:chart_options}}};var {{:id}}_chart = new google.visualization.{{:chart_type}}(document.getElementById('{{:id}}'));{{:id}}_chart.draw({{:id}}_data,  {{:id}}_options);", d))
end

function eval_parsed_block(expr)
    ## warp Evaluate.exec_cmd in try/catch
    ## return ???
    try
        Evaluate.exec_cmd(expr)
    catch e
        ("Error: ($e)...", [])
    end
end


function eval_block()
    txt = SG.getValue(sg)
    println(txt)
    for (cmd, expr) in Evaluate.parseit(txt)
        result, output = eval_parsed_block(expr)
        println(result)
        (html, js) = prepare_out(result) # what to do with output (printed to STDOUT)
        SG.prependOutput(sg, html)
        SG.execJsOutput(sg, js)
        ## extra bit calls back into julia on a click event
        SG.prependOutput(sg, "<div style=\"cursor:hand;\" onClick=\"eval_julia(this);\"><code>$cmd</code></div>")
    end
    SG.setValue(sg, "")
end  



w = MainWindow()
setWindowTitle(w, "Simple GUI")
sg = SG.SimpleGui(w)
setCentralWidget(w, sg.block)


## ## Define some actions
## evaluate ... Qt.QKeySequence("Ctrl+X, Ctrl+C");
## reload ...
evaluate_action = Qt.QAction(PySide.project(w))
qinvoke(evaluate_action, :setText, "evaluate")
qinvoke(evaluate_action, :setShortcut, Qt.QKeySequence("Open")) ## This fails!!
qinvoke(evaluate_action, :setStatusTip, "Evaluate buffer contents")
qconnect(evaluate_action, :triggered, eval_block)

tb = Qt.QToolBar(PySide.project(w))
qinvoke(tb, :addAction, evaluate_action)
qinvoke(w, :addToolBar, tb)



## ## Integration of JavaScript -> julia
qnew_class("Julia", "QtCore.QObject", meths=[{:meth_dfn => "evaluate = QtCore.Signal(str)"}])
julia = qnew_class_instance("Julia")
qconnect(julia, :evaluate) do cmd
  SG.setValue(sg, cmd)
end




## How to call JavaScript from within Qt
## This sets up a function `eval_julia` for evaluating the contents of a div tag
## see the formatting of the output above
frame = sg.output[:page]()[:currentFrame]()
frame[:addToJavaScriptWindowObject]("julia", julia)
frame[:evaluateJavaScript]("window.eval_julia = function(self) {julia.evaluate(\$(self).text());}")



raise(w)


