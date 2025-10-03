function VBR = CB_021_analytical_methods()
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %  CB_021_analytical_methods
     %
     %  Runs all analytical methods, using moduli and viscosity from VBRc
     %  outputs.
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % the analytical methods will pull unrelaxed modules from the
     % anharmonic output and the steady state viscosity from the first entry
     % in the viscous methods list
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     VBR.in.elastic.methods_list={'anharmonic';};
     VBR.in.viscous.methods_list={'HZK2011'};
     VBR.in.anelastic.methods_list={'andrade_analytical';'maxwell_analytical'};

     %% Define the Thermodynamic State %%

     % set state variables
     n1 = 1;
     VBR.in.SV.P_GPa = 2 * ones(n1,1); % pressure [GPa]
     VBR.in.SV.T_K = 1473 * ones(n1,1); % temperature [K]
     VBR.in.SV.rho = 3300 * ones(n1,1); % density [kg m^-3]
     VBR.in.SV.sig_MPa = 10 * ones(n1,1); % differential stress [MPa]
     VBR.in.SV.phi = 0.0 * ones(n1,1); % melt fraction
     VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,1); % grain size [um]

     % frequencies to calculate at
     VBR.in.SV.f = logspace(-14,0,50);

     % calculate!
     VBR = VBR_spine(VBR) ;

     % plot frequency dependence of attenuation
     if ~vbr_tests_are_running()
          figure('PaperPosition',[0,0,6,6],'PaperPositionMode','manual')
          mxw = VBR.out.anelastic.maxwell_analytical.Qinv;
          loglog(VBR.in.SV.f, VBR.out.anelastic.andrade_analytical.Qinv, ...
               'displayname', 'analytical andrade', 'linewidth', 2)
          hold all
          loglog(VBR.in.SV.f, mxw, ...
               'displayname', 'analytical maxwell', 'linewidth', 2)
          xlabel('f [Hz]')          
          ylabel('Q^{-1}')
          legend()
          saveas(gcf,'./figures/CB_021_analyticalmethods.png')
     end

end