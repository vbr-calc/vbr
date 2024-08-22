%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic usage of the VBRc and skills-building
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. initialize the VBRc
path_to_top_level_vbr=getenv('vbrdir');  % or /path/to/top_level/vbr/
addpath(path_to_top_level_vbr)
% use the VBRc a lot? add the above to
% startup.m for matlab (https://www.mathworks.com/help/matlab/ref/startup.html)
% or ~/.octaverc for octave (https://docs.octave.org/interpreter/Startup-Files.html)
vbr_init

% 2. initialize the VBR structure
%    - set the properties and methods
%    - set thermodynamic state variable arrays  (T, phi)

VBR = struct();
VBR.in = struct();

vbrListMethods

VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
VBR.in.viscous.methods_list={'HK2003';'HZK2011'};
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'};

%  frequencies to calculate at
VBR.in.SV.f = logspace(-2.2,-1.3,4); % [Hz]

%  size of the state variable arrays. arrays can be any shape
%  but all arays must be the same shape.
VBR.in.SV.T_K = linspace(600, 1600, 100)+273; % temperature [K]
sz = size(VBR.in.SV.T_K);
VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]
VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction
VBR.in.SV.dg_um = 0.01 * 1e6 * ones(sz); % grain size [um]

% what SVs are required? check docs!
% https://vbr-calc.github.io/vbr/vbrmethods/viscous/
% https://vbr-calc.github.io/vbr/vbrmethods/elastic/
% https://vbr-calc.github.io/vbr/vbrmethods/anelastic/
% or just try and you should get useful error messages...

% 3. call the VBRc
VBR = VBR_spine(VBR);

% 4. inspect output
% tab-complete VBR.
% shape of arrays (frequency dependence)
% units of output
disp(fieldnames(VBR.out))
disp(fieldnames(VBR.out.anelastic))
disp(fieldnames(VBR.out.anelastic.eburgers_psp))

% for outputs: https://vbr-calc.github.io/vbr/ left hand method types

% units of outputs
VBR.out.anelastic.eburgers_psp.units

% 5. method citations
VBR.in.anelastic.andrade_psp.citations
%ans =
%{
%  [1,1] = Jackson and Faul, 2010, Phys. Earth Planet. Inter., https://doi.org/10.1016/j.pepi.2010.09.005
%}

% 6. Looping over structures to compare methods
viscous_fields = fieldnames(VBR.out.viscous)  % cell array
viscous_fields(1) % single element of cell array
viscous_fields{2} % just the string

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

% 7. saving results
help VBR_save
VBR_save(VBR, 'myvbr_results.mat')  % alias to save(...)
VBR = load('myvbr_results.mat');
VBR_save(VBR, 'myvbr_results.mat', 1) % exclude the state variable arrays

