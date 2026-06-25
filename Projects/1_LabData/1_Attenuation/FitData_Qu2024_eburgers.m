function FitData_Qu2024_eburgers()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FitData_Qu2024_eburgers()
    %
    % Parameters
    % ----------
    % None
    %
    % Output
    % ------
    % figures to screen and to Projects/1_LabData/1_Attenuation/figures/
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear

    vbr_path = getenv('vbrdir');
    if isempty(vbr_path)
        vbr_path='../../../';
    end
    addpath(vbr_path)
    addpath('./functions')
    vbr_init


    sample_ids = {'A1802';'A1906'; 'A1928'};
    sample_temps.A1802.Tmin_C = 900;
    sample_temps.A1802.Tmax_C = 1200;
    sample_temps.A1906.Tmin_C = 900;
    sample_temps.A1906.Tmax_C = 1300;
    sample_temps.A1928.Tmin_C = 950;
    sample_temps.A1928.Tmax_C = 1300;

    global_T_min_max_K = [900, 1300] + 273;
    global_T_K = global_T_min_max_K(1):50:global_T_min_max_K(2);

    VBRresults = struct();
    for isample = 1:numel(sample_ids)
        sample_name = sample_ids{isample};
        disp(["Forward VBRc calculation with sample fit ", sample_name])
        VBRresults.(sample_name) = sample_VBR(sample_name, sample_temps);

        T_K = VBRresults.(sample_name).in.SV.T_K;
        T_K_cmap = ones(size(T_K));
        for iT = 1:numel(T_K);
            T_K_cmap(iT) = find(global_T_K-T_K(iT) == 0);
        end
        VBRresults.(sample_name).T_K_cmap = T_K_cmap;
    end



    % load data if it exists
    data = load_Qu2024_data();
    plot_data = true;
    for isample = 1:numel(sample_ids)
        sample_name = sample_ids{isample};
        VBR = VBRresults.(sample_name);
        plot_VBR_and_sample(sample_name, sample_temps, VBR, data, plot_data, global_T_K);
    end

    for isample = 1:numel(sample_ids)
        sample_name = sample_ids{isample};
        plot_T_dep(sample_name, sample_temps, data);
    end

    compare_to_ave_fit(sample_ids, sample_temps, data, VBRresults, global_T_K, plot_data);


  end


function RGB = normalize_color(i_T)
    RGB = vbr_categorical_color(i_T);
end


function VBR = sample_VBR(sample_name, sample_temps)

    % set elastic, anelastic methods, load parameters
    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.anelastic.methods_list={'eburgers_psp'};
    VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); %
    VBR.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');

    % temperature range
    T_min_K = sample_temps.(sample_name).Tmin_C + 273;
    T_max_K = sample_temps.(sample_name).Tmax_C + 273;
    VBR.in.SV.T_K=T_min_K:50:T_max_K;

    n_T = numel(VBR.in.SV.T_K);
    sz=size(VBR.in.SV.T_K); % temperature [K]
    VBR.in.SV.P_GPa = 0.2 * ones(sz); % pressure [GPa]
    VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
    VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
    VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction

    % frequencies to calculate at
    VBR.in.SV.f = 1./logspace(-.5,3.5,50);

    VBR.in.anelastic.eburgers_psp.eBurgerFit=sample_name; % 'bg_only' or 'bg_peak' or 's6585_bg_only'

    % set the reference anharmonic properties
    GU=VBR.in.anelastic.eburgers_psp.(sample_name).G_UR;
    TR=VBR.in.anelastic.eburgers_psp.(sample_name).TR;
    PR=VBR.in.anelastic.eburgers_psp.(sample_name).PR*1e9;
    VBR.in.elastic.anharmonic.Gu_0_ol = GU;
    VBR.in.elastic.anharmonic.T_K_ref = TR;
    VBR.in.elastic.anharmonic.P_Pa_ref = PR;
    % VBR.in.elastic.anharmonic.isaak.dG_dT = -0.016 * 1e9;
    % set the grain size to the average size of the sample
    dg_um = VBR.in.anelastic.eburgers_psp.(sample_name).dR;
    VBR.in.SV.dg_um=dg_um*ones(sz);

    % run it initially (eburgers_psp uses high-temp background only by default)
    [VBR] = VBR_spine(VBR) ;
end

