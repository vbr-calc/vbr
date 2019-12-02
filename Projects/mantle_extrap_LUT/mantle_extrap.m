%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mantle_extrap.m
%
% - generates a range of mantle conditions
% - calculates mechnaical properties from the thermal models
% - compares mechanical properties between methods for mantle conditions
% - pulls values out of look up table
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
fprintf('\nBuilding State Variable Ranges\n')
[SVs,Ranges] = genSVranges();

% run Box through VBR calculator (or load if it exists)
VBRsettings.ane_meths={'andrade_psp';'xfit_mxw';'eburgers_psp';'xfit_premelt'};
VBRsettings.freqs=[0.01, 0.1];
VBR = genPullVBRdata(SVs,fullfile(pwd,'data/VBR_Box.mat'),VBRsettings);


% build figures and comparisons
buildComparisons(VBR,Ranges,fullfile(pwd,'figures/'));

freq_target=0.01;
Vstarget=4.3;
scale_fac=1/1000; % search for km/s rather than m/s
cutoffperc=0.5;
PossibleRanges=getVarRange(VBR,Vstarget,'V',freq_target,cutoffperc,scale_fac);
