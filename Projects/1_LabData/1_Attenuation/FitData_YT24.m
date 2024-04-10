function FitData_YT24(use_data)
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


    plot_fig2(full_data_dir)





end


function plot_fig2(full_data_dir)

    f1 = figure();
    f2 = figure();

    samp_nums = [41]%, 42, 50];

    load(fullfile('data','YT16','table3.mat'));
    visc_data.table3_H=table3_H.table3_H;

    for isamp = 1:numel(samp_nums)
        samp_num = samp_nums(isamp);

        current_run = load_sample_data(samp_num, full_data_dir);
        sample_data = get_sample_info(samp_num);

        T_arr = [];
        for iT = 1:numel(current_run)  % temperature loop
            T_arr =[T_arr, current_run(iT).T];
        end
        min_T  = min(T_arr);
        max_T  = max(T_arr);
        dT = max_T - min_T;

        dg = sample_data.dg_um;
        phi = sample_data.phi;
        eta_r = sample_data.eta_r;
        rho = sample_data.rho_kgm3;
        for iT = 1:numel(current_run)  % temperature loop
            T = current_run(iT).T; % celcius

            VBR.in=struct();
            VBR.in.elastic.methods_list={'anharmonic';};
            VBR.in.viscous.methods_list={'xfit_premelt'};
            VBR.in.anelastic.methods_list={'xfit_premelt'};
            VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 1.0;

            % set this sample's viscosity parameters
            VBR.in.viscous.xfit_premelt=setBorneolParams();
            VBR.in.viscous.xfit_premelt.dg_um_r=dg;
            VBR.in.viscous.xfit_premelt.Tr_K=min_T+273;
            VBR.in.viscous.xfit_premelt.eta_r=eta_r;
            VBR.in.viscous.xfit_premelt.H = 147 * 1e3;

            disp(VBR.in.viscous.xfit_premelt)
            % set anharmonic conditions
            VBR.in.elastic.anharmonic=Params_Elastic('anharmonic');
            [Gu_o,dGdT,dGdT_ave]= YT16_E(T);
            Gu_o=Gu_o-0.05;

            % Gu_o is for a given T, set anharmonic derives to 0
            VBR.in.elastic.anharmonic.Gu_0_ol = Gu_o;
            VBR.in.elastic.anharmonic.dG_dT = 0;
            VBR.in.elastic.anharmonic.dG_dP = 0;

            % adjust some anelastic settings
            VBR.in.anelastic.xfit_premelt.tau_pp=2*1e-5;


            % set experimental conditions
            VBR.in.SV.T_K = T+273 ;
            sz=size(VBR.in.SV.T_K);
            VBR.in.SV.dg_um= dg.* ones(sz);
            VBR.in.SV.P_GPa = 1.0132e-04 .* ones(sz); % pressure [GPa]
            VBR.in.SV.rho =rho .* ones(sz); % density [kg m^-3]
            VBR.in.SV.sig_MPa =1000 .* ones(sz)./1e6; % differential stress [MPa]
            VBR.in.SV.Tsolidus_K = 43.0 + 273 ;
            VBR.in.SV.phi = ones(sz) * phi * (T >= 43.); % melt fraction
            VBR.in.SV.Ch2o_0=zeros(sz);

            VBR.in.SV.f=logspace(-4,2,50);
            [VBR_bysamp] = VBR_spine(VBR);
            VBR_Qinv_samp=VBR_bysamp.out.anelastic.xfit_premelt.Qinv;
            VBR_G_samp=VBR_bysamp.out.anelastic.xfit_premelt.M/1e9;


            r = (T - min_T) / dT;
            b = 1 - r;
            rgb = [r, 0.0, b];

            cdata = current_run(iT).data;
            f = cdata(:,1);
            f_normed = cdata(:,2);
            E = cdata(:,3);
            E_normed = cdata(:,4);
            Qinv =  cdata(:,5);

            set(0, 'currentfigure', f1);
            subplot(2, 3, 1+(isamp-1))
            hold all
            semilogx(f, E, '.', 'color', rgb)
            semilogx(VBR.in.SV.f, VBR_G_samp, 'color', rgb)

            ylim([0.25, 2.75])

            subplot(2, 3, 3+isamp)
            hold all
            loglog(f, Qinv,'.', 'color', rgb)
            loglog(VBR.in.SV.f, VBR_Qinv_samp, 'color', rgb)

            ylim([1e-3, 2])

            set(0, 'currentfigure', f2);
            subplot(2, 3, 1+(isamp-1))
            hold all
            semilogx(f_normed, E_normed, '.', 'color', rgb)

            subplot(2, 3, 3+isamp)
            hold all
            loglog(f_normed, Qinv,'.', 'color', rgb)

        end
    end



end

function run_data = load_sample_data(sample_number, full_data_dir)

    sample_str = num2str(sample_number);
    sample_file = fullfile(full_data_dir, ['anela',sample_str,'.mat']);
    struct_name = ['anela',sample_str];
    sample_data = load(sample_file); % e.g., sample_data.anela42
    data = getfield(sample_data, struct_name); % e.g., anela42
    run_data = data.run;
end


function sample_data = get_sample_info(sample_number)
    if sample_number == 50
        sample_data.dg_um = 47.9;
        sample_data.rho_kgm3 = 1.0111;
        sample_data.phi = 0.0368;
        sample_data.eta_r = 1061*1e12;
    elseif sample_number == 42
        sample_data.dg_um = 46.3;
        sample_data.rho_kgm3 = 1.0111;
        sample_data.phi = 0.016;
        sample_data.eta_r = 132 * 1e12;
    elseif sample_number == 41
        sample_data.dg_um = 34.2;
        sample_data.rho_kgm3 = 1.0111;
        sample_data.phi = 0.004;
        sample_data.eta_r = 1433 * 1e12;
    end

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