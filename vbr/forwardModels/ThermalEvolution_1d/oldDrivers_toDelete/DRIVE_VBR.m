%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRIVE_VBR.m
% calls VBR for input file in Box format
% uses VBR version 0pt95
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  clear;

%% ----------------------- %%
%% General Driver Settings %%
%% ----------------------- %%
  Work.quit_at_end = 'no'; % if yes, forces matlab to exit at completion!
        % meant for running matlab in background via command line. Use with
        % bash script, RunMatBG, set to 'no' otherwise.

  % include melt fraction in vbr calc?
  wMelt_flag = 0   % BH: we need to clarify this... the flag signals the calling of some scripts
  Work.MELT = 0; % integer (1 or 0) to multiply melt fraction by

  % GIA calc :
  GIA_flag = 0 ;

%% ---------------------- %%
%% Box input/output files %%
%% ---------------------- %%

%% box name without the 'Box_' prefix
   %Work.Box_base_name='2016-06-30-prem_init_sweep';
   %Work.Box_base_name='y161213_TNA_fit';
   Work.Box_base_name='2018-07-02-BigBox';
   %Work.Box_base_name='2017-08-15-TNA_forGIA';

%% box directory
   Work.cwd=pwd;cd ~; Work.hmdir=pwd;cd( Work.cwd)
   %Work.Box_dir =[ Work.hmdir '/Dropbox/Research/0_Boxes/'];
   %Work.Box_dir =[ Work.hmdir '/Dropbox/0_VBR_WORK/0_y17_Projects/Boxes/'];
   Work.Box_dir =[ Work.hmdir '/0_vbr_git/VBRcloset'];
   Work.Box_dir = [ Work.Box_dir  Work.Box_base_name '/'];

%% full box name
   if wMelt_flag == 1
        Work.Box_name_IN = ['Box_'  Work.Box_base_name '_wMelt'];
   elseif wMelt_flag == 0
        Work.Box_name_IN = ['Box_'  Work.Box_base_name ];
   end

   Work.Box_name_IN = [ Work.Box_dir  Work.Box_name_IN ];

%% new VBR box name
   if GIA_flag==0
       Work.Box_out_suffix='_VBR_py';
   elseif GIA_flag==1
        Work.Box_out_suffix='_VBR_GIA_py';
   end

   Work.Box_name_OUT = [ Work.Box_name_IN  Work.Box_out_suffix];

%% ------------ %%
%% VBR settings %%
%% ------------ %%
  %% set frequency to calculate over
  if GIA_flag==0
    % body wave band
    %VBR.in.SV.f =  logspace(-1.5,0.0,10);
    % long period (Grand Helmberger)
    VBR.in.SV.f =  logspace(-1.7,-1.3,10);
    % surface wave band
    %VBR.in.SV.f =  logspace(-2.2,-1.3,10);
  elseif GIA_flag==1
   % GIA band 50 years to 10,000 years
   VBR.in.SV.f =  logspace(-11.497,-9.196,40);
  end
%% frame selection
   Work.frames2vbr='ONLYONETHING';
            % 'ALLTHETHINGS' to VBR all frames in a Box
            % 'ONLYONETHING' to VBR a single frame in a Box
   if strcmp( Work.frames2vbr,'ONLYONETHING')==1
      Work.frm_num = 1; % either an age in Myr or a frame index
      Work.frm_num_type ='final_frame';
          % frm_num_type: 'age_Myr' or 'frame_index' or 'final_frame'
          %               'final_frame' will ignore frm_num
   end

%% add VBR paths
   Work.VBR_version = 'VBR_v0p95';
   addpath(['../../4_VBR/'  Work.VBR_version ],...
           ['../../4_VBR/'  Work.VBR_version '/functions'],...
           ['../../4_VBR/'  Work.VBR_version '/params'])


%% write VBR methods lists (these are the things to calculate)
   VBR.in.elastic.methods_list={'anharmonic';'poro_Takei'};
   VBR.in.viscous.methods_list={'HK2003'; 'LH2012'};
   VBR.in.anelastic.methods_list={'eBurgers';'AndradePsP'};

