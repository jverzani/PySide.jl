using DataFrames
using PySide

## Test DataFrameModel.

## test roles
d = DataFrame(x=[randstring(10) for i in 1:10],
              x__ToolTipRole = [randstring(10) for i in 1:10],
              x__BackgroundRole= rep("yellow", 10),
              y = 1:10
              )

w = Widget()
lyt = VBoxLayout(w)
setLayout(w, lyt)


view = TableView(w)
push!(lyt, view)

m = DataFrameModel(d, view)
setModel(view, m)
              
## test scaling
n = 10^5
d1 = DataFrame(x = randn(n),
              y = 1:n)


view = TableView(w)
push!(lyt, view)

m = DataFrameModel(d1, view, editable=true)
setModel(view, m)

raise(w)

             
              
