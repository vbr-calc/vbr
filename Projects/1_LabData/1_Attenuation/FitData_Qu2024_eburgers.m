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
  
    % set elastic, anelastic methods, load parameters
    VBR0.in.elastic.methods_list={'anharmonic'};
    VBR0.in.anelastic.methods_list={'eburgers_psp'};      
    VBR0.in.elastic.anharmonic=Params_Elastic('anharmonic'); %
    VBR0.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');
    % temperature range
    VBR0.in.SV.T_K=700:50:1350;
    VBR0.in.SV.T_K=VBR0.in.SV.T_K+273;
    T_min_K = min(VBR0.in.SV.T_K);
    T_max_K = max(VBR0.in.SV.T_K);
    n_T = numel(VBR0.in.SV.T_K);
    sz=size(VBR0.in.SV.T_K); % temperature [K]
    VBR0.in.SV.P_GPa = 0.2 * ones(sz); % pressure [GPa]
    VBR0.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
    VBR0.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
    VBR0.in.SV.phi = 0.0 * ones(sz); % melt fraction

    % frequencies to calculate at
    VBR0.in.SV.f = 1./logspace(-.1,3.1,50);

    sample_ids = {'A1802';'A1906'; 'A1928'};
    
    VBRresults = struct();
    for isample = 1:numel(sample_ids)
        
        sample_name = sample_ids{isample};
        disp(["Forward VBRc calculation with sample fit ", sample_name])
        VBR = VBR0; 
        VBR.in.anelastic.eburgers_psp.eBurgerFit=sample_name; % 'bg_only' or 'bg_peak' or 's6585_bg_only'
                          
        GU=VBR.in.anelastic.eburgers_psp.(sample_name).G_UR;
        TR=VBR.in.anelastic.eburgers_psp.(sample_name).TR;
        PR=VBR.in.anelastic.eburgers_psp.(sample_name).PR*1e9;
        VBR.in.elastic.anharmonic.Gu_0_ol = GU; 
        VBR.in.elastic.anharmonic.T_K_ref = TR;
        VBR.in.elastic.anharmonic.P_Pa_ref = PR;
        % set the grain size to the average size of the sample
        dg_um = VBR.in.anelastic.eburgers_psp.(sample_name).dR; 
        VBR.in.SV.dg_um=dg_um*ones(sz);    

        % run it initially (eburgers_psp uses high-temp background only by default)
        [VBR] = VBR_spine(VBR) ;

        VBRresults.(sample_name) = VBR; 
    end 

    % load data if it exists
    data = load_Qu2024_data();
  
    %% ====================================================
    %% Display some things ================================
    %% ====================================================
    
    figure;
    n_samples = numel(sample_ids);
    for isample = 1:n_samples
        sample_name = sample_ids{isample};
        VBR = VBRresults.(sample_name);
        logper=1./VBR.in.SV.f;

        for iTemp = 1:numel(VBR.in.SV.T_K)
            M=squeeze(VBR.out.anelastic.eburgers_psp.M(1,iTemp,:)/1e9);      
            Qinv=squeeze(VBR.out.anelastic.eburgers_psp.Qinv(1,iTemp,:));
            RGB = normalize_color(VBR.in.SV.T_K(iTemp), T_min_K, T_max_K, iTemp);            
            
            subplot(n_samples,2,isample*2-1)
            hold on
            semilogx(logper,M,'color',RGB,'LineWidth',2);
            
            subplot(n_samples,2,isample*2)
            hold on
            loglog(logper,Qinv,'color',RGB,'LineWidth',2);
        end 

        subplot(n_samples,2,isample*2-1)
        ylabel(['M [GPa] : ', sample_name])
        box on
        subplot(n_samples,2,isample*2)
        ylabel('log10 Q^{-1}')        
        box on
    end 

    if numfields(data) > 0
        for isample = 1:n_samples
            sdata = data.(sample_name);
            for iTemp = 1:numel(sdata.T_K)
                T_K = sdata.T_K(iTemp);
                Qinv = 10.^sdata.logQs_inv(iTemp);                
                G_GPa = sdata.G_GPa(iTemp);
                period = 10.^sdata.log_period(iTemp);                
                dT = abs(T_K - VBR0.in.SV.T_K);
                iTemp_other = find(dT == min(dT));                
                RGB = normalize_color(T_K, T_min_K, T_max_K, iTemp_other);            

                subplot(n_samples,2,isample*2-1)
                hold on
                semilogx(period, G_GPa,'color',RGB, 'linestyle', 'none', 'marker', '.', 'markersize', 12);
                
                subplot(n_samples,2,isample*2)
                hold on
                semilogy(period,Qinv,'color',RGB, 'linestyle', 'none', 'marker', '.', 'markersize', 12);
                ylim([-2.3, .3])

            end 
        end 
    end 
    
    saveas(gcf,'./figures/Qu2024_eBurgers.png')
  end
  


function RGB = normalize_color(T_K, T_min_K, T_max_K, i_T)
    % R = (T_K - T_min_K) / (T_max_K - T_min_K);
    % G = 0.;
    % B = 1 - R; 
    % RGB = [R, G, B];
    % RGB(RGB<0) = 0;
    % RGB(RGB>1) = 1;

    RGB = vbr_categorical_color(i_T);
end 