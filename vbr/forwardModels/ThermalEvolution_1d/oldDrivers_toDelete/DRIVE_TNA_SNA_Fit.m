clear; close all;

wMelt_flag = 0
T1orS2_flag = 2

% ===============================
% load Box data
% box name without the 'Box_' prefix
   %Work.Box_base_name='2016-06-30-prem_init_sweep';
   if T1orS2_flag==1
       %Work.Box_base_name='y161213_TNA_fit';
       Work.Box_base_name='2017-08-15-TNA_forGIA';
       if wMelt_flag==0
       Work.savefigname='TNA_noMelt';
       elseif wMelt_flag==1
       Work.savefigname='TNA_wMelt';
       end
   elseif T1orS2_flag==2
       Work.Box_base_name='2017-07-20-SNA_forGIA';
       Work.savefigname='SNA_noMelt';
   end


% box directory
   Work.cwd=pwd;cd ~; Work.hmdir=pwd;cd( Work.cwd)
   Work.Box_dir =[ Work.hmdir '/Dropbox/0_VBR_WORK/0_y17_Projects/Boxes/'];
   %Work.Box_dir =[ Work.hmdir '/0_vbr_git/VBRcloset/'];
   Work.Box_dir = [ Work.Box_dir  Work.Box_base_name '/'];

% full box name
   if wMelt_flag == 1
        Work.Box_name_IN = ['Box_'  Work.Box_base_name '_wMelt_VBR'];
   elseif wMelt_flag == 0
        Work.Box_name_IN = ['Box_'  Work.Box_base_name '_VBR'];
   end

   Work.Box_name_IN = [ Work.Box_dir  Work.Box_name_IN];

% ===============================
% the velocity profile
  Fit_Params.velfile = '../../6_FitVobs/velocity_models/TNA_SNA/TNA_SNA';

% choose which VBR to fit against
  Fit_Params.VBR_anelastic_method = 'AndradePsP'; % for actual fitting
          % NOTE: eBurgers will BREAK since naming convention is not the
          % same. Should fix that in the spine.
  Fit_Params.VBR_visc_method = 'LH2012'; % only for plotting

% ===============================
% set depth weighting (weighting for all depths initialized to 1, set changes here)
% asthenosphere:
  Fit_Params.depthrange = [0 80 ; 80 300; 300 600 ];
  Fit_Params.weighted = [ 0 1 0 ];
  % plate
  %Fit_Params.depthrange = [0 30 ; 80 300; 300 600 ];
  %Fit_Params.weighted = [ 0 1 0 ];

% ===============================
% add paths
  addpath('../../6_FitVobs/Functions_Plotting/')
  addpath('../../6_FitVobs/')

% load the box
  load(Work.Box_name_IN)

% get variable info, VarInfo
  VarInfo.Var1_name=Box(1,1).info.var1name;
  VarInfo.Var1_units=Box(1,1).info.var1units;
  VarInfo.Var1_range = Box(1,1).info.var1range;
  if isempty(Box(1,1).info.var2range)==0
      VarInfo.Var2_name=Box(1,1).info.var2name;
      VarInfo.Var2_units=Box(1,1).info.var2units;
      VarInfo.Var2_range = Box(1,1).info.var2range;
  end
  VarInfo.Var1_n=numel(Box(:,1));
  VarInfo.Var2_n=numel(Box(1,:));

% set depth range for all plots
  ylimits = [0 350]; % NOMELT Vs only resolved to 325 km. Below that, the
                     % observations are smoothed to a reference model.
  xlimits = [min(VarInfo.Var2_range) max(VarInfo.Var2_range)];
  maxZ_km = max(Box(1,1).run_info.Z_km) ;

% build matrix with frame index to fit against
  for i = 1:VarInfo.Var1_n
      for j = 1:VarInfo.Var2_n
       Fit_Params.Frame_Selection(i,j)=Box(i,j).run_info.VBR_frame_indeces;
      end
  end
  clear i j

% load, modify NOMELT Vs profile
  TNASNA = load(Fit_Params.velfile);

% pull out depth, velocities of interest
  Obs.depth = TNASNA.Depthkm;
  if T1orS2_flag == 1
      Obs.Vs = TNASNA.TNAkms1*1000;
  elseif T1orS2_flag == 2
      Obs.Vs = TNASNA.SNAkms1*1000;
  end
  Obs.Vs = Obs.Vs(Obs.depth<max(maxZ_km));
  Obs.depth = Obs.depth(Obs.depth<max(maxZ_km));

% calculate and plot the best fitting Vs
  [Fit_Params]=Calc_bestFit_ch_2(Box,Fit_Params,Obs);
  [F1]=PLOT_bestFit_ch(Box,VarInfo,Fit_Params,Obs,ylimits,xlimits);

% plot the full range of tests
  F2=PLOT_wholeBox_ch(Box,Obs,Fit_Params,ylimits);

% plot the best fitting profiles
  F3=PLOT_bestProfiles_ch(Box,VarInfo,Fit_Params,Obs);

% save the figs
  saveas(F1,[Work.Box_dir Work.savefigname '_Fit1.eps'],'epsc')
  saveas(F2,[Work.Box_dir Work.savefigname '_Fit2.eps'],'epsc')
  saveas(F3,[Work.Box_dir Work.savefigname '_Fit3.eps'],'epsc')
