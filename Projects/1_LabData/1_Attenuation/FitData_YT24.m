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


function VBRc_results = plot_fig7(full_data_dir);

    figure('Position', [10 10 500 600],'PaperPosition',[0,0,7,7*6/5],'PaperPositionMode','manual');
    yheight = 0.4;
    xpos = 0.1;
    ypos = 0.1;
    xwidth = 0.6;
    ax_Q = axes('position', [xpos, ypos, xwidth, yheight]);
    ax_E = axes('position', [xpos, ypos + yheight, xwidth, yheight]);
    leg_pos = [xpos+xwidth+0.05, ypos, 0.2, yheight];


    load(fullfile('data','YT16','table3.mat'));
    visc_data.table3_H=table3_H.table3_H;

    combined_data = YT24_load_fig7_combined_data(full_data_dir);

    n_exps = numel(combined_data);

    freq_range = logspace(-6,9,100);
    Tsol = 43.0;

    % get VBRc results
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
        % VBR.in.anelastic.xfit_premelt.tau_pp=2*1e-5;
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
        results.Tn = VBR.in.SV.T_K  / VBR.in.SV.Tsolidus_K ;
        results.VBR = VBR_bysamp;
        VBRc_results(i_exp) = results;
    end


    for i_exp = 1:n_exps
        if i_exp == 2
            linesty = '--';
        else
            linesty = '-';
        end
        results = VBRc_results(i_exp);
        rgb = vbr_categorical_color(i_exp);
        Tnlab = num2str(results.Tn, 3+(results.Tn>=1));
        axes(ax_E)
        hold_if(i_exp)
        semilogx(results.f_normed, results.E_normed ,'color', rgb, ...
                 'linewidth', 1.5, 'linestyle', linesty)
        axes(ax_Q)
        hold_if(i_exp)
        loglog(results.f_normed, results.Qinv , 'color', rgb, ...
              'linewidth', 1.5, 'displayname', Tnlab, 'linestyle', linesty)
    end

    % plot experimental results
    delta_systematic = 0.031;

    for i_exp = 1:n_exps
        data = combined_data(i_exp);
        dporo = data.dporo * data.phi;
        mod_fac = 1 / ( 1 - delta_systematic) / (1 - dporo);  % correction factor
        rgb = vbr_categorical_color(i_exp);
        if data.Tn >= 1
            mrkr = 'o';
            mrkr_sz = 5;
            mkr_fc = 'w';
        else
            mrkr = '.';
            mrkr_sz=15;
            mkr_fc = rgb;
        end
        Tnlab = num2str(data.Tn, 3+(data.Tn>=1));
        axes(ax_E)
        hold_if(i_exp)
        semilogx(data.f_normed, data.E_normed * mod_fac, mrkr, ...
                 'markersize', mrkr_sz, 'color', rgb, 'displayname', Tnlab, ...
                 'MarkerFaceColor', mkr_fc)
        axes(ax_Q)
        hold_if(i_exp)
        loglog(data.f_normed, data.Qinv, mrkr, 'markersize', mrkr_sz, ....
               'color', rgb, 'displayname', Tnlab, 'MarkerFaceColor', mkr_fc)
    end
    axes(ax_Q)
    leg = legend('Location', 'eastoutside', 'Orientation', 'vertical', ...
                 'AutoUpdate','off','title','T_n','NumColumns',1);

    axes(ax_E)
    xticklabels([])
    xlim([1e-2,1e9])
    ylim([0,1.1])
    xlabel('f / f_M')
    ylabel("E/E_u")

    axes(ax_Q)
    xlim([1e-2,1e9])
    ylim([1e-3,2])
    xlabel('f / f_M')
    ylabel("Q^-^1")

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