function compare_to_ave_fit(sample_ids, sample_temps, data, VBRresults,global_T_K, plot_data)

    % calculate with the average fit
    sample_temps.Qu2024.Tmin_C = 900;
    sample_temps.Qu2024.Tmax_C = 1300;
    VBR_ave = sample_VBR('Qu2024', sample_temps);

    % pick some temps to compare at
    Target_T_K_vals = [900, 1000, 1100, 1200, 1300] + 273;

    figure()
    for iTarget = 1:numel(Target_T_K_vals)
        Target_T_K = Target_T_K_vals(iTarget);
        iTemp = find(VBR_ave.in.SV.T_K - Target_T_K == 0);
        M=squeeze(VBR_ave.out.anelastic.eburgers_psp.M(1,iTemp,:)/1e9);
        Qinv=squeeze(VBR_ave.out.anelastic.eburgers_psp.Qinv(1,iTemp,:));
        logper=log10(1./VBR_ave.in.SV.f);

        iTemp_cmap = find(global_T_K - Target_T_K == 0);
        RGB = normalize_color(iTemp_cmap);

        subplot(1,2,1)
        hold on
        plot(logper,M,'color',RGB,'LineWidth',2, 'displayname','Qu2024');


        subplot(1,2,2)
        hold on
        plot(logper,log10(Qinv),'color',RGB,'LineWidth',2);

        % plot the fits
        for isample = 1:numel(sample_ids)
            sample_name = sample_ids{isample};
            VBR = VBRresults.(sample_name);

            if Target_T_K <= max(VBR.in.SV.T_K)
                iTemp = find(VBR.in.SV.T_K - Target_T_K == 0);

                M=squeeze(VBR.out.anelastic.eburgers_psp.M(1,iTemp,:)/1e9);
                Qinv=squeeze(VBR.out.anelastic.eburgers_psp.Qinv(1,iTemp,:));
                iTemp_cmap = VBR.T_K_cmap(iTemp);
                RGB = normalize_color(iTemp_cmap);

                subplot(1,2,1)
                hold on
                plot(logper,M,'color',RGB,'LineWidth',1, 'linestyle','--','displayname',sample_name);

                subplot(1,2,2)
                hold on
                plot(logper,log10(Qinv),'color',RGB,'linestyle','--','LineWidth',1);
            end

            if numfields(data) > 0 && plot_data
                sdata = data.(sample_name);
                unique_T_vals = unique(sdata.T_C);
                T_val_C = Target_T_K - 273;
                T_sample_min =  sample_temps.(sample_name).Tmin_C;
                T_sample_max =  sample_temps.(sample_name).Tmax_C;
                if T_val_C >= T_sample_min && T_val_C <= T_sample_max;
                    T_mask = sdata.T_C == T_val_C;
                    Qinv = sdata.log_Qinv(T_mask);
                    G_GPa = sdata.G_GPa(T_mask);
                    period = sdata.log_period_s(T_mask);

                    iTemp_cmap = find(global_T_K - Target_T_K == 0);
                    RGB = normalize_color(iTemp_cmap);

                    subplot(1,2,1)
                    hold on
                    plot(period, G_GPa,'color',RGB, 'linestyle', 'none', 'marker', '.','MarkerSize',14);

                    subplot(1,2,2)
                    hold on
                    plot(period,Qinv,'color',RGB, 'linestyle', 'none', 'marker', '.', 'MarkerSize',14);
                end
            end
        end

    end
    subplot(1,2,1)
    ylabel(['M [GPa]'])
    ylim([0, 80])
    logperrange = [min(logper), max(logper)];
    xlim(logperrange)
    title("Comparison to average fit")
    box on

    subplot(1,2,2)
    ylim([-2.5, .3])
    xlim(logperrange)
    ylabel('log10 Q^{-1}')
    box on

    saveas(gcf,'./figures/Qu2024_eBurgers_ave_fit.png')
end

