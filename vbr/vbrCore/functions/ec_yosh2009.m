function [ VBR ] = ec_yosh2009( VBR )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_yosh2009( VBR )
%
% Parameterization of Electrical Conductivity in San Carlos Olivine Aggregate at 10GPa
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.yosh2009_ol 
% 
%                       VBR.out.electric.yosh2009_ol.esig_i
%                       VBR.out.electric.yosh2009_ol.esig_h
%                       VBR.out.electric.yosh2009_ol.esig_p
%                       VBR.out.electric.yosh2009_ol.esig
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
    params = VBR.in.electric.yosh2009_ol;
    Si = params.S_i;
    Va_i = params.Va_i;
    Hi = params.H_i + Va_i.*P;
    k = params.k_i;
   
    Sh = params.S_h;
    Va_h = params.Va_h;
    Hh = params.H_h + Va_h.*P;
    
    Sp = params.S_p;
    Va_p = params.Va_p;
    Hp = params.H_p + Va_p.*P;
    a = params.a_p;
    r = params.r_p;
    
    % Arrhenius Relation
        % ionic conduction
        esig_i = arrh_dry(Si,Hi,k,T); 

        % small polaron hopping
        esig_h = arrh_dry(Sh,Hh,k,T);

        % proton conduction
        esig_p = arrh_wet(Sp,Hp,k,T,Ch2o_ol,a,r);
    
    % summation of conduction mechanisms
    esig = esig_i + esig_h + esig_p; % S/m
    
    % store in VBR structure
    yosh2009_ol.esig_i = esig_i; % S/m, conductivity ionic 
    yosh2009_ol.esig_h = esig_h; % S/m, conductivity polaron hopping
    yosh2009_ol.esig_p = esig_p; % S/m, conductivity proton
    yosh2009_ol.esig = esig; % S/m, conductivity olivine bulk
    yosh2009_ol = ec_method_units(yosh2009_ol);
    VBR.out.electric.yosh2009_ol = yosh2009_ol;
end

function sig = arrh_dry(S,H,k,T)
exponent = -(H)./(k.*T);
sig = (S).*exp(exponent);
end

function sig = arrh_wet(S,H,k,T,w,a,r)
exponent = -(H-a.*(w.^(1/3)))./(k.*T);
sig = (S).*(w.^r).*exp(exponent);
end
