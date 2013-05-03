Examples for the `PySide` package


* `hello-world.jl` simple hello world with window, button, callback
  and message dialog

* `signal-slot.jl` check the signals and slots work. Shows the
  `qconnect` function to slightly simplify interface

* `events.jl` Simple example of defining a new class so that we can
  implement event handlers, as opposed to just signal handlers.

* `data-frame.jl` Shows `DataFrameModel` for a simple to create model
  for large data sets.

* `workspace.jl` simple workspace browser.

* `webbrowser.jl` simple use of QtWebKit to embed a web page. This one
  creates a primitive command line/output area. It illustrates a
  mechanism to write from `julia` to `JavaScript` and back.

* `menu.jl` shows how to work with menus

* `timer.jl` shows the basic use of `QTimer`, as an alternate to `Base.TimeoutAsyncWork`

## We have several example related to plotting

* `manipulate.jl` an implementation of `RStudio`'s `manipulate`
  interface for `R` (a stripped down version of Mathematica's). Uses
  `Winston` as written, but that isn't necessary.

* `svg.jl` simple use showing `Gadfly` graphic in svg widget

* `d3.jl` An attempt (failed) to plot using `d3.js` and
  `QWebView`. This fails as the evaluation of of `JavaScript` passed
  from `julia` to `Qt` is really sluggish.

* `simple-plotting.jl` shows how a QGraphicsScene can be used for
  simple plotting

* `pyqtgraph.jl` creates `plot` function to use for graphing via
  `pyqtgraph` (http://www.pyqtgraph.org/). One could graph through
  `Python` with `matplotlib`, but this gives an alternative where
  embedding a plot device within a graphical framework is
  possible. The conversion from the `Python` code into `julia` is
  almost trivial (many `.meth` converted to `[:meth]`, change single
  quote to double, Python's `def` to `function`, replace `numpy` stuff
  with `julia`).

* `pyqtgraph-scatterplot.jl` shows the scatterplot demo from
  `pyqtgraph`. 

* `pyqtgraph-plot.jl` shows the plot demo from `pyqtgraph`.  The
  figure shows the result:


<img src="pyqtgraph-plot-ex.png"></img>
