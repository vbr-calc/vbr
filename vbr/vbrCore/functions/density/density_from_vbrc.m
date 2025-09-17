function rho_TP = density_from_vbrc(P_Pa, T_K, varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rho_TP = density_from_vbrc(P_Pa, T_K, varargin)
    %
    % calculates a temperature and pressure dependent density in two steps:
    %    1. pressure correction: isothermal compression with a bulk modulus with linear pressure dependence.
    %    2. thermal correction: isobaric thermal expansion
    %
    % Parameters
    % ----------
    %
    % P_Pa : array
    %   pressure array in Pa, must be the same shape as T_K
    % T_K : array
    %   temperature array in degrees K, must be the same shape as P_Pa
    % varargin : optional key-value pairs. Possible pairs include:
    %
    %   'reference_scaling', string
    %       The name of the reference scale to use in the parameter structure.
    %       defaults to 'default'.
    %   'params_elastic', structure
    %       The anharmonic parameter structure to use, defaults to Params_Elastic('anharmonic').
    %       Any entry here will be merged with the default structure (with preference given to
    %       the user supplied values)
    %   'rho_o', float
    %       The reference density in kg/m^3. If not set, then will use either the reference scaling if it
    %       has a 'rho_ref' field or 3300 kg/m^3 if it does not. May be an array, in which case it must
    %       match the shape of P_Pa and T_K.
    %   'pressure_scaling, string
    %       the name of the pressure scaling to use. Defaults to the value of the value in
    %       params_elastic.pressure_scaling if it exists, otherwise uses the default in the
    %       Params_Elastic('anharmonic') structure.
    %
    % Examples
    % --------
    %
    % T_K = linspace(800, 1500, 100);
    % P_Pa = linspace(2,3, 100) * 1e9;
    %
    % % use the built in upper mantle scaling:
    % rho_TP = density_from_vbrc(P_Pa, T_K, 'reference_scaling', 'upper_mantle', 'pressure_scaling', 'upper_mantle')
    %
    % % use the default scaling, provide a reference density (defined at the default reference pressure):
    % rho_TP = density_from_vbrc(P_Pa, T_K, 'rho_o', 3310)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%
    % handle varargin %
    %%%%%%%%%%%%%%%%%%%

    input_args = varargin_keyvals_to_structure(varargin);

    % set easy defaults
    defaults.reference_scaling = 'default';
    defaults.params_elastic = Params_Elastic('anharmonic');
    input_args = nested_structure_update(defaults, input_args);

    % less easy defaults
    if strcmp(input_args.reference_scaling, 'default')
        param_struct = input_args.params_elastic;
    else
        param_struct = input_args.params_elastic.(input_args.reference_scaling);
    end

    if ~isfield(input_args, 'rho_o')
        if isfield(param_struct, 'rho_ref')
            rho_o = param_struct.rho_ref;
        else
            rho_o = 3300;
        end
        input_args.rho_o = rho_o;
    end

    if ~isfield(input_args, 'pressure_scaling')
        input_args.pressure_scaling = input_args.params_elastic.pressure_scaling;
    end

    if isfield(param_struct, 'T_K_ref')
        T_K_ref = param_struct.T_K_ref;
    else
        T_K_ref = input_args.params_elastic.T_K_ref;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % the actual calculation %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    dK_dP = input_args.params_elastic.(input_args.pressure_scaling).dK_dP;
    K_o = param_struct.Ku_0 *1e9;
    P_Pa_ref = param_struct.P_Pa_ref;
    rho_P = density_isothermal_compression(P_Pa, input_args.rho_o , K_o, dK_dP, P_Pa_ref);
    rho_TP = density_thermal_expansion(rho_P, T_K, .9, T_K_ref);

end