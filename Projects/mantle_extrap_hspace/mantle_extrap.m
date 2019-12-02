%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mantle_extrap.m
%
% - generates a range of mantle conditions from analytical halfspace cooling
% - calculates mechnaical properties from the thermal models
% - compares mechanical properties between methods for mantle conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

% put VBR in the path
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

% put local functions in path
addpath('./functions')

% generate mantle conditions from thermal model (or load if it exists)
% ThermalSettings.Tpots=[1400];
[SVs,HS] = genThermalModels();

% run Box through VBR calculator (or load if it exists)
VBRsettings.ane_meths={'andrade_psp';'xfit_mxw';'eburgers_psp';'xfit_premelt'};
VBRsettings.freqs=[0.01, 0.1];
VBRsettings.phi0=0.01; % phi when T > Tsol
VBR = genPullVBRdata(SVs,fullfile(pwd,'data/VBR_Box.mat'),VBRsettings);

% build figures and comparisons
buildComparisons(VBR,HS,fullfile(pwd,'figures/'));
