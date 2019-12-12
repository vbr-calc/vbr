---
permalink: /vbrmethods/support/solliq/
title: ''
---

# SolLiquidus()

Calculates the peridite solidus with options for volatile dependence. Current options for the water dependence of the solidus are Katz [cite] or hirschmann [cite], CO2 dependence is from dasgupta [cite].

## documentation
```matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [Solidus] = SoLiquidus(P,H2O,CO2,solfit)
%
% calculates peridotite solidus and related properties
%
%
% Parameters
% ----------
% P         Pressure in Pa
% H2O       wt % of water in the melt phase
% CO2       wt % of CO2 in the melt phase
% solfit    which dry solidus to use, either 'katz' or 'hirschmann'
%
% Output
% ------
% Solidus.  structure with following fields
%        .Tsol       the effective solidus [C]
%        .Tsol_dry   the volatile free solidus [C]
%
% if using 'katz' parametrization, Solidus will also include:
%
% Solidus.
%        .Tliq   effective liquidus [C]
%        .Tlherz idealized lherzolite solidus [C]
%        .dTdPsol  productivity [C/GPa]
%        .dTdPlherz  lherzolite productivity [C/Gpa]
%        .dTdPliq  liquidis productivity [C/Gpa]
%        .dTdH2O   dependence of solidus on water content [C / wt %]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```

## Note on H2O and CO2 wt percent:

Note that the input H2O and CO2 to this function are the weight percent of the volatile in the melt phase.

## Example 
