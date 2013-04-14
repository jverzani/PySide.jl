using DataFrames
n = 10^3                                #  this is slow!!!
d = DataFrame(x = randn(n), y = 1:n)


w = Qt.QWidget()
w[:setWindowTitle]("View a data frame")

lyt = Qt.QVBoxLayout(w)
w[:setLayout](lyt)

## This is really slow. Need to proxy to be effective.
m = Qt.QStandardItemModel(w)
for row in 1:nrow(d), col in 1:ncol(d)
    Qt.QStandardItem(string(d[row, col])) | item -> m[:setItem](row-1, col-1, item)
end

view = Qt.QTableView(w)
view[:setModel](m)
view[:setAlternatingRowColors](true)
lyt[:addWidget](view)

header = view[:horizontalHeader]()
header[:setStretchLastSection](true)


raise(w)
