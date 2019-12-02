% TEMPORARY-- plot the GIA objective Q functions to set up for new
% fitting... 

clear all; clf; close all;
%% ---------------------- %%                             
%% Box input/output files %%
%% ---------------------- %%

%% box name without the 'Box_' prefix
   %Work.Box_base_name='2016-06-30-prem_init_sweep';
   %Work.Box_base_name='y161206_TNA_test';
   Work.Box_base_name='y161205_SNA_test';
   
%% box directory  
   Work.cwd=pwd;cd ~; Work.hmdir=pwd;cd( Work.cwd)
   %Work.Box_dir =[ Work.hmdir '/Dropbox/Research/0_Boxes/'];
   Work.Box_dir =[ Work.hmdir '/0_vbr_git/VBRcloset/']; 
   Work.Box_dir = [ Work.Box_dir  Work.Box_base_name '/'];
  
%% full box name  
   Work.Box_name_IN = ['Box_'  Work.Box_base_name '_VBR_GIA'];  
   Work.Box_name_IN = [ Work.Box_dir  Work.Box_name_IN ];
%% load the Box  
   load( Work.Box_name_IN) ; 
   
Box(2,9).info  
%% =======================================================
% Extract the Temp profile and q functions at two depths

i_var1 = 4 ;  % craton: 2
i_var2 = 4 ;  % craton: 9

Z_km = Box(i_var1,i_var2).run_info.Z_km ;
T_z_K = Box(i_var1,i_var2).Frames.T ; 

size(Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.Qinv)

Qinv_vbr_lowf_Z = Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.Qinv(:,1);
Qinv_vbr_hif_Z = Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.Qinv(:,end);

zzz1 = 25 ; 
zzz2 = 90 ; 

f_vbr_vec = Box(i_var1,i_var2).Frames(end).VBR.in.SV.f ;
omega_nf = f_vbr_vec.*2*pi ;

Qinv_z1 = Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.Qinv(zzz1,:);
Qinv_z2 = Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.Qinv(zzz2,:);


% Maxwell times:  
Gu = Box(i_var1,i_var2).Frames(end).VBR.out.elastic.anharmonic.Gu(:) ; 
eta_diff = Box(i_var1,i_var2).Frames(end).VBR.out.viscous.LH2012.diff.eta(:) ; 
eta_tot = Box(i_var1,i_var2).Frames(end).VBR.out.viscous.LH2012.eta_total(:) ; 
MaxwellTime_diff = eta_diff./Gu ;
MaxwellTime_total = eta_tot./Gu ;


%% WRITE OUT FILES FOR PYTHON

TauMax_mat = zeros(length(Gu),5); 
TauMax_mat(:,1) = Gu ; 
TauMax_mat(:,2) = eta_diff ; 
TauMax_mat(:,3) = eta_tot ;
TauMax_mat(:,4) = MaxwellTime_diff ;
TauMax_mat(:,5) = MaxwellTime_total ;

TauMax_name = './x1_BH_GIA_notPublic/TauMax_data.txt' ;
save(TauMax_name,'TauMax_mat','-ascii') ; 

% extract M profiles as function of frequency for animation... 
M_matname = './x1_BH_GIA_notPublic/GIA_M_freq.txt' ; 
M_freq_mat = Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.M_comp(:,:) ; 
save(M_matname,'M_freq_mat','-ascii') ; 

Freq_vecname = './x1_BH_GIA_notPublic/VBR_freqs.txt' ; 
VBR_freq_vec = Box(1,1).Frames(7).VBR.in.SV.f ; 
save(Freq_vecname,'VBR_freq_vec','-ascii') ; 

%% PLOTTING
%% ==================================================================

LBLFNT = 15 ;
LW = 2 ;

column1 = [0.1 0.1 0.2 0.7] ;
column2 = [0.35 0.1 0.2 0.7] ;
plot1 = [0.65 0.5 0.3 0.3] ;
plot2 = [0.65 0.1 0.3 0.3] ;

% COLUMN =========================================================
axes('Position', column1); 

plot(log10(Qinv_vbr_lowf_Z),Z_km,'r-', 'LineWidth', LW+2); hold on; 
plot(log10(Qinv_vbr_hif_Z),Z_km,'r-', 'LineWidth', LW+2); hold on; 
%plot(log10(Qinv_zener_lowf_Z),Z_km,'b-', 'LineWidth', LW); hold on; 
%plot(log10(Qinv_zener_hif_Z),Z_km,'b-', 'LineWidth', LW); hold on; 

log10_Qinv_min = -4 ;
log10_Qinv_max = 4 ;
plot([log10_Qinv_min log10_Qinv_max], [Z_km(zzz1) Z_km(zzz1)],'k-','LineWidth',1) ;
plot([log10_Qinv_min log10_Qinv_max], [Z_km(zzz2) Z_km(zzz2)],'k-','LineWidth',1) ;

axis([log10_Qinv_min log10_Qinv_max 0 350]) ;
set(gca, 'YDir', 'reverse')
xlabel('log attenuation, Q^{-1}','fontname','Times New Roman','fontsize', LBLFNT) ;
ylabel('depth, (km)', 'fontname','Times New Roman','fontsize', LBLFNT)

set(gca,'fontname','Times New Roman','fontsize', LBLFNT)
set(gca,'box','on','xminortick','on','yminortick','on','ticklength',[0.03 0.03],'linewidth',1);

% COLUMN =========================================================
axes('Position', column2); 
s_per_year = pi*1e7 ; 
plot(log10(MaxwellTime_diff./s_per_year),Z_km,'g-', 'LineWidth', LW+2); hold on; 
plot(log10(MaxwellTime_total./s_per_year),Z_km,'b-', 'LineWidth', LW+2); hold on; 

log10_TM_min = 0 ;
log10_TM_max = 12 ;
%plot([log10_Qinv_min log10_Qinv_max], [Z_km(zzz1) Z_km(zzz1)],'k-','LineWidth',1) ;
%plot([log10_Qinv_min log10_Qinv_max], [Z_km(zzz2) Z_km(zzz2)],'k-','LineWidth',1) ;

axis([log10_TM_min log10_TM_max 0 350]) ;
set(gca, 'YDir', 'reverse')
xlabel('log T_{Mx} [yrs]','fontname','Times New Roman','fontsize', LBLFNT) ;
%ylabel('depth, (km)', 'fontname','Times New Roman','fontsize', LBLFNT)

set(gca,'fontname','Times New Roman','fontsize', LBLFNT)
set(gca,'box','on','xminortick','on','yminortick','on','ticklength',[0.03 0.03],'linewidth',1);



% AT ONE DEPTH =======================================================
axes('Position', plot1); 

loglog(omega_nf,Qinv_z1,'-r','LineWidth',LW+2) ; hold on ;
%loglog(omega,Qinv_zener,'-b','LineWidth',LW) ; hold on ;

% AT ONE DEPTH =======================================================
axes('Position', plot2); 

loglog(omega_nf,Qinv_z2,'-r','LineWidth',LW+2) ; hold on ;
%loglog(omega,Qinv_zener,'-b','LineWidth',LW) ; hold on ;