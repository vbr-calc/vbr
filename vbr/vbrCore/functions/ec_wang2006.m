function [ VBR ] = ec_wang2006( VBR )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_wang2006( VBR )
%
% Parameterization of synthetic hydrous and anhydrous polycrystalline
%     olivine
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.wang2006_ol 
% 
%                           VBR.out.electric.wang2006_ol.esig_H
%                           VBR.out.electric.wang2006_ol.esig_A
%                           VBR.out.electric.wang2006_ol.esig
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
        Ch2o_ol = VBR.in.SV.Ch2o; % ppm , water content
    end
    
    % Corrections
    Ch2o_ol = Ch2o_ol./1d4; % weight fraction, water content
    
    % read in parameters
    params = VBR.in.electric.wang2006_ol;

    SH = params.S_H;
    Va_H = params.Va_H; 
    HH = params.H_H + Va_H.*P;
    R = params.R_H;
    a = params.a_H;
    r = params.r_H;
    
    SA = params.S_A;
    Va_A = params.Va_A;
    HA = params.H_A + Va_A.*P;
    
    % Arrhenius Relation
        % Anhydrous
        esig_A = arrh_dry(SA,HA,R,T);
        % Hydrous
        esig_H = arrh_wet(SH,HH,R,T,Ch2o_ol,a,r);
        
    % summation of conduction mechanisms
    esig = esig_A + esig_H;
    
    % store in VBR structure
    wang2006_ol.esig_A = esig_A; % S/m, conductivity anhydrous olivine
    wang2006_ol.esig_H = esig_H; % S/m, conductivity hydrous olivine
    wang2006_ol.esig = esig; % S/m, conductivty olivine bulk
    wang2006_ol = ec_method_units(wang2006_ol);
    VBR.out.electric.wang2006_ol = wang2006_ol;
end

function sig = arrh_dry(S,H,k,T)
exponent = -(H)./(k.*T);
sig = (S).*exp(exponent);
end

function sig = arrh_wet(S,H,k,T,w,a,r)
exponent = -(H-a.*(w.^(1/3)))./(k.*T);
sig = (S).*(w.^r).*exp(exponent);
end
