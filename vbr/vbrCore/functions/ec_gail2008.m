function VBR = ec_gail2008(VBR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_gail2008( VBR )
%
% parameterization of oceanic asthenosphere conductivity by carbonatite present in melt
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.gail2008_melt.esig
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in State Variables (SVs)
    T = VBR.in.SV.T_K; % K, Temmperature
    
    % read in parameters
    params = VBR.in.electric.gail2008_melt;
    S = params.S; 
    H = params.H; 
    R = params.R;
    
    % Arrhenius Relation
    exponent = -H./(R.*T);
    esig = S.*exp(exponent);
    
    % store in VBR structure
    gail2008_melt.esig = esig; % S/m, conductivity melt bulk
    VBR.out.electric.gail2008_melt = gail2008_melt;
end