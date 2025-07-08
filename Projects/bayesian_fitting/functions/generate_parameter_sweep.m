function sweep = generate_parameter_sweep(sweep_params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sweep = generate_parameter_sweep(sweep_params);
%
% Calculates the mean Vs and Q at a range of depths for a combination of
% VBR input parameters (temperature, melt fraction, and grain size) across
% the values specified in sweep_params.  This will be used as a
% look-up-table to find the best fitting parameter combination.
%
% Calculated Vs and Q is dependent on the values of the state variables
% assumed, as well as the frequency range assumed for the observed data
% and the calibration assumed for anelastic behaviour.
%
% Parameters:
% -----------
%        sweep_params       structure with the following required fields
%               T               vector of temperature values [deg C]
%               phi             vector of melt fractions [vol fraction]
%               gs              vector of grain sizes [micrometres]
%               per_bw_max      maximum period (min. freq.) considered [s]
%               per_bw_min      minimum period (max. freq.) considered [s]
%
% Output:
% -------
%        sweep              structure with the following fields
%               z               vector of depths [m]
%               VBR             structure of fixed values for the VBR
%                               input, including information on assumed
%                               pressure, stress, water content, density
%               Box             structure, described separately below
%               All the fields on the input structure, sweep_params
%
%       sweep.Box          (numel(sweep_params.T) x numel(sweep_params.phi)
%                           x numel(sweep_params.gs)) structure.  Each
%                          element contains a field for each of the
%                          anelastic methods in given in
%                          VBR.in.anelastic.methods_list
%
%       sweep.Box.[anelastic method name]
%                           structure with the following fields
%               meanVs          vector of calculated Vs (mean within the
%                               given frequency range) [km/s]
%               meanQ           vector of calculated Q (mean
%                               within the given frequency range)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% construct state variable fields
z = linspace(50,170,100)*1e3; z= z';
VBR.in.z = z;
sweep_params.P_GPa = z * 3300 * 9.8 /1e9;
VBR.in.SV.f = logspace(-2.2,-1.3,10);

[T,phi,gs] = ndgrid(sweep_params.T,sweep_params.phi,sweep_params.gs);
VBR.in.SV.T_K = T + 273;
VBR.in.SV.phi = phi;
VBR.in.SV.dg_um = gs;

Tshp = size(T);
VBR.in.SV.sig_MPa = 0.1*ones(Tshp);
VBR.in.SV.Ch2o = zeros(Tshp); % in PPM!
VBR.in.SV.rho = 3300 * ones(Tshp); % [Pa]
VBR.in.SV.chi = ones(Tshp);

% write method list (these are the things to calculate)
% Use all available methods except xfit_premelt
elastic = feval(fetchParamFunction('elastic'), '');
VBR.in.elastic.methods_list = elastic.possible_methods;
viscous = feval(fetchParamFunction('viscous'), '');
VBR.in.viscous.methods_list = viscous.possible_methods;
anelastic = feval(fetchParamFunction('anelastic'), '');
VBR.in.anelastic.methods_list = anelastic.possible_methods;
VBR.in.anelastic.eburgers_psp = Params_Anelastic('eburgers_psp');
VBR.in.anelastic.eburgers_psp.method = 'FastBurger';

% Generate parameter sweep and calculate VBR at each combination
sweepBox = calculate_sweep(VBR, sweep_params);

sweep = sweep_params;
sweep.z = z;
sweep.Box = sweepBox;
sweep.VBR = VBR;
sweep.P_GPa = sweep_params.P_GPa;
% sweep.cH2O = VBR.in.SV.Ch2o;
sweep.state_names = {'T', 'phi', 'gs'};

end

function [sweepBox] = calculate_sweep(VBR_init, sweep_params)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % sweepBox = calculate_sweep(sweep_params);
    %
    % Calls extract_meanVs_Q() to calculate mean Vs and Q values given the
    % fixed parameters given in VBR_init and across all combinations of the
    % parameters given in sweep_params (T, phi, gs) for the frequency range
    % given in sweep_params.
    %
    % Parameters:
    % -----------
    %       sweep_params       structure with the following required fields
    %               T               vector of temperature values [deg C]
    %               phi             vector of melt fractions [vol (?) fraction]
    %               gs              vector of grain sizes [micrometres]
    %               per_bw_max      maximum period (min. freq.) considered [s]
    %               per_bw_min      minimum period (max. freq.) considered [s]
    %
    %       VBR                 structure of fixed values for the VBR input
    %                           including information on assumed pressure,
    %                           stress, water content, density
    %
    % Output:
    % -------
    %       sweepBox          (numel(sweep_params.T) x numel(sweep_params.phi)
    %                           x numel(sweep_params.gs)) structure.  Each
    %                          element contains a field for each of the
    %                          anelastic methods in given in
    %                          VBR.in.anelastic.methods_list
    %       sweep.Box.[anelastic method name]
    %                           structure with the following fields
    %               meanVs          vector of calculated Vs (mean within the
    %                               given frequency range) [km/s]
    %               meanQinv        vector of calculated attentuation (mean
    %                               within the given frequency range)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    VBR = VBR_init; 
    P_GPa0 = sweep_params.P_GPa; 
    n_T   = numel(sweep_params.T);
    n_phi    = numel(sweep_params.phi);
    n_gs     = numel(sweep_params.gs);
    nZ = numel(P_GPa0);
    nP = numel(P_GPa0);

    VBRBox(numel(P_GPa0)) = struct();
    % now loop it, store the mean value arrays
    disp('    generating parameter sweep')
    Tshp = size(VBR.in.SV.T_K);
    
    for i_P = 1:nP
      tic()
      disp(['    calculating step ',num2str(i_P),' of ',num2str(nP)])
      VBR.in.SV.P_GPa = P_GPa0(i_P) * ones(Tshp);
      solidus_C = SoLiquidus(VBR.in.SV.P_GPa*1e9, zeros(Tshp), zeros(Tshp), 'hirschmann');
      VBR.in.SV.Tsolidus_K = solidus_C.Tsol + 273;
      VBR = VBR_spine(VBR);
      telapsed = toc() ;
      disp(['         step complete after ',num2str(telapsed/60),' mins, storing result.'])
      % get averages over frequencies at this pressure/depth 
      anelastic_methods = fieldnames(VBR.out.anelastic);
      for i_an = 1:length(anelastic_methods)
        ameth = anelastic_methods{i_an};
        % disp(ameth)
        Q = VBR.out.anelastic.(ameth).Q;
        V = VBR.out.anelastic.(ameth).V/1e3;
        % disp(size(V))
        
        VBRBox(i_P).(ameth).Qmean = mean(Q,4); % size is (T,phi,gs)
        VBRBox(i_P).(ameth).Vsmean = mean(V,4); % size is (T,phi,gs)
        % disp(size(VBRBox(i_P).(ameth).Qmean))
        % disp(VBRBox(i_P).(ameth).Qmean(1:5))
        % disp(VBRBox(i_P).(ameth).Vsmean(1:5))
        % pause(5.)
      end 
      
    end 

    disp('    sweep complete: rearranging structure...')
    % re-arrange it all to match what's expected later
    sweepBox(n_T,n_phi,n_gs) = struct();
    for i_state=1:n_T*n_phi*n_gs
        anelastic_methods = VBR.in.anelastic.methods_list;
        for i_an = 1:length(anelastic_methods)
           ameth = anelastic_methods{i_an};
           if isfield(sweepBox(i_state),ameth)==0
               sweepBox(i_state).(ameth) = struct();
           end
           if isfield(sweepBox(i_state).(ameth),'meanQ') == 0 
             sweepBox(i_state).(ameth).meanQ=zeros(nZ,1);
             sweepBox(i_state).(ameth).meanVs=zeros(nZ,1);              
           end
           for i_P = 1:nP
               sweepBox(i_state).(ameth).meanQ(i_P)=VBRBox(i_P).(ameth).Qmean(i_state);
               sweepBox(i_state).(ameth).meanVs(i_P)=VBRBox(i_P).(ameth).Vsmean(i_state);
           end
        end
    end
    disp('    sweep complete!')
end
