%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build a deformation mechanism map for HZK2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VBR = struct();
% populate methods list
VBR.in.viscous.methods_list={'HZK2011'};

% setup experimental conditions
sigma_1d = logspace(-1, 4, 100); % MPa
grain_size_1d = logspace(0, 4, 98); % um

[grain, sigma] = meshgrid(grain_size_1d, sigma_1d);

VBR.in.SV.dg_um = grain;
VBR.in.SV.sig_MPa = sigma;
sz = size(sigma);
VBR.in.SV.P_GPa = 3 * ones(sz); % pressure [GPa]
VBR.in.SV.T_K = 1673 * ones(sz); % temperature [K]
VBR.in.SV.phi = zeros(sz); % melt fraction (porosity)

VBR = VBR_spine(VBR);

visc = VBR.out.viscous.HZK2011; % just for convenience
flds = {'diff'; 'disl'; 'gbs';};
figure()
for ifield = 1:numel(flds)
  current_field = flds{ifield};
  subplot(1,numel(flds), ifield)
  sr_f = visc.(current_field).sr ./ visc.sr_tot;
  contourf(log10(grain_size_1d), log10(sigma_1d), sr_f, 25, 'linecolor', 'None')
  colorbar()
  xlabel('log10(grain size [um])')
  ylabel('log10(differential stress [MPa])')
  title(current_field)
end
