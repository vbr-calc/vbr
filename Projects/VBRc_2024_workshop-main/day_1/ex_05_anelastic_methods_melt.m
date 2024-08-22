%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comparing anelastic methods
%
% State variable settngs:
% * Variable temperature
% * arbitrary solidus (Ts = 1300 C)
% * simplistic melting model phi = (T - Ts) / (Ts - Tl), liquidus Tl = Ts + 1000;
%
%
% Suggested Explorations:
% * again, how does the poroelastic effect impact variation?
% * add an upper cap on melt fraction to account for melt extraction
% * calculate differences between results from different anelastic methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all;
path_to_top_level_vbr=getenv('vbrdir');
addpath(path_to_top_level_vbr)
vbr_init

VBR.in.elastic.methods_list={'anharmonic';  'anh_poro'};
VBR.in.viscous.methods_list={'HZK2011'}; % needed by xfit_mxw
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw';'xfit_premelt'};

VBR.in.anelastic.xfit_premelt = Params_Anelastic('xfit_premelt');
VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 1; % Yamauchi & Takei 2024 extension

VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticity
VBR.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');
VBR.in.anelastic.eburgers_psp.eBurgerFit = 'bg_peak'; % 'bg_only' (default) or 'bg_peak'


VBR.in.SV.T_K=linspace(900,1400,1000)+273;
sz = size(VBR.in.SV.T_K);
VBR.in.SV.Tsolidus_K=1300*ones(sz)+273;
T_liquidus = VBR.in.SV.Tsolidus_K + 1000;

% phi = (T - Ts) / (Tl - Ts)
VBR.in.SV.phi=(VBR.in.SV.T_K-VBR.in.SV.Tsolidus_K) ./ (T_liquidus - VBR.in.SV.Tsolidus_K);
VBR.in.SV.phi(VBR.in.SV.phi<0)=1e-16;
VBR.in.SV.phi(VBR.in.SV.phi>1)=1;

VBR.in.SV.dg_um=0.01*1e6* ones(sz); % grain size [um]
VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]

rho = san_carlos_density_from_pressure(VBR.in.SV.P_GPa);
rho = Density_Thermal_Expansion(rho, VBR.in.SV.T_K, 0.9);
VBR.in.SV.rho = rho; % density [kg m^-3]
VBR.in.SV.sig_MPa = .01 * ones(sz); % differential stress [MPa]
VBR.in.SV.f = [0.01];

VBR = VBR_spine(VBR);

figure('PaperPosition',[0,0,5,10],'PaperPositionMode','manual')
subplot(4,1,1)
T_C = VBR.in.SV.T_K-273;
semilogy(T_C, VBR.in.SV.phi,'k')
ylim([1e-6,1e-1])
ylabel('\phi')
for imeth = 1:numel(VBR.in.anelastic.methods_list)
    current = VBR.in.anelastic.methods_list{imeth};
    results = VBR.out.anelastic.(current);
    Vs = results.V;
    Q = results.Q;
    M = results.M;

    subplot(4,1,2)
    hold all
    plot(T_C, M/1e9, 'displayname', current)
    ylabel('M [GPa]')

    subplot(4,1,3)
    hold all
    semilogy(T_C, Q, 'displayname', current)
    ylabel('Q')

    subplot(4,1,4)
    hold all
    plot(T_C, Vs/1e3,'displayname', current)
    legend('location','SouthWest')
end

xlabel('T [C]')
saveas(gcf, 'ex_05_anelastic_methods.png')


