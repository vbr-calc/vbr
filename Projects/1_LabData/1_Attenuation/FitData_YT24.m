function VBRc_results = FitData_YT24(use_data)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FitData_YT24()
    %
    % Plots viscosity, modulus, Qinv for borneol near and above the solidus
    % temperature following premelting scaling of Yamauchi and Takei, 2024, JGR.
    %
    % Parameters
    % ----------
    % use_data
    %   if 1, will attempt to fetch data from zenondo
    %
    % Output
    % ------
    % figures to screen and to Projects/1_LabData/1_Attenuation/figures/
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % put VBR in the path
    vbr_path = getenv('vbrdir');
    if isempty(vbr_path)
        vbr_path='../../../';
    end
    addpath(vbr_path)
    vbr_init

    addpath('./functions')

    % check on data
    full_data_dir = 0;
    if use_data == 1
        full_data_dir = download_YT24('data');
    end

    VBRc_results = plot_fig7(full_data_dir);

end

function rgb = get_rgb(Tn, Tn_min, dT)
    clr_sc = (Tn - Tn_min) / dT;
    clr_sc(clr_sc > 1) = 1.0;
    clr_sc(clr_sc < 0) = 0.0;
    rgb = [clr_sc, 0., 1-clr_sc];
end

function VBRc_results = plot_fig7(full_data_dir);

    figure();

    load(fullfile('data','YT16','table3.mat'));
    visc_data.table3_H=table3_H.table3_H;

    combined_data = YT24_load_fig7_combined_data(full_data_dir);
    n_exps = numel(combined_data);

    freq_range = logspace(-4,9,100);
    T_sc_min = 0.3;
    T_sc_max = 1.01;
    dT_rng = T_sc_max - T_sc_min;
    Tsol = 43.0;
    Tvals = [];
    % first plot experimental results
    for i_exp = 1:n_exps
        data = combined_data(i_exp);

        rgb = get_rgb(data.T/Tsol, T_sc_min, dT_rng);
        Tvals = [Tvals, data.T];

        subplot(2,1,1)
        hold all
        semilogx(data.f_normed, data.E_normed, '.', 'markersize', 12, 'color', rgb)
        subplot(2,1,2)
        hold all
        loglog(data.f_normed, data.Qinv, '.', 'markersize', 12, 'color', rgb)
    end

    % now get VBRc results
    VBRc_results = struct();
    for i_exp = 1:n_exps
        data = combined_data(i_exp);

        T = data.T; % celcius
        dg = data.dg_um;
        phi = data.phi;
        rho = data.rho_kgm3;
        VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};
        VBR.in.viscous.methods_list={'xfit_premelt'};
        VBR.in.anelastic.methods_list={'xfit_premelt'};
        VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 1.0;

        VBR.in.viscous.xfit_premelt=setBorneolViscParams();
        VBR.in.viscous.xfit_premelt.dg_um_r = dg; %47.9;
        VBR.in.viscous.xfit_premelt.Tr_K = 46.3 + 273.;
        VBR.in.viscous.xfit_premelt.eta_r = 0.173 * 1e12;
        VBR.in.viscous.xfit_premelt.H = 147*1e3;

        % set anharmonic conditions
        VBR.in.elastic.anharmonic=Params_Elastic('anharmonic');
        % extract reference modulus (E_normed = E / E_u)
        Gu_o = mean(data.E ./ data.E_normed)*1e9;
        % Gu_o is for a given T, specify at elevated TP to skip anharmonic scaling
        VBR.in.elastic.Gu_TP = Gu_o;
        VBR.in.elastic.quiet = 1; % not bothering with K, avoid printing the poisson warning

        % set experimental conditions
        VBR.in.SV.T_K = T+273 ;
        sz=size(VBR.in.SV.T_K);
        VBR.in.SV.dg_um= dg.* ones(sz);
        VBR.in.SV.P_GPa = 1.0132e-04 .* ones(sz); % pressure [GPa]
        VBR.in.SV.rho =rho .* ones(sz); % density [kg m^-3]
        VBR.in.SV.sig_MPa =1000 .* ones(sz)./1e6; % differential stress [MPa]
        VBR.in.SV.Tsolidus_K = Tsol + 273 ;
        disp(T/Tsol)
        VBR.in.SV.phi = phi * ones(sz); % melt fraction
        VBR.in.SV.Ch2o_0=zeros(sz);

        VBR.in.SV.f=freq_range;
        [VBR_bysamp] = VBR_spine(VBR);
        results.Qinv=VBR_bysamp.out.anelastic.xfit_premelt.Qinv;
        results.E=VBR_bysamp.out.anelastic.xfit_premelt.M;
        results.f = VBR.in.SV.f;
        results.f_normed = VBR_bysamp.out.anelastic.xfit_premelt.f_norm;
        results.E_normed = results.E / Gu_o;
        results.T = T;
        results.VBR = VBR_bysamp;
        VBRc_results(i_exp) = results;
    end


    for i_exp = 1:n_exps

        results = VBRc_results(i_exp);
        rgb = get_rgb(results.T/Tsol, T_sc_min, dT_rng);
        % and plot
        subplot(2,1,1)
        hold all
        semilogx(results.f_normed, results.E_normed ,'color', rgb)
        subplot(2,1,2)
        hold all
        loglog(results.f_normed, results.Qinv , 'color', rgb)
    end

    subplot(2,1,1)
    xlim([1e-2,1e9])
    ylim([0,1.1])

    subplot(2,1,2)
    xlim([1e-2,1e9])
    ylim([1e-3,2])
end




function unzipped_data_dir = download_YT24(datadir)
    % downloads, unzips data from zenodo

    unzipped_data_dir = fullfile(datadir,'YT24');
    if exist(datadir) ~= 7
        mkdir(datadir)
        mkdir(unzipped_data_dir)
    end

    YT24data_url = 'https://zenodo.org/api/records/10201689/files-archive';
    zipfilename = '10201689.zip';

    local_data = fullfile(unzipped_data_dir, zipfilename);
    if exist(local_data) ~= 2
        urlwrite(YT24data_url, zipfilename)
        movefile(zipfilename, unzipped_data_dir)
        unzip(local_data, unzipped_data_dir)
    end
end