function plot_T_dep(sample_name, sample_temps, data)
    % set elastic, anelastic methods, load parameters

    VBR = struct();
    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); %

    % temperature range
    VBR.in.SV.T_K=200:10:1400 + 273;

    n_T = numel(VBR.in.SV.T_K);
    sz=size(VBR.in.SV.T_K); % temperature [K]
    VBR.in.SV.P_GPa = 0.2 * ones(sz); % pressure [GPa]
    VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
    VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction

    % set the reference anharmonic properties
    e_psp=Params_Anelastic('eburgers_psp');
    GU=e_psp.(sample_name).G_UR;
    TR=e_psp.(sample_name).TR;
    PR=e_psp.(sample_name).PR*1e9;

    VBR.in.elastic.anharmonic.Gu_0_ol = GU;
    VBR.in.elastic.anharmonic.T_K_ref = TR;
    VBR.in.elastic.anharmonic.P_Pa_ref = PR;

    % run it initially (eburgers_psp uses high-temp background only by default)
    [VBR] = VBR_spine(VBR) ;

    Gu = VBR.out.elastic.anharmonic.Gu;

    figure()
    plot(VBR.in.SV.T_K-273, Gu/1e9, 'k', 'displayname', 'Gu0')
    hold on

    if numfields(data) > 0
        sdata = data.(sample_name);
        unique_per = unique(sdata.log_period_s);
        iperiods = [1, 4, 7, 10];
        for iper = 1:numel(iperiods)
            per_val = unique_per(iperiods(iper));

            per_mask = sdata.log_period_s == per_val;

            T_vals = sdata.T_C(per_mask);
            G_vals = sdata.G_GPa(per_mask);
            RGB = vbr_categorical_color(iper+20);
            plot(T_vals(T_vals>370), G_vals(T_vals>370), '.', ...
                 'markersize', 12, 'color',RGB, ...
                 'displayname', [num2str(10.^per_val), ' s'])
        end
    end
    xlabel('T [C]')
    ylabel('G')
    xlim([200, 1500])
    ylim([20, 80])
    title(sample_name)
    legend('location','southwest')

    saveas(gcf,['./figures/Qu2024_eBurgers_',sample_name, '_T_dependence.png'])
end


function plot_VBR_and_sample(sample_name, sample_temps, VBR, data, plot_data, global_T_K)

    figure('PaperPosition',[0,0,8,4],'PaperPositionMode','manual')
    logper=log10(1./VBR.in.SV.f);
    T_sample_min =  sample_temps.(sample_name).Tmin_C;
    T_sample_max =  sample_temps.(sample_name).Tmax_C;
    for iTemp = 1:numel(VBR.in.SV.T_K)
        T_val_C = VBR.in.SV.T_K(iTemp) - 273;
        if T_val_C >= T_sample_min && T_val_C <= T_sample_max;
            M=squeeze(VBR.out.anelastic.eburgers_psp.M(1,iTemp,:)/1e9);
            Qinv=squeeze(VBR.out.anelastic.eburgers_psp.Qinv(1,iTemp,:));
            iTemp_cmap = VBR.T_K_cmap(iTemp);
            RGB = normalize_color(iTemp_cmap);

            subplot(1,2,1)
            hold on
            plot(logper,M,'color',RGB,'LineWidth',2);

            subplot(1,2,2)
            hold on
            plot(logper,log10(Qinv),'color',RGB,'LineWidth',2);
        end
    end


    if numfields(data) > 0 && plot_data
        sdata = data.(sample_name);
        unique_T_vals = unique(sdata.T_C);
        for iTemp = 1:numel(unique_T_vals)
            T_val_C = unique_T_vals(iTemp);
            T_K =  T_val_C + 273;
            T_sample_min =  sample_temps.(sample_name).Tmin_C;
            T_sample_max =  sample_temps.(sample_name).Tmax_C;
            if T_val_C >= T_sample_min && T_val_C <= T_sample_max;
                T_mask = sdata.T_C == T_val_C;
                Qinv = sdata.log_Qinv(T_mask);
                G_GPa = sdata.G_GPa(T_mask);
                period = sdata.log_period_s(T_mask);

                iTemp_cmap = find(global_T_K - T_K == 0);
                RGB = normalize_color(iTemp_cmap);

                subplot(1,2,1)
                hold on
                plot(period, G_GPa,'color',RGB, 'linestyle', 'none', 'marker', '.','MarkerSize',14);

                subplot(1,2,2)
                hold on
                plot(period,Qinv,'color',RGB, 'linestyle', 'none', 'marker', '.', 'MarkerSize',14);
            end
        end
    end

    subplot(1,2,1)
    ylabel(['M [GPa] : ', sample_name])
    ylim([0, 80])
    logperrange = [min(logper), max(logper)];
    xlim(logperrange)
    title(sample_name)
    box on

    subplot(1,2,2)
    ylim([-2.5, .3])
    xlim(logperrange)
    ylabel('log10 Q^{-1}')
    box on

    saveas(gcf,['./figures/Qu2024_eBurgers_',sample_name, '.png'])

end
