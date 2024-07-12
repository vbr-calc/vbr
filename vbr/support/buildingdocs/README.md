Python scripts for building docs related markdown files. Not intended for wider use. These do not rely on anything outside the standard Python library (but probably does require Python 3.5ish+)

To generate docs: `cd` to this directory then run 

``` 
python buildExampleDocs.py
``` 

This will:

* build the `vbr_core_example` CB pages in `docs/_pages/examples`
* copy images from the `vbr_core_example` CB runs if they exist to `docs/assets/images/CBs`. Pre-existing images will be overwritten.

If you run with 

``` 
$ python buildExampleDocs.py 1 
```

then the `docs/_pages/examples` directory will be cleared out first.