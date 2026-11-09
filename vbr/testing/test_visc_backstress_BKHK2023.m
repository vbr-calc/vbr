function TestResult = test_visc_backstress_BKHK2023()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % a bit more thorough test of the backstress model
    % to check failure states a bit better
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed = true;
    TestResult.fail_message = '';

    %set temperature
    T = 1000+273; %K, temperature

    %set frequency
    f =  1e-2; %Hz

    %  build 2D grid of grain size and stress
    d   = logspace(1,    5,    40)      ; %um, grain sizes
    sig = logspace(-1,   3,    41)      ; %MPa, differential stress

    [SV.dg_um, SV.sig_MPa] = meshgrid(d, sig); %creates an array with dimensions in order of d, and then sig

    sz = size(SV.dg_um);

    % set constants
    SV.T_K   = T * ones(sz); %K, Temperature
    SV.f = f;
    SV.phi = 0 * ones(sz);
    SV.P_GPa = 3.5 * ones(sz); % pressure [GPa]
    SV.Tsolidus_K = -5.104.*SV.P_GPa.^2 + 132.899.*SV.P_GPa + 1120.661 +273; %K , solidus temperature (for premelt model) from Hirschmann, 2000
    SV.rho = 3300 * ones(sz); %kgm-3, density

    VBR = struct();
    VBR.in.SV = SV;
    VBR.in.elastic.methods_list = {'anharmonic'}; % set methods list
    VBR.in.elastic.anharmonic = Params_Elastic('anharmonic');
    VBR.in.elastic.anharmonic.temperature_scaling = 'isaak';
    VBR.in.elastic.anharmonic.pressure_scaling = 'abramson';


    VBR.in = VBR.in;
    VBR.in.viscous.methods_list={'BKHK2023'};
    VBR.in.anelastic.methods_list={'maxwell_analytical'};
    % select viscous method, in this case the backstress model with
    % dislocation recovery by grain-boundary and pipe diffusion
    VBR.in.anelastic.maxwell_analytical.viscosity_method_mechanism = 'gbnp';
    [VBR] = VBR_spine(VBR); % run VBR
end
