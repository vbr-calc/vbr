function [VBR] = ec_tubes(VBR, phase1, phase2, ~) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = ec_tube( VBR )
%
% Geophysical mixing model of continous tubes of melt
%     arranged in an ordely fashion
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.tubes.esig
%           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in phi
    phi = VBR.in.SV.phi; % volume fraction, melt
    
    % Calculations
    esig = (1/3)*phi.*phase2 + (1-phi).*phase1;
    
    % Store in VBR structure
    tubes.esig = esig; % S/m, conductivity bulk
    tubes = ec_method_units(tubes);
    VBR.out.electric.tubes = tubes;
end