---
permalink: /contrib/newmethod/
title: "Adding a new VBR core method"
toc: false 
---

To add a new method to the VBR core:

1. Open the corresponding parameter file in `vbr/vbrCore/params` and then:
  * add the new method name to the `params.possible_methods` cell array
  * add an `elseif` catch for the new method name
  * within the `elseif`, set `param.func_name` to the name of the matlab function that you will write for the new method, e.g.,
  ```
  param.func_name='new_vbr_method'
  ```
  * set any other values/parameters that the new method needs.

2. Create a new file in `vbr/vbrCore/functions` for your new function **with the name from `param.func_name`**. Using the above example, that would be `new_vbr_method.m`.

3. Write your new method function. The function must have the `VBR` struct as input and output:
```
function [VBR] = new_vbr_method(VBR)
```
The remainder of the function is where you write whatever calculations are appropriate. The VBR structure will come in with all the state variables and parameter values. State variables are accessed with, e.g., `VBR.in.SV.T` or `VBR.in.SV.phi`. The parameter values are accessed with `VBR.in.method_type.method_name` where `method_type` is the same as the parameter file that you modified (`anelastic`,`elastic` or `viscous`) and `method_name` is the name you added to `params.possible_methods`.

4. To return the results of your function, modify the `VBR.out` structure appropriately, e.g., ```VBR.out.method_type.method_name.result = result;```
where `method_type` is the same as the parameter file that you modified (`anelastic`,`elastic` or `viscous`) and `method_name` is the name you added to `params.possible_methods`

5. If your new method relies on other methods (e.g., you're putting in a new anelastic method that requires an elastic method to exist), you can add your method to `vbr/vbrCore/functions/checkInput.m` following the other methods already there.

To use your new method, simply add the new method name to the `methods_list`, before you call `VBRspine`, e.g.:
```
VBR.in.method_type.methods_list={'method_name'}
```
where `method_type` is `anelastic`,`elastic` or `viscous` and `method_name` is your new method.
