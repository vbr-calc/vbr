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
[SVs, Ranges] = genSVranges();

% run Box through VBR calculator (or load if it exists)
VBR.in.SV=SVs;
VBR.in.electric.methods_list={'yosh2009_ol','SEO3_ol','poe2010_ol','wang2006_ol','UHO2014_ol','jones2012_ol'};
% VBR = genPullVBRData(SVs,fullfile(pwd,'data/VBR_Box.mat'),VBRsettings);
VBR = VBR_spine(VBR);
VBR = ec_vol2part(VBR, 'sifre2014','vol'); % Ch2o and Cco2 partitioning between ol & melt phases
VBR.in.electric.methods_list={'sifre2014_melt','ni2011_melt','gail2008_melt'};
VBR = VBR_spine(VBR);
VBR = HS_mixing(VBR); % Hashin-Shtrikman for melt mixing model

% Generate Variable Ranges
esigtarget=0.1; % S/m
cutoffperc=5; % cutoffperc./100
PossibleRanges=getVarRange(VBR,esigtarget,'esig',cutoffperc);

% build figures and comparisons
buildComparisons(VBR,PossibleRanges,fullfile(pwd,'figures/'));

[index, uho_, poe_] = check_val(VBR);
