function [ VBR ] = ec_SEO3( VBR )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_SEO3( VBR )
%
% Standard Electrical Olivine 3 model derived from point defects in a dunite 
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.SEO3_ol.esig
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in electric parameters
    T = VBR.in.SV.T_K; % K, Temperature
    
    % Calculations
        % Oxygen Fugacity
        fO2 = OxF(T); % Pa, Partial Pressure
        
        % Esig SEO3
        esig = SEO3_ne(T, fO2);
    
    % store in VBR structure
    SEO3_ol.esig = esig; % S/m, conductivity olivine bulk
    VBR.out.electric.SEO3_ol = SEO3_ol;
end

function fO2 = OxF(T)
qfm = -24441.9./(T) + 13.296; % revised QFM-fO2 buffer from Jones et al 2009
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
