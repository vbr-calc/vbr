function [SVs, settings] = depth_model(T_K_pot, settings)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate the depth-dependent model given mantle potential temperature
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    z_min = settings.z_min_km;
    z_plate = settings.z_plate_km;
    z_max = settings.z_max_km;
    nz = settings.nz;

    if isfield(settings, 'z_km') == 0
        z_km = transpose(linspace(z_min, z_max, nz));
        settings.z_km = z_km;
    end
    z_km = settings.z_km;

    % temperature and solidus calculations
    T_K = T_K_pot + (z_km - z_min) * settings.dTdz_ad;
    zlith = z_km<=z_plate;
    T_plate = max(T_K(zlith));
    T_surf_K = 300;
    T_K(zlith) = T_surf_K + (T_plate - T_surf_K) * (z_km(zlith) - z_min) / z_plate;

    T_sol_K = settings.T_sol_K_surf + z_km * settings.T_sol_dTdz; % arbitrary solidus

    % density, pressure
    sz = [numel(z_km), 1];
    P_GPa = zeros(sz);
    rho = zeros(sz);

    P_GPa(1) = settings.P0_GPa;
    rho_P = san_carlos_density_from_pressure(P_GPa(1));
    rho(1) = Density_Thermal_Expansion(rho_P, T_K(1), 0.9);
    rho_c_m = 2800/3300;
    if z_km(1) <= settings.z_crust_km
        rho(1) = rho(1) * rho_c_m;
    end

    for i_z = 2:nz
        % project with density just above
        P_GPa(i_z) = P_GPa(i_z-1) + rho(i_z-1) * (z_km(i_z) - z_km(i_z-1)) * 1e3* 9.8/1e9;
        rho_i = san_carlos_density_from_pressure(P_GPa(i_z));
        rho(i_z) = Density_Thermal_Expansion(rho_i, T_K(i_z), 0.9);
        if z_km(i_z) <= settings.z_crust_km
            rho(i_z) = rho(i_z) * rho_c_m;
        end

    end

    SVs.T_K = T_K;
    SVs.Tsolidus_K = T_sol_K;
    SVs.phi = settings.phi_0 * (T_K >=T_sol_K);
    SVs.rho = rho;
    SVs.P_GPa = P_GPa;

end
