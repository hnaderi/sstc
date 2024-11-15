import FreeCAD
import os.path

doc = FreeCAD.activeDocument()
base_filename = os.path.splitext(doc.FileName)[0]

for obj in doc.Objects:
    if len(obj.Parents)==0 and hasattr(obj, 'Shape'):
        filename = base_filename + "_" + obj.Label + ".stl"
        obj.Shape.exportStl(filename)
        FreeCAD.Console.PrintMessage(f"Exported {filename}\n")
