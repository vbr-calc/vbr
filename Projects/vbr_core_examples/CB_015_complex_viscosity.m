    VBR.in.elastic.methods_list={'anharmonic';};
    VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw';'xfit_premelt'};

    VBR.in.GlobalSettings.anelastic.include_complex_viscosity = 1;

    %  frequencies to calculate at
    nfreqs = 4;
    VBR.in.SV.f = logspace(-2.2,-1.3,nfreqs);


    % Define the Thermodynamic State
    nT = 50;
    T_K = linspace(700+273,1400+273, nT);
    ndg = 30;
    d_um= logspace(-4,log10(5*1e-2), ndg) * 1e6;

    VBR.in.SV.T_K = 1473 * ones(n1,n2); % temperature [K]
    VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,n2); % grain size [um]

    VBR.in.SV.P_GPa = full_nd(2, nT, ndg); % pressure [GPa]
    VBR.in.SV.rho = 3300 * ones(n1,n2); % density [kg m^-3]
    VBR.in.SV.sig_MPa = 10 * ones(n1,n2); % differential stress [MPa]
    VBR.in.SV.phi = 0.0 * ones(n1,n2); % melt fraction
    VBR.in.SV.Tsolidus_K=1200*ones(n1,n2); % solidus

    VBR = VBR_spine(VBR);