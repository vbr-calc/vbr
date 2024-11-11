function VBR = ec_sifre2014(VBR) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_sifre2014( VBR )
%
% Parameterization of electrical conductivity in peridotite melt from 
%   volatile content in the incipient melt
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.sifre2014_melt.esig
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in State Variables (SVs)
    T = VBR.in.SV.T_K; % K, Temperature
    Ch2o_m = VBR.in.SV.Ch2o_m; % ppm, bulk water content
    Cco2_m = VBR.in.SV.Cco2_m; % ppm, bulk CO2 content
    
    % Correction
    Ch2o_m = Ch2o_m./1d4; % weight percent, water content melt
    Cco2_m = Cco2_m./1d4; % weight percent, CO2 content melt
    % read in parameters
    params = VBR.in.electric.sifre2014_melt;

    a_h2o = params.h2o_a;
    b_h2o = params.h2o_b;
    c_h2o = params.h2o_c;
    d_h2o = params.h2o_d;
    e_h2o = params.h2o_e;
   
    a_c2o = params.c2o_a;
    b_c2o = params.c2o_b;
    c_c2o = params.c2o_c;
    d_c2o = params.c2o_d;
    e_c2o = params.c2o_e;

    % Arrhenius Relation
        % Esig H2O melt
        H_h2o = a_h2o.*exp(-b_h2o.*Ch2o_m) + c_h2o;
        lS_h2o = d_h2o.*H_h2o + e_h2o;
        S_h2o = exp(lS_h2o);
        melt_h2o = S_h2o.*exp(-H_h2o./(8.314*T)); 
        
        % Esig CO2 melt
        H_co2 = a_c2o.*exp(-b_c2o.*Cco2_m) + c_c2o;
        lS_co2 = d_c2o.*H_co2 + e_c2o;
        S_co2 = exp(lS_co2);
        melt_co2 = S_co2.*exp(-H_co2./(8.314*T)); 
        
    % summation of conduction mechanisms
    esig = melt_co2 + melt_h2o;
    
    % Output to VBR structure
    sifre2014_melt.esig = esig; % S/m, conductivity melt bulk
    sifre2014_melt = ec_method_units(sifre2014_melt);
    VBR.out.electric.sifre2014_melt = sifre2014_melt;
end