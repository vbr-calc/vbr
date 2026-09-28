---
permalink: /vbrmethods/elastic/
title: 'Elastic Methods'
toc: false
---

The elastic methods displayed by `VBR_list_methods` currently include:

* `anharmonic` [documentation]({{ '/vbrmethods/el/anharmonic/' | relative_url }}): anharmonic scaling
* `anh_poro` [documentation]({{ '/vbrmethods/el/anhporo/' | relative_url }}): poro-elastic scaling
* `SLB2005` [documentation]({{ '/vbrmethods/el/slb2005/' | relative_url }}): Stixrude and Lithgow‐Bertelloni (2005)

Parameters can be set by setting any of the appropriate fields of `VBR.in.elastic.(method_name).fieldtoset` where `(method_name)` is one of the above methods.
