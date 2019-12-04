---
permalink: /vbrmethods/elastic/
title: "Elastic Methods"
---

The elastic methods displayed by `vbrListMethods` currently include:

* `anharmonic`: anharmonic scaling
* `anh_poro`: poro-elastic scaling
* `SLB2005`: Stixrude and Lithgow‐Bertelloni (2005)

Parameters can be set by setting any of the appropriate fields of `VBR.in.elastic.(method_name).fieldtoset` where `(method_name)` is one of the above methods

## `anharmonic`

The anharmonic scaling calculates unrelaxed elastic moduli at elevated temperature and pressure.

**Requires**:
* `VBR.in.SV.T_K` temperature in degrees K
* `VBR.in.SV.GPa` pressure in GPa

**Output** is stored in `VBR.out.elastic.anharmonic`

**Important parameters** are
* `VBR.in.elastic.anharmonic.T_K_ref`: reference temperature in K
* `VBR.in.elastic.anharmonic.P_Pa_ref`: reference temperature in Pa
* `VBR.in.elastic.anharmonic.Gu_0_ol`: reference unrelaxed olivine modulus in GPa at reference T, P.
* `VBR.in.elastic.anharmonic.dG_dT`: temperature dependence of modulus in Pa/K (or Pa/C).
* `VBR.in.elastic.anharmonic.dG_dP`: pressure dependence of modulus, unitless.

Default values for reference temperature and pressure are surface conditions.

Additionally, there is a parameter for a crustal modulus, `VBR.in.elastic.anharmonic.Gu_0_crust`. The unrelexed reference modulus is calculated as a linear mixture of `Gu_0_crust` and `Gu_0_ol` where the compositional fraction is set by `VBR.in.SV.chi`, with a value of 1 for pure olivine:

```matlab
Gu = Gu_0_ol .* VBR.in.SV.chi + (1-VBR.in.SV.chi) .* Gu_0_crust;
```
The main purpose of this scaling is to generate more realistic velocity profiles in the crust and uppermost mantle at low temperatures below where anelastic affects are negligible. If `VBR.in.SV.chi` is not set by the user, then  `VBR.in.SV.chi` is initialized to a value of 1 everywhere.

## `anh_poro`

The poro-elastic scaling applies a correction for poro-elasticity on top of the anharmonic scaling. The scaling method follows Appendix A of Takei, 2002, "Effect of pore geometry on VP/VS: From equilibrium geometry to crack", JGR Solid Earth, [DOI](https://doi.org/10.1029/2001JB000522).

**Requires**:
* `VBR.out.elastic.anharmonic` result of anharmonic calculation.
* `VBR.in.SV.phi` melt fraction or porosity (volume fraction)

**Output** is stored in `VBR.out.elastic.anh_poro`.

## `SLB2005`

The `SLB2005` scaling is the relationship for upper mantle shear wave velocity directly from Stixrude and Lithgow‐Bertelloni (2005), "Mineralogy and elasticity of the oceanic upper mantle: Origin of the low‐velocity zone." JGR 110.B3, [DOI](https://doi.org/10.1029/2004JB002965).

**Requires**:
* `VBR.in.SV.T_K` temperature in degrees K
* `VBR.in.SV.GPa` pressure in GPa

**Output** is `VBR.out.elastic.SLB2005.Vs`, theshear wave velocity in km/s.
