---
permalink: /gettingstarted/volatiles/
title: "On volatiles"
---

# Volatiles in the VBRc 

The impact of volatiles on rheological relationships is confusing and their 
implementation in the VBRc is correspondingly a little confusing. This 
page tries to lay out how volatiles concentrations are set and how and where 
they are used.

## State variable arrays 

Starting with the VBRc version 2.0.0, volatiles in the state variable arrays 
should have a `_s` and `_f` suffix to denote solid and liquid concentrations 
in PPM. Meaning: 

```matlab
VBR.in.SV.Ch2o_s = ... ;
VBR.in.SV.Ch2o_f = ... ; 
```
are the concentration of water in the solid phase and liquid phase, respectively
(with both in PPM!).

The core VBRc does not compute these concentrations for you! Depending on your 
application, you may want to set concentrations functionally based on a bulk 
water content and a porosity. 

## Using volatile arrays 

Core VBRc functionality will automatically convert concentration arrays between 
PPM and weight percent as needed, but manually calling some functions will 
require that you check the function help to see if you need to provide PPM or 
weight percent.

For example, `SoLiquidus` expects volatile concentrations in the fluid/melt phase 
in weight percent (run `help SoLiquidus` for more information).


## Volatiles and anelastic methods 

Whether or not volatiles impact anelastic outputs depends on the anelastic method
and the options used to call the method. 

