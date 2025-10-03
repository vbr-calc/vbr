%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linearized backstress model temperature and frequency 
% dependence at a laboratory scale grain size.
%
% Compare to, e.g., Figure S6 of the supplement to Hein 
% et al 2025, but note that the VBRc result here uses the 
% linearized model, so results only agree at frequencies 
% higher than the characteristic frequency. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VBR.in.anelastic.methods_list = {'backstress_linear'};
VBR.in.elastic.methods_list = {'anharmonic'};
VBR.in.elastic.anharmonic = Params_Elastic('anharmonic'); 
VBR.in.elastic.anharmonic.temperature_scaling = 'isaak';
VBR.in.elastic.anharmonic.pressure_scaling = 'abramson';

% set state variables
VBR.in.SV.T_K = linspace(800, 1500, 10)+273;
sz = size(VBR.in.SV.T_K);
VBR.in.SV.sig_MPa = full_nd(10.0, sz);
VBR.in.SV.dg_um = full_nd(4, sz);

% following are needed for anharmonic calculation
VBR.in.SV.P_GPa = full_nd(.1, sz);
VBR.in.SV.rho = full_nd(3300, sz);
VBR.in.SV.f = logspace(-15, 0, 500);%[0.001, 0.01]; 

% calculations
VBR = VBR_spine(VBR); 

Qinv = squeeze(VBR.out.anelastic.backstress_linear.Qinv);
E = squeeze(VBR.out.anelastic.backstress_linear.E);

xtick_locs = 10.^(-15:5:0);
nT = numel(VBR.in.SV.T_K);
figure('DefaultAxesFontSize', 14)
set(gcf, 'Position', [1, 1, 1200, 800])
for iT = 1:nT
    T_Ci = VBR.in.SV.T_K(iT) - 273;
    Qinv_i = Qinv(iT,:);
    E_i = E(iT,:);    
    R = 1;
    G = (nT - iT)/nT; 
    B = 0; 
    RGB = [R, G, B];

    subplot(2,1,1)
    hold on
    loglog(VBR.in.SV.f, Qinv_i, 'color', RGB, 'linewidth', 2, 'displayname', [num2str(round(T_Ci)), '^oC'])   
    xticks(xtick_locs)
    yticks([1e-5, 1, 1e5])
    ylim([1e-5, 1e5]) 
    ylabel('Q^{-1}') 
    legend('location', 'northwest', 'orientation', 'horizontal')
    box on           
        
    subplot(2,1,2) 
    hold on     
    loglog(VBR.in.SV.f, E_i,  'color', RGB,'linewidth', 2) 
    ylim([1e10, 1e12])
    xticks(xtick_locs)
    title('Linearized backstress T-f dependence')
    
    xlabel('f [Hz]')
    ylabel('relaxed E [Hz]')
    box on
end 
