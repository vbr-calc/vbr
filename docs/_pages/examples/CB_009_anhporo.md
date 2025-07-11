---
permalink: /examples/CB_009_anhporo/
title: ""
---

# CB_009_anhporo.m
## output figures

!['CB_009_anhporo'](/vbr/assets/images/CBs/CB_009_anhporo.png){:class="img-responsive"}
## contents
```matlab
function VBR = CB_009_anhporo()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % CB_009_anhporo.m
  %
  %   Script that plots unrelaxed shear modulus and wavespead vs porosity
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% set porosity variation and other state variables %%
  VBR.in.SV.phi=logspace(-5,-1,100);
  one_array=ones(size(VBR.in.SV.phi));
  VBR.in.SV.T_K = (1300 +273)*one_array; % temperature [K]
  VBR.in.SV.rho = 3300 *one_array; % density [kg m^-3]
  VBR.in.SV.P_GPa=2 * one_array; % pressure [GPa]

  %% set methods list %%
  VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};

  %% call VBR_spine %%
  [VBR] = VBR_spine(VBR) ;

  %% plot the result %%
  if (getenv('VBRcTesting') ~= '1')
    figure('Position', [10 10 600 300],'DefaultAxesFontSize',16);
    subplot(1,2,1)
    semilogx(VBR.in.SV.phi,VBR.out.elastic.anh_poro.Gu/1e9,'k','linewidth',1.5)
    xlabel('\phi'); ylabel('Gu(P,T,\phi) [GPa]')
    set(gca,'linewidth',1.5)

    subplot(1,2,2)
    semilogx(VBR.in.SV.phi,VBR.out.elastic.anh_poro.Vsu/1e3,'k','linewidth',1.5)
    xlabel('\phi'); ylabel('Vsu(P,T,\phi) [km/s]')
    set(gca,'linewidth',1.5)

    saveas(gcf,'./figures/CB_009_anhporo.png')
  end
end```
