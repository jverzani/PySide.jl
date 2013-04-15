using DataFrames
using PySide

## DataFrameModel Class
qnew_class("DataFrameModel", "QtCore.QAbstractTableModel")


## WE follow R's qtdataframe and embed roles into the data frame via
## column names so columns like x__DisplayRole, x__BackgroundRole,
## ... x__DecorationRole will have info looked up in.  we have issues
## storing the PyObjects in the data frame (they go out of scope when
## the view is shown) so instead you store strings that get mapped to
## pyobjects. E.g, for BackgrounRole a color name, for Decoration, a
## filename of an icon, ..
##
## Otherwise, we use these defaults:

display_role(x::DataArray, row::Int) = x[row]
display_role{T <: Real}(x::DataArray{T}, row::Int) = x[row]

text_alignment_role(x::DataArray, row::Integer) = convert(Int, qt_enum("AlignLeft"))
text_alignment_role{T <: Real}(x::DataArray{T}, row::Integer) = convert(Int, qt_enum("AlignRight"))

background_role(x::DataArray, row::Integer) = Qt.QBrush(Qt.QColor(0,0,0,0))
foreground_role(x::DataArray, row::Integer) = Qt.QBrush(Qt.QColor("black"))

tool_tip_role(x::DataArray, row::Integer) = nothing
whats_this_role(x::DataArray, row::Integer) = nothing

function make_role(r::String, value)
    ## some roles require us to do things
    if  r == "TextAlignmentRole"
        qt_enum(value)                  # "AlignRight"
    elseif r == "DecorationRole"
        Qt.QIcon(value)                 # filename
    elseif r == "BackgroundRole"
        Qt.QBrush(Qt.QColor(value))     # "blue"
    elseif r == "ForegroundRole"
        Qt.QBrush(Qt.QColor(value))
    else
        value
    end
end

function DataFrameModel(d; parent=nothing)
    m = qnew_class_instance("DataFrameModel")
    if !isa(parent, Nothing)
        m[:setParent](parent)
    end

    role_re  = r"__[a-zA-Z]+Role$"
    nms = filter(u -> !ismatch(role_re, u), colnames(d))

    m[:rowCount] = (index) -> nrow(d)
    m[:columnCount] = (index) -> length(nms)

    ## data property
## Qt::DisplayRole	0	The key data to be rendered in the form of text. (QString)
## Qt::DecorationRole	1	The data to be rendered as a decoration in the form of an icon. (QColor, QIcon or QPixmap)
## Qt::EditRole	2	The data in a form suitable for editing in an editor. (QString)
## Qt::ToolTipRole	3	The data displayed in the item's tooltip. (QString)
## Qt::StatusTipRole	4	The data displayed in the status bar. (QString)
## Qt::WhatsThisRole	5	The data displayed for the item in "What's This?" mode. (QString)
## Qt::SizeHintRole	13	The size hint for the item that will be supplied to views. (QSize)
## Qt::FontRole	6	The font used for items rendered with the default delegate. (QFont)
## Qt::TextAlignmentRole	7	The alignment of the text for items rendered with the default delegate. (Qt::AlignmentFlag)
## Qt::BackgroundRole	8	The background brush used for items rendered with the default delegate. (QBrush)
## Qt::BackgroundColorRole	8	This role is obsolete. Use BackgroundRole instead.
## Qt::ForegroundRole	9	The foreground brush (text color, typically) used for items rendered with the default delegate. (QBrush)
## Qt::TextColorRole	9	This role is obsolete. Use ForegroundRole instead.
## Qt::CheckStateRole	10	This role is used to obtain the checked state of an item. (Qt::CheckState)
## Qt::InitialSortOrderRole	14	This role is used to obtain the initial sort order of a header view section. (Qt::SortOrder). This role was introduced in Qt 4.8.


    function do_role(idx, role)
        ## role is Int64
                                  
        row = idx[:row]() + 1
        col = idx[:column]() + 1
        nm = nms[col]

        
        ## check the rol
        cnames = colnames(d)
        roles = ["DisplayRole", "EditRole", "TextAlignmentRole", "BackgroundRole", "ForegroundRole", "ToolTipRole", "WhatsThisRole"]
        function role_default(r, row, col)
            if r == "DisplayRole"
                display_role(d[:,col], row)
            elseif r == "EditRole"
                edit_role(d[:,col], row)
            elseif r == "TextAlignmentRole"
                text_alignment_role(d[:,col], row)
            elseif r == "BackgroundRole"
                background_role(d[:,col], row)
            elseif r == "ForegroundRole"
                foreground_role(d[:,col], row)
            elseif r == "ToolTipRole"
                tool_tip_role(d[:,col], row)
            elseif r == "WhatsThisRole"
                whats_this_role(d[:,col], row)
            else
                nothing
            end
        end
        for r in roles
            if role == convert(Int, qt_enum(r))
                role_name = nm * "__" * r
                out = (contains(cnames, role_name) ? make_role(r, d[row, role_name]) : role_default(r, row, nm))
                return(out)
            end
        end
        return(nothing)
    end
    m[:data] = do_role

    ## editable must implement setData(idx, value, role) and flags(idx) also headerData()
    ## Header data
    function header_data(section::Int, orient, role)
        if orient.o ==  qt_enum("Horizontal").o #  match pointers
            ## column, section is column
            role == convert(Int, qt_enum("DisplayRole")) ?  nms[section + 1] : nothing
        else
             role == convert(Int, qt_enum("DisplayRole")) ?  string(section + 1) : nothing
        end
    end
    m[:headerData] = header_data
            

    function flags(idx)
        if !idx[:isValid]() return(qt_enum("ItemIsEnabled")) end
        
        row = idx[:row]()
        col = idx[:column]() + 1
        qt_enum(["ItemIsSelectable", "ItemIsEditable"], how="|")
        qt_enum("NoItemFlags")

    end
    ## This isn't working, though not clear why not. The seleciton just gets messed up, but
    ## can't get editing to work
#    m[:flags] = flags 

    function set_data(idx, value, role)
        if !idx[:isValid]() return end

        row = idx[:row]() + 1
        col = idx[:column]() + 1
        nm = nms[col]

        println(role)
        d[row, col] = value

        m[:dataChanged][:emit](idx, idx)
        true
    end
    m[:setData] = set_data
    
    
    m
end

## return array of selected values in [row,col] format
function selected_inidices(view)
    sel_model = view[:selectionModel]()
    if !sel[:hasSelection]() return [] end

    idxs = sel[:selectedIndexes]()
    map(u -> [u[:row]() + 1, u[:column]() + 1], idxs)
end
    


## Test it out
testing = false
if testing
    ## test roles
    d = DataFrame(x=[randstring(10) for i in 1:10],
                  x__ToolTipRole = [randstring(10) for i in 1:10],
                  x__BackgroundRole= rep("yellow", 10),
                  y = 1:10
                  )
    view = Qt.QTableView()
    m = DataFrameModel(d, parent=view)
    view[:setModel](m)
    raise(view)

    ## test scaling
    n = 10^5
    d = DataFrame(x = randn(n),
                  y = 1:n)
        
    view = Qt.QTableView()
    m = DataFrameModel(d, parent=view)
    view[:setModel](m)
    raise(view)
end
             
              
