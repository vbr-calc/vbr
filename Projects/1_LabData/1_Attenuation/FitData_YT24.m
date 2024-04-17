function VBRc_results = FitData_YT24()
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

    % check on data, download if needed
    full_data_dir = download_YT24('data');

    % get VBRc result and plot along the way
    VBRc_results = plot_fig7(full_data_dir);

end

function rgb = get_rgb(i_exp, Tn, Tn_min, dT)

%    rgba = [
%           0  , 0.4470  , 0.7410;
%           0.8500 ,  0.3250  , 0.0980;
%           0.9290 ,  0.6940  , 0.1250;
%           0.4940 ,  0.1840  , 0.5560;
%           0.4660 ,  0.6740  , 0.1880;
%           0.3010 ,  0.7450  , 0.9330;
%           0.6350 ,  0.0780  , 0.1840;
%           0  , 0.4470  , 0.7410;
%           0.8500 ,  0.3250  , 0.0980;
%           0.9290 ,  0.6940  , 0.1250;
%           0.4940 ,  0.1840  , 0.5560;
%           0.4660 ,  0.6740  , 0.1880;
%           0.3010 ,  0.7450  , 0.9330;
%           0.6350 ,  0.0780  , 0.1840;
%    ];
%    rgba(8:end,:) = rgba(8:end,:) * 0.5;
%
%    rgb = rgba(i_exp,:);
    clr_sc = (Tn - Tn_min) / dT;
    clr_sc(clr_sc > 1) = 1.0;
    clr_sc(clr_sc < 0) = 0.0;
    rgb = [clr_sc, 0., 1-clr_sc];
end

function VBRc_results = plot_fig7(full_data_dir);

    figure('Position', [10 10 500 600],'PaperPosition',[0,0,7,7*6/5],'PaperPositionMode','manual');
    ax_1 = subplot(2,1,1);
    ax_2 = subplot(2,1,2);

    load(fullfile('data','YT16','table3.mat'));
    visc_data.table3_H=table3_H.table3_H;

    combined_data = YT24_load_fig7_combined_data(full_data_dir);

    n_exps = numel(combined_data);

    freq_range = logspace(-6,9,100);
    T_sc_min = 0.889;
    T_sc_max = 1.015;
    dT_rng = T_sc_max - T_sc_min;
    Tsol = 43.0;
    % first plot experimental results
    mod_fac = 1 / ( 1 - 0.031);  % systematic error correction
    for i_exp = 1:n_exps
        data = combined_data(i_exp);

        rgb = get_rgb(i_exp, data.Tn, T_sc_min, dT_rng);
        if data.Tn >= 1
            mrkr = 'o';
            mrkr_sz = 3;
        else
            mrkr = '.';
            mrkr_sz=10;
        end
        Tnlab = num2str(data.Tn, 3+(data.Tn>=1));
        subplot(2,1,1)
        hold_if(i_exp)
        semilogx(data.f_normed, data.E_normed * mod_fac, mrkr, 'markersize', mrkr_sz, 'color', rgb, 'displayname', Tnlab)
        subplot(2,1,2)
        hold_if(i_exp)
        loglog(data.f_normed, data.Qinv, mrkr, 'markersize', mrkr_sz, 'color', rgb, 'displayname', Tnlab)
    end
    subplot(2,1,2)
    leg = legend('Location', 'eastoutside', 'Orientation', 'vertical', ...
                 'AutoUpdate','off','title','T_n','NumColumns',1);

    % now get VBRc results
    VBRc_results = struct();
    for i_exp = 1:n_exps
        data = combined_data(i_exp);

        T = data.T; % celcius
        dg = data.dg_um;
        phi = data.phi;
        rho = data.rho_kgm3;

        VBR.in.elastic.methods_list={'anharmonic';};
        VBR.in.viscous.methods_list={'xfit_premelt'};
        VBR.in.anelastic.methods_list={'xfit_premelt'};
        VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 1.0;
        VBR.in.anelastic.xfit_premelt.tau_pp=2*1e-5;
        % plotting with correction for poro-elastic effect applied, so
        % set effect to 0 here.
        VBR.in.anelastic.xfit_premelt.poro_Lambda = 0.0;

        % set viscous params
        VBR.in.viscous.xfit_premelt=setBorneolViscParams(); % YT2016 values, sample 41
        VBR.in.viscous.xfit_premelt.alpha = 32;  % YT2024 actually fit this

        % set anharmonic conditions
        VBR.in.elastic.anharmonic=Params_Elastic('anharmonic');
        % extract reference modulus (E_normed = E / E_u)
        [Gu_o,dGdT,dGdT_ave]= YT16_E(T);
        Gu_o = Gu_o * 1e9;

        % Gu_o is for a given T, specify at elevated TP to skip anharmonic scaling
        VBR.in.elastic.Gu_TP = Gu_o;
        VBR.in.elastic.quiet = 1; % not bothering with K, avoid printing the poisson warning

        % set experimental conditions
        VBR.in.SV.T_K = T+273 ;
        sz=size(VBR.in.SV.T_K);
        VBR.in.SV.dg_um= dg .* ones(sz); %dg.* ones(sz);
        VBR.in.SV.P_GPa = 1.0132e-04 .* ones(sz); % pressure [GPa]
        VBR.in.SV.rho =rho .* ones(sz); % density [kg m^-3]
        VBR.in.SV.sig_MPa = 1000 .* ones(sz)./1e6; % differential stress [MPa]
        VBR.in.SV.Tsolidus_K = Tsol + 273 ;

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
        rgb = get_rgb(i_exp, (results.T +273)/(Tsol+273), T_sc_min, dT_rng);
        % and plot
        subplot(2,1,1)
        hold_if(i_exp)

        semilogx(results.f_normed, results.E_normed ,'color', rgb)
        subplot(2,1,2)
        hold_if(i_exp)
        loglog(results.f_normed, results.Qinv , 'color', rgb)
    end

    subplot(2,1,1)
    xticklabels([])
    xlim([1e-2,1e9])
    ylim([0,1.1])
    xlabel('f / f_M')
    ylabel("E/E_u")

    subplot(2,1,2)
    xlim([1e-2,1e9])
    ylim([1e-3,2])
    xlabel('f / f_M')
    ylabel("Q^-^1")

    ax2pos = get(ax_2, 'Position');
    ax1pos = get(ax_1, 'Position');

    ax1pos(2) = ax2pos(2) + ax2pos(4); % use the same x axis
    set(ax_1, 'Position', ax1pos)
    set(ax_2, 'Position', ax2pos)

    leg_pos = get(leg, 'Position');
    leg_pos(2) = ax2pos(2);
    set(leg, 'Position', leg_pos)

    saveas(gcf,'./figures/YT24_MQ.png')
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

function hold_if(iterval)
    if iterval > 1
        hold all
    end
end