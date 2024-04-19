function combined_data_final = YT24_load_fig7_combined_data(full_data_dir)

    combined_data = struct();
    % pull all data for sample 41 first T cycle
    sample_id= 41;
    [current_run, sample_info] = load_sample_data(sample_id, full_data_dir);

    start_end = sample_info.first_Tcycle_index_start_stop;
    i_Tstart = start_end(1);
    i_Tend = start_end(2);

    i_data = 1;
    Tsol = 43;
    Tvals = [];
    for iT = i_Tstart: i_Tend
        combined_data(i_data) = extract_single_experiment(current_run, sample_info, iT, Tsol, sample_id);
        Tvals = [Tvals, combined_data(i_data).Tn];
        i_data = i_data + 1;
    end

    for sample_id = 42:8:50  % 42, 50
        [current_run, sample_info] = load_sample_data(sample_id, full_data_dir);
        start_end = sample_info.first_Tcycle_index_start_stop;
        i_Tstart = start_end(1);
        i_Tend = start_end(2);
        for iT = i_Tstart: i_Tend
            if current_run(iT).T >= Tsol
                combined_data(i_data) = extract_single_experiment(current_run, sample_info, iT, Tsol, sample_id);
                Tvals = [Tvals, combined_data(i_data).Tn];
                i_data =  i_data + 1;
            end
        end
    end



    % finally, re-order based on homologous temperature
    [sorted_T, idx] = sort(Tvals);
    for isamp = 1:numel(combined_data)
        combined_data_final(isamp) = combined_data(idx(isamp));
    end

end

function single_exp = extract_single_experiment(current_run, sample_info, iT, Tsol, sample_id)
    T = current_run(iT).T; % celcius
    cdata = current_run(iT).data;
    single_exp.T = T;
    single_exp.Tn = (T + 273.0) / (Tsol+273); % homologous temperature
    single_exp.f = cdata(:,1);
    single_exp.f_normed = cdata(:,2);
    single_exp.E = cdata(:,3);
    single_exp.E_normed = cdata(:,4);
    single_exp.Qinv = cdata(:,5);


    phi = sample_info.phi * (T >= Tsol);
    single_exp.phi = phi;
    single_exp.dg_um = sample_info.dg_um;
    single_exp.sample_id = sample_id;
    single_exp.rho_kgm3 = sample_info.rho_kgm3;
    single_exp.dporo = (phi > 0) * sample_info.dporo;
end

function [run_data, sample_info] = load_sample_data(sample_number, full_data_dir)

    sample_str = num2str(sample_number);
    sample_file = fullfile(full_data_dir, ['anela',sample_str,'.mat']);
    struct_name = ['anela',sample_str];
    sample_data = load(sample_file); % e.g., sample_data.anela42
    data = getfield(sample_data, struct_name); % e.g., anela42

    run_data = data.run;
    sample_info = get_sample_info(sample_number);
end



function sample_data = get_sample_info(sample_number)

    if sample_number == 50
        sample_data.dg_um = 47.9;
        sample_data.rho_kgm3 = 1.0111;
        sample_data.phi = 0.0368;
        sample_data.eta_r = 1061*1e12;
        sample_data.first_Tcycle_index_start_stop = [2, 9];
        sample_data.nT = 8;
        sample_data.dporo = 0.135;
    elseif sample_number == 42
        sample_data.dg_um = 46.3;
        sample_data.rho_kgm3 = 1.0111;
        sample_data.phi = 0.016;
        sample_data.eta_r = 132 * 1e12;
        sample_data.first_Tcycle_index_start_stop = [2, 8];
        sample_data.nT = 7;
        sample_data.dporo = 0.0585;
    elseif sample_number == 41
        sample_data.dg_um = 34.2;
        sample_data.rho_kgm3 = 1.0111;
        sample_data.phi = 0.004;
        sample_data.eta_r = 1433 * 1e12;
        sample_data.first_Tcycle_index_start_stop = [3, 10];
        sample_data.nT = 8;
        sample_data.dporo = 0.0178;
    end

end