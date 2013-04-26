using DataFrames
using PySide

## Test DataFrameModel.

## test roles
d = DataFrame(x=[randstring(10) for i in 1:10],
              x__ToolTipRole = [randstring(10) for i in 1:10],
              x__BackgroundRole= rep("yellow", 10),
              y = 1:10
              )
view = TableView()
m = DataFrameModel(d, view)
setModel(view, m)
raise(view)
              
## test scaling
n = 10^5
d = DataFrame(x = randn(n),
              y = 1:n)
        
view = TableView()
m = DataFrameModel(d, view, editable=true)
setModel(view, m)
raise(view)

             
              
