using DataFrames
n = 10^3                                #  this is slow!!!
d = DataFrame(x = randn(n), y = 1:n)


w = Widget()
setWindowTitle(w, "View a data frame")

lyt = VBoxLayout(w)
setLayout(w, lyt)

## This is really slow for large data sets, but works fine at this scale (2000 items)
## for large data sets the DataFrameModel can be used.

m = StandardItemModel(w)
## currently no set_items method to populate from a data frame, so we
## do it at the Qt level
for row in 1:nrow(d), col in 1:ncol(d)
    Qt[:QStandardItem](string(d[row, col])) | item -> m[:setItem](row-1, col-1, item)
end

view = TableView(w)
setModel(view, m)
addWidget(lyt, view)

## Some adjustments for non-exported functions
view[:setAlternatingRowColors](true)
header = view[:horizontalHeader]()
header[:setStretchLastSection](true)


raise(w)
