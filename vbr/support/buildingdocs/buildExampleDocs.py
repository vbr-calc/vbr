'''
script for building /docs/_pages/examples/
'''
from doc_builder import converter
import sys

if __name__ == "__main__":

    if len(sys.argv) > 1:
        clear_dir = bool(sys.argv[1])
    else:
        clear_dir = False

    # rebuild the cookbook examples
    CBwalker=converter.CBwalker()
    CBwalker.walkDir(clearTargetDir=clear_dir)

    converter.sync_release_notes()
    converter.sync_support_functions()
