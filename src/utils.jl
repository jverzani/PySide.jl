## utility methods


XXX(msg) = println(msg); XXX() = XXX("define me")


function members(object::PyObject)
    convert(Vector{(String,PyObject)}, 
            pycall(PyCall.inspect["getmembers"], PyObject, object))
end
has_member(object::PyObject, key) = contains(pluck(members(object),1), key)


pluck(xs, key) = [ x[key] for x = xs ]

