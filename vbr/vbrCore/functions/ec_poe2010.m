function [ VBR ] = ec_poe2010(VBR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_poe2010( VBR )
%
% Parameterization of electrical conductivity in single crystal San Carlos 
%   olivine (Fo90) at 8 GPa were determined by complex impedance spectroscopy.
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.poe2010_ol
%   
%   VBR.out.electric.jones2012_ol.esig_A
%   VBR.out.electric.jones2012_ol.esig_H
%   VBR.out.electric.jones2012_ol.esig
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
    Ch2o_ol = Ch2o_ol./1d4; % weight percent, water content olvine
    
    % read in paramaters
    params = VBR.in.electric.poe2010_ol;
    
        S_H100 = params.S_H100;   
        Va_H100 = params.Va_H100;
        H_H100 = params.H_H100 + Va_H100.*P;
        a_H100 = params.a_H100;
        r = params.r_H100;
        k = params.k_H100;
    
        S_H010 = params.S_H010;  
        Va_H010 = params.Va_H010;
        H_H010 = params.H_H010 + Va_H010.*P;
        a_H010 = params.a_H010;
    
        S_H001 = params.S_H001;
        Va_H001 = params.Va_H001;
        H_H001 = params.H_H001 + Va_H001.*P;
        a_H001 = params.a_H001;
    
        S_A100 = params.S_A100;
        Va_A100 = params.Va_A100;
        H_A100 = params.H_A100 + Va_A100.*P;
        
        S_A010 = params.S_A010;
        Va_A010 = params.Va_A010;
        H_A010 = params.H_A010 + Va_A010.*P;
        
        S_A001 = params.S_A001;
        Va_A001 = params.Va_A001;
        H_A001 = params.H_A001 + Va_A001.*P;
    
    % Arrhenius Relation
        % Anhydrous
         esig_A100 = arrh_dry(S_A100,H_A100,k,T);
         esig_A010 = arrh_dry(S_A010,H_A010,k,T);
         esig_A001 = arrh_dry(S_A001,H_A001,k,T);
         esig_A = (esig_A001.*esig_A010.*esig_A100).^(1/3);
    
        % Hydrous
         esig_H100 = arrh_wet(S_H100,H_H100,k,T,Ch2o_ol,a_H100,r);
         esig_H010 = arrh_wet(S_H010,H_H010,k,T,Ch2o_ol,a_H010,r);
         esig_H001 = arrh_wet(S_H001,H_H001,k,T,Ch2o_ol,a_H001,r);
         esig_H = (esig_H001.*esig_H010.*esig_H100).^(1/3);
     
    % summation of conduction mechanisms
    esig = esig_H + esig_A; 
    
    % store in VBR structure
    poe2010_ol.esig_H = esig_H; % S/m, conductivity hydrous
    poe2010_ol.esig_A = esig_A; % S/m, conductivity anhydrous
    poe2010_ol.esig = esig; % S/m, conductivity bulk olivine
    VBR.out.electric.poe2010_ol = poe2010_ol;
end

function sig = arrh_dry(S,H,k,T)
exponent = -(H)./(k.*T);
sig = (S).*exp(exponent);
end

function sig = arrh_wet(S,H,k,T,w,a,r)
exponent = -(H-a.*(w.^(1/3)))./(k.*T);
sig = (S).*(w.^r).*exp(exponent);
end
