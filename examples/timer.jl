## Qt has a QTimer class for calling values periodically.
## Here we illustrate its basic use.

## a timer instance
timer = QtCore.QTimer()

## add a callback
i = 1
qconnect(timer, :timeout) do
  global i
  i += 1
  i > 100 ? qinvoke(timer, :stop) : println(i)
end

qinvoke(timer, :start, 50)
