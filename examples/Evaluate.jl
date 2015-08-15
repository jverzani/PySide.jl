module Evaluate

import Base.start, Base.next, Base.done, Base.strip
export parseit, exec_cmd


# A special module in which a documents code is executed.
module WeaveSandbox
    # Replace OUTPUT_STREAM references so we can capture output.
    OUTPUT_STREAM = IOBuffer()
    print(x) = Base.print(OUTPUT_STREAM, x)
    println(x) = Base.println(OUTPUT_STREAM, x)
end


# An iterator for the parse function: parsit(source) will iterate over the
# (cmd, expressions) in a string.
type ParseIt
    value::String
end

parseit(value::String) = ParseIt(value)
start(it::ParseIt) = 1
function next(it::ParseIt, pos)
    (ex,newpos) = parse(it.value, pos)
    ((it.value[pos:(newpos-1)], ex), newpos)
end
done(it::ParseIt, pos) = pos > length(it.value)

## Execute a julia command returning (result, output_stream) tuple
function exec_cmd(expr)
    result = eval(WeaveSandbox, expr)
    
    seek(WeaveSandbox.OUTPUT_STREAM, 0)
    output = takebuf_array(WeaveSandbox.OUTPUT_STREAM)
    truncate(WeaveSandbox.OUTPUT_STREAM, 0)
    (result, output)
end



end
