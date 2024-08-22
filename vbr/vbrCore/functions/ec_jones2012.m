function [ VBR ] = ec_jones2012(VBR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_jones2012( VBR )
%
% Jones et al. calibration of hydrous electrical conductivity from previous labratory experiments
%   to South African Jagersfontein and Gibeon Xenolith in situ results
%   
% Constable 2006(SEO3) used as the Esig Anhydrous Conduction;
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.jones2012_ol
%   
%           VBR.out.electric.jones2012_ol.esig_A
%           VBR.out.electric.jones2012_ol.esig_H
%           VBR.out.electric.jones2012_ol.esig
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
    
    % Corrections
    Ch2o_ol = Ch2o_ol./1d4; % weight fraction, water content
    
    % read in parameters
    params = VBR.in.electric.jones2012_ol;
    S = params.S;
    r = params.r;
    H = params.H;
    a = params.a;
    Va = params.Va;
    k = params.k;
    H = H + Va.*P; 
    
    % Arrhenius Relation
        % Hydrous 
        esig_H = arrh_wet(S,H,k,T,Ch2o_ol,a,r);

        % Anhydrous
        fO2 = OxF(T); % Pa
        esig_A = SEO3_ne(T, fO2);
    
    % summation of conduction mechanisms
    esig = esig_H + esig_A; 
    
    % store in VBR structure
    jones2012_ol.esig_A = esig_A; % S/m, conductivity anhydrous
    jones2012_ol.esig_H = esig_H; % S/m, conductivity hydrous
    jones2012_ol.esig = esig; % S/m, conductivity olivine bulk
    VBR.out.electric.jones2012_ol = jones2012_ol;
end
    
function sig = arrh_wet(S,H,k,T,w,a,r)
exponent = -((H-a.*(w.^(1/3)))./(k.*T));
sig = (S).*(w.^r).*exp(exponent);
end

function fO2 = OxF(T)
qfm = -24441.9./(T) + 13.296; % revised QFM-fO2 from Jones et al 2009
fO2 = 10.^qfm;
end

function sT = SEO3_ne(T, fO2)
e = 1.602e-19;
k = 8.617e-5;
kT = k*(T);
bfe = (5.06e24)*exp((-0.357)./kT);
bmg = (4.58e26)*exp((-0.752)./kT);
ufe = (12.2e-6)*exp((-1.05)./kT);
umg = (2.72e-6)*exp((-1.09)./kT);
concFe = bfe + (3.33e24)*exp((-0.02)./kT).*fO2.^(1/6); 
concMg = bmg + (6.21e30)*exp((-1.83)./kT).*fO2.^(1/6); 
sT = concFe.*ufe*e + 2*concMg.*umg*e;
return 
end
