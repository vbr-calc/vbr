function [ VBR ] = ec_UHO2014(VBR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_UHO2014( VBR )
%
% An amalgam of labratory experimentationfor hydrous and anhydrous conductivity in olivine
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.UHO2014_ol
% 
%               VBR.out.electric.UHO2014_ol.esig_i
%               VBR.out.electric.UHO2014_ol.esig_h
%               VBR.out.electric.UHO2014_ol.esig_p
%               VBR.out.electric.UHO2014_ol.esig
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in State Variables (SVs)
    T = VBR.in.SV.T_K; % K, Temperature
    if isfield(VBR.in.SV, "P_GPa")
        P = VBR.in.SV.P_GPa * 1e9; % Pa, Pressure
    else
        P = 0; % Pa (Pressure)
    end

    if isfield(VBR.in.SV, "Ch2o_ol")
        Ch2o_ol = VBR.in.SV.Ch2o_ol; % ppm, water content
    else
        Ch2o_ol = VBR.in.SV.Ch2o; % ppm, water content
    end
    
    % read in parameters
    params = VBR.in.electric.UHO2014_ol;
    
    Sv = params.S_v;
    Va_v = params.Va_v;
    Hv = params.H_v + Va_v.*P;
    
    Sp = params.S_p;
    Va_p = params.Va_p;
    Hp = params.H_p + Va_p.*P;
    
    Sh = params.S_h;
    Va_h = params.Va_h;
    Hh = params.H_h + Va_h.*P;
    R = params.R_h;
    a = params.a_h;
    r = params.r_h;
    
    % Arrhenius Relation
        % Anhydrous
        esig_v = arrh_dry(Sv,Hv,R,T);
        esig_p = arrh_dry(Sp,Hp,R,T);
    
        % Hydrous
        esig_h = arrh_wet(Sh,Hh,R,T,Ch2o_ol,a,r);
    
    % summation of conduction mechanisms
    esig = esig_v + esig_p + esig_h;
    
    % store in VBR structure
    UHO2014_ol.esig_i = esig_v; % S/m, conductivity ionic vacancy
    UHO2014_ol.esig_h = esig_p; % S/m, conductivity polaron hopping
    UHO2014_ol.esig_p = esig_h; % S/m, conductivity proton 
    UHO2014_ol.esig = esig; % S/m, conductivity olivine bulk
    UHO2014_ol = ec_method_units(UHO2014_ol);
    VBR.out.electric.UHO2014_ol = UHO2014_ol;
end

function sig = arrh_dry(S,H,k,T)
exponent = -(H)./(k.*T);
sig = (S).*exp(exponent);
end

function sig = arrh_wet(S,H,k,T,w,a,r)
exponent = -(H-a.*(w.^(1/3)))./(k.*T);
sig = (S).*(w.^r).*exp(exponent);
end
