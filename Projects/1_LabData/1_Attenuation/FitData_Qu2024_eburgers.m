function FitData_Qu2024_eBurgers()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FitData_Qu2024_eBurgers()    
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
    vbr_init
  
    % set elastic, anelastic methods, load parameters
    VBR0.in.elastic.methods_list={'anharmonic'};
    VBR0.in.anelastic.methods_list={'eburgers_psp'};      
    VBR0.in.elastic.anharmonic=Params_Elastic('anharmonic'); %
    VBR0.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');
    % temperature range
    VBR0.in.SV.T_K=700:50:1200;
    VBR0.in.SV.T_K=VBR0.in.SV.T_K+273;
    sz=size(VBR0.in.SV.T_K); % temperature [K]
    VBR0.in.SV.P_GPa = 0.2 * ones(sz); % pressure [GPa]
    VBR0.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
    VBR0.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
    VBR0.in.SV.phi = 0.0 * ones(sz); % melt fraction

    % frequencies to calculate at
    VBR0.in.SV.f = 1./logspace(-2,4,100);

    sample_ids = {'A1802';'A1906'; 'A1928'};
    
    VBRresults = struct();

    for isample = 1:numel(sample_ids)
        sample_name = sample_ids{isample};

        VBR = VBR0; 
        VBR.in.anelastic.eburgers_psp.eBurgerFit=sample_name; % 'bg_only' or 'bg_peak' or 's6585_bg_only'
  
        % JF10 have Gu_0=62.5 GPa, but that's at 900 Kelvin and 0.2 GPa,
        % so set Gu_0_ol s.t. it ends up at 62.5 at those conditions
        dGdT=VBR.in.elastic.anharmonic.isaak.dG_dT;
        dGdP=VBR.in.elastic.anharmonic.cammarano.dG_dP;
        Tref=VBR.in.elastic.anharmonic.T_K_ref;
        Pref=VBR.in.elastic.anharmonic.P_Pa_ref/1e9;
        GUJF10=VBR.in.anelastic.eburgers_psp.s6585_bg_only.G_UR;
        VBR.in.elastic.anharmonic.Gu_0_ol = GUJF10 - (900+273-Tref) * dGdT/1e9 - (0.2-Pref)*dGdP; % olivine reference shear modulus [GPa]
  
        % set the grain size to the average size of the sample
        dg_um = VBR.in.anelastic.eburgers_psp.(sample_name).dR; 
        VBR.in.SV.dg_um=dg_um*ones(sz);    

        % run it initially (eburgers_psp uses high-temp background only by default)
        [VBR] = VBR_spine(VBR) ;

        VBRresults.(sample_name) = VBR; 
    end 

    % load data if it exists
    data = tryDataLoad();
  
    %% ====================================================
    %% Display some things ================================
    %% ====================================================
    
    figure;

    n_samples = numel(sample_ids);
    for isample = 1:n_samples
        sample_name = sample_ids{isample};
        VBR = VBRresults.(sample_name);
        logper=log10(1./VBR.in.SV.f);

        for iTemp = 1:numel(VBR.in.SV.T_K)
            M=squeeze(VBR.out.anelastic.eburgers_psp.M(1,iTemp,:)/1e9);      
            Qinv=squeeze(VBR.out.anelastic.eburgers_psp.Qinv(1,iTemp,:));   

      
            R=(iTemp-1) / (numel(VBR.in.SV.T_K)-1);
            B=1 - (iTemp-1) / (numel(VBR.in.SV.T_K)-1);
            
            subplot(n_samples,2,isample*2-1)
            hold on
            plot(logper,M,'color',[R,0,B],'LineWidth',2);
            
            subplot(n_samples,2,isample*2)
            hold on
            semilogy(logper,Qinv,'color',[R,0,B],'LineWidth',2);
            
        end 

        subplot(n_samples,2,isample*2-1)
        ylabel(['M [GPa] : ', sample_name])
        box on
        subplot(n_samples,2,isample*2)
        ylabel('log10 Q^{-1}')
        box on
    end 
    
  
  
    %   if isfield(data,'Qinv')
    %     theT=VBR.in.SV.T_K(iTemp);
    %     disp(['plotting data for T=',num2str(theT-273)])
    %     expQinvPer=log10(data.Qinv.period_s(data.Qinv.T_K==theT));
    %     expQinv=log10(data.Qinv.Qinv(data.Qinv.T_K==theT));
    %     expGPer=log10(data.G.period_s(data.G.T_K==theT));
    %     expG=data.G.G(data.G.T_K==theT);
  
    %     subplot(2,2,1)
    %     hold on
    %     plot(expGPer,expG,'.','color',[R,0,B],'markersize',10);
    %     subplot(2,2,3)
    %     hold on
    %     plot(expGPer,expG,'.','color',[R,0,B],'markersize',10);
  
    %     subplot(2,2,2)
    %     hold on
    %     plot(expQinvPer,expQinv,'.','color',[R,0,B],'markersize',10);
    %     subplot(2,2,4)
    %     hold on
    %     plot(expQinvPer,expQinv,'.','color',[R,0,B],'markersize',10);
    %   end
    % end
  
    saveas(gcf,'./figures/Qu2024_eBurgers.eps','epsc')
  end
  
  function data = tryDataLoad()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % loads data if available
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dataDir = getenv('vbrPublicData');

    fi = [dataDir, filesep, 'Qu_etal_2024', filesep, 'Qu_2024_data.mat'];
    if exist(fi,'file')
      disp(['found Qu et al 2024 file at:', fi])
      data = load(fi);
    else
      msg = ['Qu et al 2024 data not found. ', ...
             'Clone https://github.com/vbr-calc/vbrPublicData (outside the vbr repo dir) ',...
             ' and set the vbrPublicData environment variable to point to /the/path/to/vbrPublicData'];
      disp(msg)
      data = 0;
    end
  end
  