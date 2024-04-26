%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CB_014_electrical_conductivy.m
%
%  Calculating electrical conductivity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% put the VBRc in the path %
clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

% specify state variables as usual
VBR = struct();
VBR.in.SV.T_K = linspace(800, 1000, 4);
sz_T = size(VBR.in.SV.T_K);
VBR.in.SV.P_GPa = ones(sz_T) * 2;
VBR.in.SV.Ch2o = ones(sz_T) * 200;

% specify methods
VBR.in.electric.methods_list={'yosh2009';};

% call the VBRc
VBR = VBR_spine(VBR);
