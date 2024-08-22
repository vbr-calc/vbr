# Tutorial 01 : Basic Usage


# Steps

## 1. Initializing the VBRc

```
vbr_path='~/src/vbr/';
vbr_path=getenv('vbrdir');
addpath(vbr_path)
vbr_init
```

## 2. Overview of the calculation

* the VBR structure

start by building a structure that specifies inputs:

```
VBR.in.
```

run the VBRc

```
[VBR] = VBR_spine(VBR) ;
```

inspect output

```
VBR.out.
```


* Setting the methods lists
to see implemented methods:

```
vbrListMethods
```

```
VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
VBR.in.viscous.methods_list={'HK2003';'HZK2011'};
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'};
```

* Setting the thermodynamic state
