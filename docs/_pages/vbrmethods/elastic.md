---
permalink: /vbrmethods/elastic/
title: "Elastic Methods"
---

The elastic methods displayed by `vbrListMethods` currently include:

* `anharmonic`: anharmonic scaling
* `anh_poro`: poro-elastic scaling
* `SLB2005`: Stixrude and Lithgow‐Bertelloni (2005)

## `anharmonic`, anharmonic scaling

The anharmonic scaling calculates unrelaxed elastic moduli at elevated temperature and pressure, output is stored in `VBR.out.elastic.anharmonic`

## `anh_poro`, poro-elastic scaling

The poro-elastic scaling applies a correction for poro-elasticity on top of the anharmonic scaling. The scaling method follows Appendix A of Takei, 2002, "Effect of pore geometry on VP/VS: From equilibrium geometry to crack", JGR Solid Earth, [DOI](https://doi.org/10.1029/2001JB000522), output is stored in `VBR.out.elastic.anh_poro`.

## `SLB2005`, Stixrude and Lithgow‐Bertelloni (2005)

The `SLB2005` scaling is the relationship for upper mantle shear wave velocity directly from Stixrude and Lithgow‐Bertelloni (2005), "Mineralogy and elasticity of the oceanic upper mantle: Origin of the low‐velocity zone." JGR 110.B3, [DOI](https://doi.org/10.1029/2004JB002965). The method only uses the temperature and pressure arrays from `VBR.in.SV` and is not used by other methods. Output is `VBR.out.elastic.SLB2005.Vs`, the anharmonic velocity in km/s.
