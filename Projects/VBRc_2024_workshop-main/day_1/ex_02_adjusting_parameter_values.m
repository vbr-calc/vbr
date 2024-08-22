%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic VBRc usage: adjusting parameters, iterating over structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all;
% 1. initialize the VBRc
path_to_top_level_vbr=getenv('vbrdir');
addpath(path_to_top_level_vbr)
% use the VBRc a lot? add the above to
% startup.m for matlab (https://www.mathworks.com/help/matlab/ref/startup.html)
% or ~/.octaverc for octave (https://docs.octave.org/interpreter/Startup-Files.html)
vbr_init

% 2. initialize the VBR structure
%    - set the properties and methods
%    - set thermodynamic state variable arrays  (T, phi)
vbrListMethods

% Params_ % tab

params_hzk = Params_Viscous('HZK2011')

VBR.in.viscous.methods_list={'HK2003'; 'HZK2011'};
VBR.in.viscous.HZK2011 = Params_Viscous('HZK2011');
VBR.in.viscous.HZK2011.diff.Q = 1e5; % very low, very wrong.

VBR.in.SV.T_K = linspace(600, 1600, 100)+273; % temperature [K]
sz = size(VBR.in.SV.T_K);
VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction
VBR.in.SV.dg_um = 0.01 * 1e6 * ones(sz); % grain size [um]

% 3. call the VBRc
VBR = VBR_spine(VBR);

viscous_fields = fieldnames(VBR.out.viscous)
nfields = numel(viscous_fields);
figure()
for ifield = 1:nfields
    visc = VBR.out.viscous.(viscous_fields{ifield});
    eta_total = visc.eta_total;
    hold all
    semilogy(VBR.in.SV.T_K-273, eta_total, 'displayname', viscous_fields{ifield})
end
legend()
ylabel(['eta (', VBR.out.viscous.HZK2011.units.eta, ')'])
xlabel('T (deg C)')
