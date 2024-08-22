function [VBR] = ec_layers(VBR, phase1, phase2) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [ VBR ] = layer(VBR, phase1, phase2)
%
% Geophysical mixing model of laterally continous, perpendicularly
%     alternating for electrical conductivity of 2 phases
%
% Parameters:
% ----------
% VBR    the VBR structure
%
% Output:
% ------
% VBR    the VBR structure, with VBR.out.electric.layers.esig
%           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read in phi
    phi = VBR.in.SV.phi; % volume fraction, melt
    
    % Calculations
    Nphi = 1-phi; % volume fraction, solid phase
    
    aa = ((Nphi.^(2/3))-1).*phase2;
    ab = (Nphi.^(1/3)).*phase1;
    a = aa-ab;
    
    b = (Nphi-(Nphi.^(2/3))).*phase2;
    c = ((Nphi.^(2/3))-Nphi-1).*phase1;
    
    esig = a.*((b+c).^-1).*phase2;
    
    % Store in VBR structure
    layers.esig = esig; % S/m, conductivity bulk
    VBR.out.electric.layers = layers;
end