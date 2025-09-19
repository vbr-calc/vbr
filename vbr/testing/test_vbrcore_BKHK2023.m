%% test-drive BKHK2023 viscous function
% DH 9/8/2025
addpath('/home/diedehein/Documents/GitHub/VBR/vbr')
close all; clear; clc
vbr_init

%% Setup

% set equal-sized arrays of state variables
T_K     = [1200]+273; %K, temperature
sig_MPa = [1];   %MPa, deviatoric stress
dg_um   = [1000]; %um, grain size
[VBR.in.SV.T_K, VBR.in.SV.sig_MPa, VBR.in.SV.dg_um] = meshgrid(T_K,sig_MPa,dg_um); % create meshgrid
sz = size(VBR.in.SV.T_K); 

% set frequency range
f = logspace(-13,2,16); % [Hz] 
VBR.in.SV.f = f;

% set constants
VBR.in.SV.P_GPa = 3.5 * ones(sz); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(sz); %kgm-3, density

% set methods
VBR.in.anelastic.methods_list = {'andrade_analytical'}; % set methods list
VBR.in.anelastic.andrade_analytical.Beta = 0; % turn off anelastic part of Andrade model and turns it into a Maxwell model
VBR.in.viscous.methods_list = {'BKHK2023'}; % select which viscosity to use
VBR.in.viscous.BKHK2023.Resolution = 0.001e6; %Pa, set resolution of numerical algorithm that finds the steady-state viscosity of BKHK2023
VBR.in.elastic.methods_list = {'anharmonic'}; % set methods list
VBR.in.elastic.anharmonic = Params_Elastic('anharmonic'); 
VBR.in.elastic.anharmonic.temperature_scaling = 'isaak';
VBR.in.elastic.anharmonic.pressure_scaling = 'abramson';
VBR.in.anelastic.andrade_analytical.viscosity_method_mechanism = 'gbnp'; % select viscous method, in this case the backstress model including both gb and pipe recovery

%% Call VBR
VBR = VBR_spine(VBR); % run VBR

%% rudimentary plotting
figure
%                                                          s T d
loglog(f,squeeze(VBR.out.anelastic.andrade_analytical.Qinv(:,:,:,:)))
xlabel('Frequency (Hz)')
ylabel('Q^{-1}')