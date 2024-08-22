function [VBR] = ec_HS1962(VBR, phase1, phase2) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_HS1962(VBR, phase1, phase2)
%
% Hashin-Shtrikman Lower and upper bound 
%   geophysical mixing model for electrical conductivity of 2 phases
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.HS
% 
%              VBR.out.electric.HS.esig_up
%              VBR.out.electric.HS.esig_lo
%              VBR.out.electric.HS.tf
%           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in phi
    phi = VBR.in.SV.phi; % volume fraction, melt 
    
    % Correction
    if mean(phase1,"all") > mean(phase2,"all") % HS requires that Esig phase 2 > Esig phase 1
      phase1 = phase2; % S/m
      phase2 = phase1; % S/m
    
      disp(" \n ")
      disp(" mean(Phase2) less than mean(phase1), where phase2 should be greater than phase1 \n ")
      disp(" Therefore phase2 and phase1 values exchanged for one another \n ")
      disp(" \n ")
    end
    
    tf = phase1 < phase2; % logical array
    
    % Calculations
    esigUP = HS1962_up(phase1, phase2, phi); % HS upper bound 
    esigLO = HS1962_lo(phase1, phase2, phi); % HS lower bound
    
    % Store in VBR structure
    HS.esig_up = esigUP; % S/m, conductivity bulk
    HS.esig_lo = esigLO; % S/m, conductivity bulk
    HS.tf = tf; % logical array

    VBR.out.electric.HS = HS;
end

function esig = HS1962_up(esig_1, esig_2,phi) % Hashin-Shtrikman Upper
num = 3.*(1-phi).*(esig_2-esig_1); % numerator
den = 3.*esig_2-phi.*(esig_2-esig_1); % denominator
esig = esig_2.*(1-(num./den));
end

function esig = HS1962_lo(esig_1, esig_2,phi) % Hashin-Shtrikman Lower
num = 3.*(phi).*(esig_2-esig_1); % numerator
den = 3.*esig_1+(1-phi).*(esig_2-esig_1); % denominator
esig = esig_1.*(1+(num./den));
end