---
permalink: /examples/CB_017_backstress_model/
title: ""
---

# CB_017_backstress_model.m
## output figures

!['CB_017_backstress_model'](/vbr/assets/images/CBs/CB_017_backstress_model.png){:class="img-responsive"}
## contents
```matlab
function VBR = CB_017_backstress_model()
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % CB_017_backstress_model
       %
       % Demonstration of the backstress model: reproduces the 
       % supplemental figure S12 of Hein et al, 2025 
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


       VBR.in.anelastic.methods_list = {'backstress_linear'};
       VBR.in.elastic.methods_list = {'anharmonic'};
       VBR.in.elastic.anharmonic = Params_Elastic('anharmonic'); 
       VBR.in.elastic.anharmonic.temperature_scaling = 'isaak';
       VBR.in.elastic.anharmonic.pressure_scaling = 'abramson';

       % set state variables
       VBR.in.SV.T_K = [1300, 1400, 1500] + 273;
       sz = size(VBR.in.SV.T_K);
       VBR.in.SV.sig_dc_MPa = full_nd(3., sz);
       VBR.in.SV.dg_um = full_nd(0.001 * 1e6, sz);

       % following are needed for anharmonic calculation
       VBR.in.SV.P_GPa = full_nd(5., sz);
       VBR.in.SV.rho = full_nd(3300, sz);
       VBR.in.SV.f = logspace(-8, 0, 500);%[0.001, 0.01]; 

       % calculations
       VBR = VBR_spine(VBR); 

       % plotting
       if ~vbr_tests_are_running()
              Qinv = VBR.out.anelastic.backstress_linear.Qinv;
              Vs = VBR.out.anelastic.backstress_linear.V / 1e3;

              valid_f = VBR.out.anelastic.backstress_linear.valid_f;
              figure('PaperPosition',[0,0,12,4],'PaperPositionMode','manual')
              colors = {[0.9290 0.6940 0.1250]; [0.8500 0.3250 0.0980]; 'r'};
              for itemp = 1:sz(2)    
              Qinvvals = squeeze(Qinv(1, itemp, :));
              above_cutoff = squeeze(valid_f(1, itemp, :));
              Vsvals = squeeze(Vs(1, itemp, :));

              dnm = [num2str(VBR.in.SV.T_K(itemp) - 273), ' [C]'];
              subplot(1,2,1)
              hold on
              loglog(VBR.in.SV.f, Qinvvals, 'color', colors{itemp}, ...
                     'displayname', dnm)   
                                   
              subplot(1,2,2) 
              hold on     
              semilogx(VBR.in.SV.f, Vsvals,  'color', colors{itemp}, ...
                     'displayname', dnm)    
                     
                     
              dnm = [dnm, ' (valid)'];
              valid_Qinvvalues = Qinvvals(above_cutoff == 1);
              valid_fvals = VBR.in.SV.f(above_cutoff == 1);
              valid_vs = Vsvals(above_cutoff == 1);

              subplot(1,2,1)
              hold on
              loglog(valid_fvals, valid_Qinvvalues, 'color', colors{itemp}, ...
                     'linewidth', 2, 'displayname', dnm)

              subplot(1,2,2)
              hold on
              semilogx(valid_fvals, valid_vs, 'color', colors{itemp}, ...
                     'linewidth', 2, 'displayname', dnm)      

              end 
              subplot(1,2,1)
              ylim([1e-4, 1e2])
              xlabel('f [Hz]')
              ylabel('Q^{-1}')
              box on

              subplot(1,2,2)
              box on
              ylabel('V_s [km/s]')
              xlabel('f [Hz]')
              legend('location', 'northwest')

              saveas(gcf,'./figures/CB_017_backstress_model.png')
       end
end```
