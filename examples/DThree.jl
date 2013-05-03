module DThree

 export I, @I_str, D3

using JSON
using PyCall
using PySide
using Mustache

tpl = Mustache.template_from_file(Pkg.dir("PySide", "tpl", "d3.html"))


type AsIs
    x
end
I(x) = AsIs(x)
macro I_str(x)
    I(x)
end

## Take a function, get its args as array of symbols. There must be better way...
## Helper functions for bind callback
function get_args(li::LambdaStaticData)
    e = li.ast
    if !isa(e, Expr)
        e = Base.uncompressed_ast(li)
    end
    argnames = e.args[1]
    ## return array of symbols -- not args
    if isa(argnames[1], Expr)
        argnames = map(u -> u.args[1], argnames)
    end

    argnames
end

function get_args(m::Method)
    li = m.func.code
    get_args(li)
end

function get_args(f::Function)
    try
        get_args(f.env.defs.func)
    catch e
        get_args(f.code)
    end
end


## figure out how to make [0, I"d3.max(data)] -> [0, d3.max(data)]
## tojson(x::Any) = to_json(x)
## tojson(x::AsIs) = string(x.x)
## tojson(x::Tupe) = to_json([tojson(x) for x in x])

prep(d3, x::Any) = to_json(x)
prep(d3, x::AsIs) = string(x.x)
function prep(d3, f::Function)
    ## much trickier. We have julia object pushed into webpage which callback to this function
    julia = qnew_class_instance("Julia")
    qconnect(julia, :evaluate, (args...) -> f(args...))
    nm = randstring(10)
    d3.web[:page]()[:currentFrame]()[:addToJavaScriptWindowObject](nm, julia)
    args = join(map(string, get_args(f)), ", ")
    "function($args) {$nm.evaluate($args)}"
end

## D3 instances can chain commands with interface nearly same as d3.js
## d3.selectAll("p").style("color","#00f").render()
## render passes JavaScript to browser. If you want to assign to variable name, pass as argument.
## If method not defined, then can do something like d3._(:selectAll, "p"). ...
## by default this uses JavaScript d3 object as receiver. This can be changed with d3.receiver("chart"). ...
## arguments are converted via to_json, except:
## * functions are treated as callbacks into julia. These are asynchronous.
## * use I"x" or I("x") to treat object "as is". This is needed to quote JavaScript functions
## TODO: PyCall this baby so members can be added from a list of symbols
type D3
    web
    cmd
    loaded
    receiver
    eval_js
    render
    _
    select
    selectAll
    data
    enter
    append
    style
    attr
    text
    domain
    range
    scale_linear
    svg_axis
    scale
    ticks
    orient
    call
    max
    function D3(parent::PyCall.PyObject, style::String,dataset::String)
        web = PySide.QtWebKit.QWebView(parent)
        this = new(web, "d3", false)        

        tmp = tempname() * ".html"

        io = open(tmp, "w")
        Mustache.render(io, tpl, {:style => style, :dataset=>dataset})
        close(io)

        
        qconnect(web, :loadFinished, (bool) -> this.loaded = bool)
        qinvoke(web, :load, QtCore.QUrl("file:///" * tmp))
        

        this.receiver = (value) -> begin this.cmd = value; this end
        this.eval_js = (value) -> begin
            println(value)
            ## a bit kludgey, making sure page is loaded before evaluating
            if this.loaded
                this.web[:page]()[:currentFrame]()[:evaluateJavaScript](value)
                return(nothing)
            else
                ctr, max_steps = 1, 100
                timer = QtCore.QTimer()
                qconnect(timer, :timeout) do
                  ctr += 1
                  if this.loaded
                      timer[:stop]()
                      this.web[:page]()[:currentFrame]()[:evaluateJavaScript](value)
                  elseif ctr > max_steps
                      println("Failed to load page?")
                      timer[:stop]()
                  else
                      println(ctr)
                  end
                  return(nothing)
                end
                timer[:start](50)
            end
        end
        this.render = (args...) -> begin
            if length(args) > 0
                this.cmd = "var " * args[1] * " = " * this.cmd
            end
            this.eval_js(this.cmd)
            this.receiver("d3")
            nothing
        end
        this._ = (meth, args...) ->  begin
            args = map(u -> prep(this, u), args)
            args = join(args, ", ")
            cmd = this.cmd
            this.cmd = "$(this.cmd).$meth($args)"
            this
        end
        ## generate in @eval map meth by replacing _ with symbol(replace("scale_linear", "_", "."))
        this.select    = (args...) -> this._(:select, args...)
        this.selectAll = (args...) -> this._(:selectAll, args...)
        this.data      = (args...) -> this._(:data, args...)
        this.enter     = (args...) -> this._(:enter, args...)
        this.append    = (args...) -> this._(:append, args...)
        this.style     = (args...) -> this._(:style, args...)
        this.attr      = (args...) -> this._(:attr, args...)
        this.text      = (args...) -> this._(:text, args...)
        this.domain    = (args...) -> this._(:domain, args...)
        this.range     = (args...) -> this._(:range, args...)
        this.scale_linear = (args...) -> this._("scale.linear", args...)
        this.svg_axis  = (args...) -> this._("svg.axis", args...)
        this.scale     = (args...) -> this._(:scale, args...)
        this.ticks     = (args...) -> this._(:ticks, args...)
        this.orient    = (args...) -> this._(:orient, args...)
        this.call      = (args...) -> this._(:call, args...)
        this.max       = (args...) -> this._(:max, args...)

        this
    end
    D3(parent::PyCall.PyObject, dataset::String) = D3(parent, "", dataset)
end

end ## module
