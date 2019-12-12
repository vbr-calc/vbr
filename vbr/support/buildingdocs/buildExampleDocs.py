'''
script for building /docs/_pages/examples/
'''
from doc_builder import converter

# rebuild the cookbook examples
CBwalker=converter.CBwalker()
CBwalker.walkDir()
