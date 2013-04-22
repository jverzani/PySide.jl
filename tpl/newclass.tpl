"""
Stub for making a new class
"""

import sys
from PySide import QtGui, QtCore

class {{:NewClass}}({{:OldClass}}):
    
    def __init__(self):
        super({{:NewClass}}, self).__init__()
        
    {{#:methods}}
    {{{:meth_dfn}}}
    {{/:methods}}
