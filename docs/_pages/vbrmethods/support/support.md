---
permalink: /vbrmethods/support/support/
title: "Additional functions"
toc: true
---

# Overview
This is a list of functions that you may find useful when using or developing the VBRc. Note to developers: this page is auto-generated from `vbr/vbr/support/buildingdocs/sync_support_functions.py`. 

## Density
functions related to calculating density
* [thermal_expansion_coefficient](#thermal_expansion_coefficient)
* [san_carlos_density_from_pressure](#san_carlos_density_from_pressure)
* [density_isothermal_compression](#density_isothermal_compression)
* [density_from_vbrc](#density_from_vbrc)
* [density_thermal_expansion](#density_thermal_expansion)
* [density_adiabatic_compression](#density_adiabatic_compression)

## Fitting and Statistics
functions related to fitting observations and probability distributions. Note that many of the functions related to probability distributions are available in  other MATLAB or GNU Octave toolboxes. The VBRc implemented its own versions to avoid the  need for 3rd party packages.
* [find_LAB_Q](#find_lab_q)
* [probability_lognormal](#probability_lognormal)
* [probability_uniform](#probability_uniform)
* [joint_independent_probability](#joint_independent_probability)
* [conditionally_independent_C_given_AB](#conditionally_independent_c_given_ab)
* [conditional_Bayes](#conditional_bayes)
* [probability_distributions](#probability_distributions)
* [probability_normal](#probability_normal)
* [likelihood_from_residuals](#likelihood_from_residuals)
* [priorModelProbs](#priormodelprobs)

## Other thermodynamic properties
functions related to other thermodynamic properties
* [adiabatic_coefficient](#adiabatic_coefficient)
* [adiabatic_gradient](#adiabatic_gradient)
* [SoLiquidus](#soliquidus)
* [ThermalConductivity](#thermalconductivity)
* [SpecificHeat](#specificheat)
* [sr_water_fugacity](#sr_water_fugacity)
* [Qinv_from_J1_J2](#qinv_from_j1_j2)
* [PiezometerWH2006](#piezometerwh2006)

## VBRc support
useful functions for the VBRc user
* [vbr_version](#vbr_version)
* [VBR_list_methods](#vbr_list_methods)
* [full_nd](#full_nd)
* [vbr_categorical_color](#vbr_categorical_color)
* [vbr_categorical_cmap_array](#vbr_categorical_cmap_array)
* [VBR_save](#vbr_save)

## Developer Support
functions that you may find useful for developing code
* [checkStructForField](#checkstructforfield)
* [get_nested_field_from_struct](#get_nested_field_from_struct)
* [nested_structure_update](#nested_structure_update)
* [is_octave](#is_octave)
* [varargin_keyvals_to_structure](#varargin_keyvals_to_structure)

# Full Docstrings

## Density: docstrings

### thermal_expansion_coefficient
path: `vbr/vbr/vbrCore/functions/density/thermal_expansion_coefficient.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % al_int = thermal_expansion_coefficient(T_K, FracFo, T_ref_K)
    %
    % calculates the thermal expansion coefficient at a given temperature and
    % volume fraction of forsterite following Xu et al., 2004
    %
    %
    % Parameters
    % ----------
    % T_K : scalar or array
    %     temperature in Kelvin
    % FracFo : scalar or array
    %     volume fraction of Forsterite
    % T_ref_K : optional scalar
    %     the reference temperature to use, default 273 K
    % Output
    % -------
    % al_int : scalar or array
    %     coefficient of thermal expansion
    %
    % References
    % ----------
    % Xu, Yousheng, et al."Thermal diffusivity and conductivity of olivine,
    % wadsleyite and ringwoodite to 20 GPa and 1373 K." Physics of the Earth
    % and Planetary Interiors 143 (2004): 321-336.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#density-docstrings)
[top of page!](#overview)

### san_carlos_density_from_pressure
path: `vbr/vbr/vbrCore/functions/density/san_carlos_density_from_pressure.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rho = san_carlos_density_from_pressure(P_GPa)
    %
    % calculates density of olivine at given pressure values
    % using an interpolation of Abramson et al 1997 (at Fo90)
    %
    %
    % Parameters
    % ----------
    % P_GPa: scalar or array
    %     the pressure(s) of interest in GPa
    %
    % Output
    % -------
    % rho : scalar
    %     density in kg/m3
    %
    % References
    % ----------
    % E. H. Abramson, J. M. Brown, L. J. Slutsky, J. Zaug, 1997,
    % The elastic constants of San Carlos olivine to 17 GPa,
    % JGR,  https://doi.org/10.1029/97JB00682
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#density-docstrings)
[top of page!](#overview)

### density_isothermal_compression
path: `vbr/vbr/vbrCore/functions/density/density_isothermal_compression.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rho = density_isothermal_compression(P_Pa, rho_0, K_o, dK_dP, P_Pa_ref)
    %
    % calculates density under isothermal compression for a bulk modulus with linear pressure dependence.
    %
    % Parameters
    % ----------
    % P_Pa: scalar or array
    %   pressure in Pa. if array must be same size as other arrays
    % rho_0: scalar or array
    %   reference density in any units. if array must be same size as other arrays
    % K_o: scalar or array
    %   reference bulk modulus in Pa. if array must be same size as other arrays
    % dK_dP: scalar
    %   anharmonic pressure derivative of bulk modulus in Pa/Pa
    % P_Pa_ref: scalar
    %   reference pressure in Pa
    %
    % Returns
    % -------
    % rho: scalar or array
    %   the density at supplied pressure, same units as input rho_0.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#density-docstrings)
[top of page!](#overview)

### density_from_vbrc
path: `vbr/vbr/vbrCore/functions/density/density_from_vbrc.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rho_TP = density_from_vbrc(P_Pa, T_K, varargin)
    %
    % calculates a temperature and pressure dependent density in two steps:
    %    1. pressure correction: isothermal compression with a bulk modulus with linear pressure dependence.
    %    2. thermal correction: isobaric thermal expansion
    %
    % Parameters
    % ----------
    %
    % P_Pa : array
    %   pressure array in Pa, must be the same shape as T_K
    % T_K : array
    %   temperature array in degrees K, must be the same shape as P_Pa
    % varargin : optional key-value pairs. Possible pairs include:
    %
    %   'reference_scaling', string
    %       The name of the reference scale to use in the parameter structure.
    %       defaults to 'default'.
    %   'params_elastic', structure
    %       The anharmonic parameter structure to use, defaults to Params_Elastic('anharmonic').
    %       Any entry here will be merged with the default structure (with preference given to
    %       the user supplied values)
    %   'rho_o', float
    %       The reference density in kg/m^3. If not set, then will use either the reference scaling if it
    %       has a 'rho_ref' field or 3300 kg/m^3 if it does not. May be an array, in which case it must
    %       match the shape of P_Pa and T_K.
    %   'pressure_scaling, string
    %       the name of the pressure scaling to use. Defaults to the value of the value in
    %       params_elastic.pressure_scaling if it exists, otherwise uses the default in the
    %       Params_Elastic('anharmonic') structure.
    %
    % Examples
    % --------
    %
    % T_K = linspace(800, 1500, 100);
    % P_Pa = linspace(2,3, 100) * 1e9;
    %
    % % use the built in upper mantle scaling:
    % rho_TP = density_from_vbrc(P_Pa, T_K, 'reference_scaling', 'upper_mantle', 'pressure_scaling', 'upper_mantle')
    %
    % % use the default scaling, provide a reference density (defined at the default reference pressure):
    % rho_TP = density_from_vbrc(P_Pa, T_K, 'rho_o', 3310)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#density-docstrings)
[top of page!](#overview)

### density_thermal_expansion
path: `vbr/vbr/vbrCore/functions/density/density_thermal_expansion.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [rho] = density_thermal_expansion(rho, T_K, FracFo, T_ref_K)
    %
    % Corrects density for thermal expansion at fixed pressure
    %
    % Parameters
    % ----------
    % rho : scalar or array
    %     density in any units
    % T_K : scalar or array
    %     temperature in Kelvin
    % FracFo : scalar or array
    %     volume fraction of Forsterite
    % T_ref_K : optional scalar
    %     the reference temperature to use, default 273 K
    % Output
    % -------
    % rho : scalar or array
    %     density in same units as input density
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#density-docstrings)
[top of page!](#overview)

### density_adiabatic_compression
path: `vbr/vbr/vbrCore/functions/density/density_adiabatic_compression.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [Rho,P] = density_adiabatic_compression(Rho_o,Z,P0)
    %
    % Adiabatic Compression along a profile following Turcotte and Schubert
    % should be ok for upper mantle, shallower than the 410 km phase change.
    %
    % Parameters
    % ----------
    % Rho_o
    %     reference density in kg/m^3
    % Z
    %     depth in m
    % P0
    %     reference pressure in Pa
    %
    % Output
    % -------
    % [Rho, P]
    %    Rho : adiabatic-corrected density in kg/m^3
    %    P   : pressure profile in Pa
    % see page ~190 in 1st edition, 185 in 2nd edition.                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#density-docstrings)
[top of page!](#overview)

## Fitting and Statistics: docstrings

### find_LAB_Q
path: `vbr/vbr/fitting/find_LAB_Q.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % finds seismic LAB using Q. LAB defined either as an absolute value of Q or
    % as the depth where Q = Q_factor * ave Asthenosphere Q.
    % Reminder low Q = high attenuation (Q^-1), so LAB Q will be > astheno Q.
    %
    % Parameters
    % ----------
    % Q_z: 1d array
    %     Q as a function of z
    % Z_km: 1d array
    %     depth, same size as Q_z
    % varargin: optional key-value arguments
    %
    %     'method', 'Q_factor' or 'Q_value'
    %       if 'Q_factor' (the default), the LAB is identified as the point closest to
    %       where Q_z equals a factor above the asthenosphere mean Q.
    %       if 'Q_value', the LAB is identified as the point closes to the
    %       supplied Q value.
    %     'value', scalar
    %       if 'method'=='Q_factor', this is the factor that multiplies the
    %       asthenosphere Q to find the target LAB Q (default 20).
    %       if 'method'=='Q_value', this is the target LAB Q to find.
    %     'z_min_km', scalar
    %       only used if 'method'=='Q_factor`, this value (default 80 km) defines the
    %       depth above which Q values are averaged to find the mean asthenosphere Q
    %
    % Returns
    % -------
    % Z_LAB_Q: scalar
    %     the seismic LAB depth from Q.
    %
    % Examples
    % --------
    % The following finds the depth at which Q is a factor of 20 higher than the
    % mean asthenospheric Q. The mean asthenospheric Q will be calculated by
    % averaging Q_z at depths greater than 150 km ('z_min', 150):
    %
    %    Z_LAB_Q = find_LAB_Q(Q_z,Z_km,'method','Q_factor','value',20,'z_min_km',150)
    %
    % To find the depth closest to an absolute value of Q:
    %
    %    Z_LAB_Q = find_LAB_Q(Q_z,Z_km,'method','Q_value',800)
    %
    % Notes
    % -----
    % Default behavior is to use
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### probability_lognormal
path: `vbr/vbr/fitting/probability_lognormal.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % lognormal_pdf = probability_lognormal(x, mu, sigma)
    %
    % Calculate the probability of having an observed value x given
    % a log normal distribution with mean mu and standard deviation sigma.
    %
    % Parameters
    % ----------
    % x: scalar
    %   observed value(s), must be dimensionless and > 0.
    % mu: scalar
    %   mean value of distribution in log-space
    % sigma: scalar
    %   standard deviation of the distribution in log-space
    %
    % Returns
    % -------
    % lognormal_pdf: array
    %   prior probability of being at the observed value
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### probability_uniform
path: `vbr/vbr/fitting/probability_uniform.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % uniform_pdf = probability_uniform(x, min_val, max_val)
    %
    % Calculate the probability of having an observed value x given
    % a uniform distribution between min_val and max_val.
    % (The same as unifpdf in the stats package).
    %
    %
    % Parameters
    % ----------
    % x: array
    %   observed value(s)
    % min_val: scalar
    %   minimum for uniform distribution
    % max_val: scalar
    %   maximum for uniform distribution
    %
    % Returns
    % -------
    % uniform_pdf: array
    %   prior probability of being at the observed value
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### joint_independent_probability
path: `vbr/vbr/fitting/joint_independent_probability.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % joint_independent_pdf = joint_independent_probability(marginals)
    %
    % Calculate the joint probability (assuming independent) of two or more
    % marginal probabilities, {p(A), p(B), ...}.  As we are assuming all
    % of these are independent, this is a simple product.
    %
    %
    % Parameters
    % ----------
    %  marginals: cell array
    %    A cell array containing the marginal probabilities p(A), p(B), etc.
    %    All marginal probabilities must be the same size.
    %
    % Returns
    % -------
    % joint_independent_pdf: array
    %     joint independent probability, p(A, B , ...)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### conditionally_independent_C_given_AB
path: `vbr/vbr/fitting/conditionally_independent_C_given_AB.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % p_C_given_AB = conditionally_independent_C_given_AB( ...
    %    p_A_given_C, p_B_given_C, p_C, p_A_and_B)
    %
    % Calculate the conditional probability of C given A and B, assuming that
    % A and B are dependent but conditionally independent given C
    % As such, we can calculate:
    %           P(C | A, B) = P(A, B, C) / P(A, B)
    %                       = P(A, B | C) P(C)  /  P(A, B)
    %                       = P(A | C) P(B | C) P(C) / P(A, B)
    %
    % Parameters
    % ----------
    % p_A_given_C: array | scalar
    %     conditional probability of A given C
    % p_B_given_C: array | scalar
    %     conditional probability of B given C
    % p_C: array | scalar
    %     prior probability of C
    % p_A_and_B: array | scalar
    %     joint probability of A and B
    %     Note that A and B are dependent (but only conditionally independent
    %     given C!) so p(A, B) != p(A) * p(B)
    %
    % Returns
    % -------
    % p_C_given_AB: array | scalar
    %     conditional probability of C given both A and B
    %
    % Note: ALL inputs and outputs should be the same size (or scalars).
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### conditional_Bayes
path: `vbr/vbr/fitting/conditional_Bayes.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % p_A_given_B = conditional_Bayes(p_B_given_A, p_A, p_B)
    %
    % Calculate the conditional probability using Bayes' Theorem:
    %       p(A | B) = p(B | A) * p(A) / p(B)
    %
    %
    % Parameters
    % ----------
    % p_B_given_A: array | scalar
    %     probability of B given A (likelihood)
    % p_A: array | scalar
    %     prior probability of A
    % p_B: array | scalar
    %     prior probability of B
    %
    % Returns
    % -------
    % p_A_given_B: array | scalar
    %     posterior probability of A given B
    %
    % Note: ALL inputs and outputs should be the same size (or scalars).
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### probability_distributions
path: `vbr/vbr/fitting/probability_distributions.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % pdf = probability_distributions(distribution_flag, varargin)
    %
    % Calculates probability in a Bayesian sense given constraints.
    %
    % Parameters
    % ----------
    % distribution_flag:   string
    %   A string that specifies the calculation to be done options are:
    %        Evaluate a distribution, supply one of:
    %            'normal', 'uniform', 'lognormal'
    %        Calculate a probability given other constraints, provide:
    %            'likelihood from residuals'
    %        Combining pdfs, provide one of:
    %            'joint independent'
    %            'A|B'
    %            'C|A,B conditionally independent'
    %
    %  varargin: parameters describing the distribution, values depend on
    %    the distribution flag value.
    %
    %    When evaluating distributions:
    %       'normal'    - {x*, mean, standard deviation}
    %       'uniform'   - {x*, min, max}
    %       'lognormal' - {x*, mean, standard deviation}
    %    where
    %       x: matrix
    %           values of random variable for which to find the probability
    %           in the given pdf
    %    expected varargin values for the other distribution_flag
    %    values are:
    %       'likelihood from residuals' - {obs val, obs std, predicted}
    %       'joint independent' - {marginal p_A, p_B, ...}
    %        'A|B' - {p_B_given_A, p_A, p_B}
    %        'C|A,B conditionally independent' - {p_A_given_C, p_B_given_C,
    %                                             p_C, p_A_and_B}
    %
    % Returns
    % ------
    % pdf: matrix
    %   probability for each of the values in x
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### probability_normal
path: `vbr/vbr/fitting/probability_normal.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % normal_pdf = probability_normal(x, mu, sigma)
    %
    % Calculate the probability of having an observed value x given
    % a normal distribution with mean mu and standard deviation sigma.
    % (The same as normpdf in the stats package).
    %
    % Parameters
    % ----------
    % x: array
    %   observed value(s), must be dimensionless and > 0.
    % mu: scalar
    %   mean value of distribution in log-space
    % sigma: scalar
    %   standard deviation of the distribution in log-space
    %
    % Returns
    % -------
    % normal_pdf: array
    %   prior probability of being at the observed value
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### likelihood_from_residuals
path: `vbr/vbr/fitting/likelihood_from_residuals.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % pdf = likelihood_from_residuals(obs_val, obs_std, predicted_vals)
    %
    % Calculate the likelihood (pdf) of the observed value at each of the given
    % combination of state variables by comparing the observed value to the
    % calculated value, scaled by the observed standard deviation.
    %
    % The likelihood p(D|A), e.g., P(Vs | T, phi, gs), is calculated using
    % the residual (See manual, Menke book Ch 11):
    %       p(D|A) = 1 / sqrt(2 * pi * residual) * exp(-residual / 2)
    % residual(k) here is a chi-squared residual. Given chi-square, the PDF
    % of data with a normal distribution:
    %       P = 1 / sqrt(2 * pi * sigma^2) * exp(-0.5 * chi-square)
    % where sigma = std of data, chi-square=sum((x_obs - x_preds)^2 / sigma^2)
    % e.g. www-cdf.fnal.gov/physics/statistics/recommendations/modeling.html
    %
    % Parameters:
    % -----------
    % obs_val
    %     observed (seismic) property
    % obs_std
    %     standard deviation on the observed value
    % predicted_vals
    %     (size(parameter sweep)) matrix of calculated values
    %     of the observed property at each of the different
    %     parameter sweep combinations. i.e.,
    %           size(parameter_sweep) = size(sweep.Box)
    % Output:
    % -------
    % likelihood
    %       (size(parameter sweep)) matrix of the probability of the
    %       observation for each of the proposed parameter (state variable)
    %       combinations - the LIKELIHOOD.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

### priorModelProbs
path: `vbr/vbr/fitting/priorModelProbs.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % [Prior_mod, sigmaPreds] = priodModelProbs( ...
    %       States, states_fields, ifnormal)
    %
    % Loop over the fields in States and calculate probabilities for each field
    % to get total prior model pdf.  Each field (listed in states_fields) is
    % a state variable name that we are varying.
    %
    % Assuming that the state variables are all independent of each other
    %   p(var1, var2, ...) = p(var1) * p(var2) * ...
    %
    % Parameters
    % ----------
    % states: structure
    %   A structure with the following fields for each state in the
    %   list states_fields:
    %    [field] : matrix
    %       matrix of size (n_var1, n_var2, n_var3 ...) for all values of that
    %       state variable
    %    [field]_mean : scalar
    %       mean (expected value) for that variable
    %    [field]_std : scalar
    %       standard deviation for that variable
    %    [field]_pdf_type : string (optional)
    %       If set, this is the PDF type to use (optional), must be one of
    %       'normal', 'lognormal', 'uniformlog' or 'uniform'. This
    %        option is overridden by the following field if it exists.
    %    [field]_pdf : matrix (optional)
    %       If there is a field [var_name]_pdf, then use that probability
    %       as the prior for that variable instead of calculating it
    %
    % states_fields: cell array
    %    names of all of the state variables we are varying. Each field name
    %    should exist in the states structure.
    %
    % Returns
    % -------
    % [Prior_mod, sigmaPreds]
    %   Prior_mod
    %       joint probability of all combinations of the state variables
    %   sigmaPreds
    %       joint standard deviation for all combinations of the state variables
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#fitting-and-statistics-docstrings)
[top of page!](#overview)

## Other thermodynamic properties: docstrings

### adiabatic_coefficient
path: `vbr/vbr/vbrCore/functions/thermal_properties/adiabatic_coefficient.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dTdP_s = adiabatic_coefficient(T_K, rho, FracFo)
    %
    % calculates the adiabatic coefficient (dT/dP at constant
    % entropy) given temperature and density
    %
    % Parameters
    % ----------
    % T_K
    %     temperature in K
    % rho
    %     density in kg/m^3
    % FracFo
    %     volume fraction forsterite
    %
    % Output
    % -------
    % dTdP_s
    %     adiabatic coefficient in K/Pa
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#other-thermodynamic-properties-docstrings)
[top of page!](#overview)

### adiabatic_gradient
path: `vbr/vbr/vbrCore/functions/thermal_properties/adiabatic_gradient.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dTdz_s = adiabatic_gradient(T_K, rho, FracFo)
    %
    % calculates the adiabatic gradient (dT/dz at constant
    % entropy) given temperature and density for the upper
    % mantle (g = 9.8 m/s^2)
    %
    % Parameters
    % ----------
    % T_K
    %     temperature in K
    % rho
    %     density in kg/m^3
    % FracFo
    %     volume fraction forsterite
    %
    % Returns
    % -------
    % dTdz_s
    %     adiabatic gradient in K/m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#other-thermodynamic-properties-docstrings)
[top of page!](#overview)

### SoLiquidus
path: `vbr/vbr/vbrCore/functions/thermal_properties/SoLiquidus.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [Solidus] = SoLiquidus(P_Pa,H2O,CO2,solfit)
    %
    % calculates peridotite solidus with volatile dependence. Water depression
    % calculated with Katz et al (2003), CO2 depression calculated with
    % Dasgupta et al (2007). Effects are cumulative. The dry solidus
    % to which the depression is applied can be calculated using either
    % Katz et al (2003) or Hirschmann (200).
    %
    % Parameters
    % ----------
    % P_Pa         Pressure in Pa
    % H2O       wt % of water in the melt phase
    % CO2       wt % of CO2 in the melt phase
    % solfit    which dry solidus to use, either 'katz' or 'hirschmann'
    %
    % Returns
    % -------
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
    %
    % References
    % ----------
    %
    % Dasgupta, R., Hirschmann, M. M., & Smith, N. D. (2007). Water follows carbon:
    %   CO2 incites deep silicate melting and dehydration beneath mid-ocean ridges.
    %   Geology, 35(2), 135-138. https://doi.org/10.1130/G22856A.1
    % Hirschmann, M. M. (2000). Mantle solidus: Experimental constraints and
    %   the effects of peridotite composition. Geochemistry, Geophysics, Geosystems,
    %   1(10). https://doi.org/10.1029/2000GC000070
    % Katz, R. F., Spiegelman, M., & Langmuir, C. H. (2003). A new parameterization
    %   of hydrous mantle melting. Geochemistry, Geophysics, Geosystems, 4(9).
    %   https://doi.org/10.1029/2002GC000433
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#other-thermodynamic-properties-docstrings)
[top of page!](#overview)

### ThermalConductivity
path: `vbr/vbr/vbrCore/functions/thermal_properties/ThermalConductivity.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Kc = ThermalConductivity(Kc_o, T, P)
    %
    % calculates thermal conductivity using Xu et al 2004.
    %
    % Parameters
    % ----------
    %  Kc_o   scalar or array of reference values for thermal conductivity
    %         in units of [W / m / K]
    %  T      temperature (scalar or array) [K]
    %  P      pressure (scalar or array) [Pa]
    %
    % Returns
    % -------
    % Kc      thermal conductivity in [W / m / K]
    %
    % References
    % ----------
    % Xu, Y., T. J. Shankland, S. Linhardt, D. C. Rubie, F. Langenhorst, and K.
    %   Klasinski (2004), Thermal diffusivity and conductivity of olivine,
    %   wadsleyite and ringwoodite to 20 GPa and 1373 K, Phys Earth Planet In,
    %   143-144, 321?336, doi:10.1016/j.pepi.2004.03.005.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#other-thermodynamic-properties-docstrings)
[top of page!](#overview)

### SpecificHeat
path: `vbr/vbr/vbrCore/functions/thermal_properties/SpecificHeat.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Cp = SpecificHeat(T,FracFo)
    %
    % Calculates specific heat as a function of temperature using a polynomial.
    %
    % Parameters
    % ----------
    %
    %   T: array or scalar
    %      temperature in degrees K
    %   FracFo: array or scalar
    %       volume fraction forsterite
    %
    % Returns
    % -------
    %   Cp: array or scalar
    %       Specific Heat [J kg^-1 K^-1]
    %
    % References
    % ----------
    % Berman, R. G., and L. Ya Aranovich. "Optimized standard     %
    %   state and solution properties of minerals." Contributions to Mineralogy%
    %   and Petrology 126.1-2 (1996): 1-24.
    %
    % Notes
    % -----
    %
    % Papers report heat capacity (J/mol/K) as polynomial functions of
    % temperature with coefficients determined by fitting. To get to specific
    % heat (J/kg/K), we divide the reported coefficients by molecular weight of
    % the minerals. The function form is typically:
    %
    %  Cp = B(1) + B(2)*T + B(3)*T^2 + B(4)*T^-2 + B(5)*T^-3 + ...
    %       B(6)*T^-0.5 + B(7)/T
    %
    % In this implementation, the array B initially has two rows, with values
    % for forsterite (Fo) in the first row and fayalite (Fa) in the second row.
    % The two are then linearly weighted by the fraction of forsterite in the
    % mantle before calculating Cp.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#other-thermodynamic-properties-docstrings)
[top of page!](#overview)

### sr_water_fugacity
path: `vbr/vbr/vbrCore/functions/sr_water_fugacity.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % fH2O=sr_water_fugacity(H2O_PPM,H2O_o,P_Pa,T_K)
    %
    % calculates water fugacity following
    %
    %          H2O = A_o * exp(-(E + P * V)/(R*T)) * fH2O
    %
    % equation 6 in Hirth and Kohlstedt, 2003, In Inside the Subduction
    % Factory, J. Eiler (Ed.). https://doi.org/10.1029/138GM06
    %
    % Parameters:
    % -----------
    %        P_Pa      pressure [Pa]
    %        T_K       temperature [K]
    %        H2O_PPM   water concentration [PPM]
    %        H2O_o     min water concentration [PPM], H2O_PPM<H2O_o has no effect.
    %
    % Output:
    % -------
    %        fH2O  water fugacity [MPa]
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#other-thermodynamic-properties-docstrings)
[top of page!](#overview)

### Qinv_from_J1_J2
path: `vbr/vbr/vbrCore/functions/Qinv_from_J1_J2.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Qinv_from_J1_J2(J1, J2, use_correction)
    %
    % calculate attenuation from J1 and J2 with optional
    % correction factor.
    %
    % Parameters
    % ----------
    % J1
    %    real part of complex compliance (same shape as J2)
    % J2
    %    imaginary part of complex compliance (same shape as J1)
    % use_correction
    %    optional integer flag (default is 0). If set to 1, will
    %    use the small Q (large Qinv) factor from equation B6
    %    of McCarthy et al 2011 (https://doi.org/10.1029/2011JB008382)
    %
    % Returns
    % %%%%%%%
    % Qinv
    %     attenuation, same shape as J1 and J2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#other-thermodynamic-properties-docstrings)
[top of page!](#overview)

### PiezometerWH2006
path: `vbr/vbr/vbrCore/functions/PiezometerWH2006.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % d_um = PiezometerWH2006(sig_MPa)
    %
    % returns an array of the same size as sig with grainsizes in um calculcated
    % using the rectysallized grain-size piezometer for olivine of Warren and
    % Hirth (2006). If no stress is specified the function simply produces a
    % plot of the piezometer, the data it was regressed to, and its uncertainty.
    %
    % Citation:
    %   Warren, J. M., & Hirth, G. (2006). Grain size sensitive deformation
    %   mechanisms in naturally deformed peridotites. Earth and Planetary
    %   Science Letters, 248(1-2), 438-450.
    %   https://doi.org/10.1016/j.epsl.2006.06.006
    %
    % Parameters:
    % ----------
    % sig_MPa: array | scalar
    %    differential stress in MPa. Can be an array of any shape or a scalar.
    %    If not provided, this function will make a plot.
    %
    % Output:
    % ------
    % d_um: array | scalar
    %     grain size in um, same shape as the input sig_MPa
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#other-thermodynamic-properties-docstrings)
[top of page!](#overview)

## VBRc support: docstrings

### vbr_version
path: `vbr/vbr/support/vbr_version.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Version = vbr_version()
    %
    % return the VBRc Version structure
    %
    % Returns
    % -------
    % Version.  : structure with the following fields
    %        .major : int
    %           the major version number
    %        .minor : int
    %           the minor version number
    %        .patch : int
    %           the patch version number
    %        .version: string
    %            the version string (e.g., '2.0.1')
    %
    % Notes
    % -----
    % Version.version will include a 'dev' if you are
    % running a development version.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#vbrc-support-docstrings)
[top of page!](#overview)

### VBR_list_methods
path: `vbr/vbr/support/VBR_list_methods.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VBR_list_methods() or VBR_list_methods(single_prop)
    %
    % prints available methods by property to screen
    %
    % Parameters
    % -----------
    % single_prop: optional string
    %     if included, must be in 'anelastic', 'elastic' or 'viscous'
    %
    % Examples
    % --------
    %
    % VBR_list_methods() will print all methods
    % VBR_list_methods('viscous') will print only viscous methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#vbrc-support-docstrings)
[top of page!](#overview)

### full_nd
path: `vbr/vbr/vbrCore/functions/full_nd.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % X = full_nd(fill_val, N)
    %
    % returns an N-D array filled with a constant. After fill_val, all arguments
    % are forwarded to ones().
    %
    % Parameters:
    % ----------
    % fill_val
    %     the number to fill the array (or matrix) with
    %
    % remaining arguments are forwarded to ones().
    %
    %
    % Output:
    % ------
    % matrix
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#vbrc-support-docstrings)
[top of page!](#overview)

### vbr_categorical_color
path: `vbr/vbr/support/vbr_categorical_color.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  rgb = vbr_categorical_color(iclr)
    %
    %  return a single rgb value from the vbr_categorical_cmap_array.
    %
    % Parameters
    % ----------
    % iclr
    %     the index to sample from the colormap. Will be wrapped to be within
    %     the bounds of the colormap.
    %
    % Output
    % ------
    % rgb
    %     3-element array of floating point rgb values in (0,1) range
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#vbrc-support-docstrings)
[top of page!](#overview)

### vbr_categorical_cmap_array
path: `vbr/vbr/support/vbr_categorical_cmap_array.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % x = vbr_categorical_cmap_array()
    %
    % return an array of rgb values for a categorical colormap.
    %
    % colormap was generated with http://vrl.cs.brown.edu/color , see:
    %  Gramazio et al., 2017, IEEE Transactions on Visualization and Computer
    %      Graphics, "Colorgorical: creating discriminable and preferable color
    %      palettes for information visualization"
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#vbrc-support-docstrings)
[top of page!](#overview)

### VBR_save
path: `vbr/vbr/vbrCore/functions/io_functions/VBR_save.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VBR_save(VBR, fname, exclude_SVs)
    %
    % Save a VBR structure to disk as a Matlab binary (even if
    % running from Octave).
    %
    % Parameters
    % ----------
    % VBR: structure
    %     the VBR structure to save
    % fname: string
    %     the filename, will append .mat if not present
    % exclude_SVs: optional integer
    %     default is 0. set to 1 to exclue VBR.in.SV from save file.
    %     Useful for reducing disk-space when saving multiple results.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#vbrc-support-docstrings)
[top of page!](#overview)

## Developer Support: docstrings

### checkStructForField
path: `vbr/vbr/support/checkStructForField.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [field_exists,missing] = checkStructForField(StructA,FieldTree,Verb);
    %
    % checks structure for existence of nested fields. Useful for validation in
    % functions that accept the VBR structure.
    %
    % Parameters
    % ----------
    %   StructA: structure
    %     the structure to inspect
    %   FieldTree: cell array of strings
    %     a cell array of the nested fields to look for, e.g., {'in';'SV';'T_K'}
    %   Verb: 0/1 flag
    %     verbosity flag: set to 0 to suppress messages
    %
    % Returns
    % -------
    % [field_exists, missing]
    %     field_exists:  boolean
    %       1 if StructA contains all subfields, 0 else
    %     missing
    %       string of nested location that failed
    %
    % Examples
    % --------
    % To check a VBR structure for the existence of a state variable field:
    %
    % [field_exists,missing] = checkStructForField(VBR, {'in';'SV';'T_K'} ,0);
    %
    % for example:
    %
    %   VBR = struct();
    %   [field_exists,missing] = checkStructForField(VBR, {'in';'SV';'T_K'} ,1)
    %
    % displays:
    %   structure missing field:  .in
    %   field_exists = 0
    %   missing = .in
    %
    % indicating that the field does not exist because VBR.in does not exist.
    % adding a SV field (but not T_K):
    %
    %   VBR.in.SV.phi = 0;
    %   [field_exists,missing] = checkStructForField(VBR, {'in';'SV';'T_K'} ,1)
    %
    % displays:
    %   structure missing field:  .in.SV.T_K
    %   field_exists = 0
    %   missing = .in.SV.T_K
    %
    % indicating that the field does not exist in VBR.in.SV.
    %
    % Finally,
    %
    %   VBR.in.SV.T_K = 273;
    %   [field_exists,missing] = checkStructForField(VBR, {'in';'SV';'T_K'} ,1)
    %
    % will result in:
    %   field_exists = 1
    %   missing =
    %
    % indicating that the field was found.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#developer-support-docstrings)
[top of page!](#overview)

### get_nested_field_from_struct
path: `vbr/vbr/support/get_nested_field_from_struct.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get_nested_field_from_struct(my_struct, field_tree_cell)
    %
    % attempts to fetch a potentially nested field from a structure. Important to
    % note that this function does not check for existence of the field:
    % use checkStructForField before calling this function if you are not sure
    % whether or not the field will exist.
    %
    % Parameters
    % ----------
    % my_struct: Struct
    %    a structrue
    % field_tree_cell: cell array
    %    a cell array containing the path to the field name in the structure,
    %    for example {'out'; 'elastic'; 'anharmonic'; 'Gu'}
    %
    % Example
    % -------
    % Gu = get_nested_field_from_struct(VBR, {'out'; 'elastic'; 'anharmonic'; 'Gu'})
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#developer-support-docstrings)
[top of page!](#overview)

### nested_structure_update
path: `vbr/vbr/support/nested_structure_update.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  output_struct = nested_structure_update(struct_1, struct_2)
    %
    %  update struct_1 with fields from struct_2. Unique fields from both
    %  structures are preserved. For fields that are shared, the fields from
    %  struct_2 are copied over unless the field is a structure, in which case
    %  it triggers a recursive structure comparison for that field.
    %
    %  Parameters
    %  ----------
    %  struct_1
    %    the structure to update
    %  struct_2
    %    the structure to copy in fields from
    %
    %  Returns
    %  -------
    %
    %  struct
    %    a new structure with fields from struct_1 and struct_2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#developer-support-docstrings)
[top of page!](#overview)

### is_octave
path: `vbr/vbr/support/is_octave.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % is_octave()
    %
    % returns 1 if running in Octave, 0 if running in MATLAB
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#developer-support-docstrings)
[top of page!](#overview)

### varargin_keyvals_to_structure
path: `vbr/vbr/support/varargin_keyvals_to_structure.m`

```matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % input_args = varargin_keyvals_to_structure(outer_varargin)
    %
    % convert key-value pair varargin to a structure. useful for function input validation
    %
    % Parameters
    % ----------
    % outer_varargin
    %     the varargin values from a different function
    %
    % Returns
    % -------
    % input_args: structure
    %     a structure containing fields and values for each key-value pair in outer_varargin
    %
    % Examples
    % --------
    %
    % basic usage:
    %
    %     disp(varargin_keyvals_to_structure('first_arg', 0, 'x', 100, 'last_arg', 'hello'))
    %
    %     prints
    %
    %        first_arg = 0
    %        x = 100
    %        last_arg = hello
    %
    % To use in other functions for validation:
    %
    %   function result = my_new_function(a, b, varargin)
    %        defaults.x = 1;
    %        defaults.y = 0;
    %        input_args= varargin_keyvals_to_structure(varargin);
    %
    %        % update the structure to include defaults
    %        input_args = nested_structure_update(defaults, input_args);
    %
    %        result = a * input_args.x + b * input_args.y;
    %   end
    %
    % where my_new_function is designed to accept 'x' and 'y' key-value arguments like
    %   my_new_function(a, b, 'x', 10, 'y', 100)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```
[top of category!](#developer-support-docstrings)
[top of page!](#overview)