%% load elastic parameters
   VBR.in.elastic.anharmonic=Params_Elastic('anharmonic');
%    VBR.in.elastic.anharmonic.Gu_0_ol=71;
%% ---------------- %%
%% VBR Calculations %%
%% ---------------- %%

%% load the Box
   load( Work.Box_name_IN) ;

%% loop over box indeces
   Work.nBox = numel(Box); Work.tstart = cputime;
   for iBox = 1:Work.nBox

       display('-------------------------------------------------------- ')
       display(['Run ' num2str(iBox) ' of ' num2str(Work.nBox)])

%%     pull out all frames
       Frames = Box(iBox).Frames;

%%     select the frames to run through VBR
       Work.sz = size(Frames) ;
       Work.n_frames =  Work.sz(2);
       if strcmp(Work.frames2vbr,'ALLTHETHINGS') == 1
           frame_vec = 1: Work.n_frames;
       elseif strcmp(Work.frames2vbr,'ONLYONETHING') == 1
           if  strcmp(Work.frm_num_type,'age_Myr')
               Work.t_Myr = Box(iBox).run_info.timesteps_myrs;
               [Work.val,frame_vec]=min(abs( Work.t_Myr- Work.frm_num));
           elseif strcmp(Work.frm_num_type,'frame_index')
               frame_vec=Work.frm_num;
           elseif strcmp(Work.frm_num_type,'final_frame')
               frame_vec=Work.n_frames;
           end
       end
%      record the indeces
       Box(iBox).run_info.VBR_frame_indeces = frame_vec ;


%%     loop over selected frames, send to VBR
       for ifr = frame_vec
           VBR.in.SV.P_GPa = (Frames(ifr).P)./1e9 ;
           VBR.in.SV.T_K = Frames(ifr).T +273;
           VBR.in.SV.rho = Frames(ifr).rho ;
           VBR.in.SV.phi =  Work.MELT * Frames(ifr).phi ;
           VBR.in.SV.dg_um = 1e4 ;%Frames(ifr).dg_um ;
           VBR.in.SV.sig_MPa = 1 ; %Frames(ifr).sig_MPa ;
           VBR.in.SV.chi = Frames(ifr).comp;
           VBR.in.SV.Ch2o = Frames(ifr).Cs_H2O;

%            % CHRIS TEMP FIX...============
%            % This does not need to happen for any forward models
%            % performed after 12/12/2016
%            settings = Box(iBox).run_info.settings;  % pull out settings
%            Zm=settings.Z_moho_km*1e3;
%            dzMoho = settings.Moho_thickness_km * 1e3;
%            z=Box(iBox).run_info.Z_km * 1e3;
%            % recalc composition -- this was screwy...
%            Grade = 0.5 * (1 + erf( (z - Zm) / dzMoho));
%            VBR.in.SV.chi = Grade;
           % CHRIS TEMP FIX...============

%%         VBR time!
           [VBR] = VBR_spine(VBR) ;
           VBR.input = VBR.in; % necessary for python to read in because 'in' is a reserved keyword.
%%         Store the VBR structure in the current frame
           Frames(ifr).VBR = VBR ;
       end

%%     save the new frame with VBR output in current box
       Box(iBox).Frames = Frames ;

   end
   Work.tend = cputime;

%% save the new VBR box
   save([ Work.Box_name_OUT],'Box')
   disp('-------------------------------------------------------- ')
   disp(' Computations complete!')
   disp([' Total VBR Time: ' num2str(( Work.tend- Work.tstart)/60) ' min']);
   disp(' Box with VBR calculations saved to:')
   disp(Work.Box_name_OUT)

% Quit matlab if running in background from command line
  if strcmp( Work.quit_at_end,'yes')==1
     disp('     Matlab shutting down... Farewell!');
     quit force
  else
      clear Frames frame_vec ifr iBox
  end
