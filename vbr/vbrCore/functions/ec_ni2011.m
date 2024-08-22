function VBR = ec_ni2011(VBR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_ni2011( VBR )
% 
% Parameterization of electrical conductivity resulting from H2O volatile
%   content in basaltic melt
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.ni2011_melt.esig
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in State Variables (SVs)
    T = VBR.in.SV.T_K; % K, Temmperature
    Ch2o_m = VBR.in.SV.Ch2o_m; % ppm, water content
    
    % read in parameters
    params = VBR.in.electric.ni2011_melt;
    Tcorr = params.Tcorr; % K, Temperature Correction
    
    % Corrections
    Ch2o_m = Ch2o_m./1d4; % weight fraction, water content melt
    
    % Calculations
    ls = 2.172-((860.82-204.46*sqrt(Ch2o_m))./(T-Tcorr));
    esig = 10.^ls;
    
    % store in VBR structure
    ni2011_melt.esig = esig; % S/m, conductivity melt bulk
    VBR.out.electric.ni2011_melt = ni2011_melt;
end