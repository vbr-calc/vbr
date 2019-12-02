clf; 

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
   if wMelt_flag == 1
        Work.Box_name_IN = ['Box_'  Work.Box_base_name '_wMelt'];
   elseif wMelt_flag == 0
        Work.Box_name_IN = ['Box_'  Work.Box_base_name ]; 
   end
   
   Work.Box_name_IN = [ Work.Box_dir  Work.Box_name_IN ];
%% load the Box  
   load( Work.Box_name_IN) ; 

j = 1; 
k = 1;

zzz1 = 51
zzz2 = 200

% =========================================

f_vbr_vec = PMbox.VBRinfo.f_vbr_vec ;

%n_veri = 100
%omega=logspace(log10(2*pi*f_vbr_min),log10(2*pi*f_vbr_max),n_veri)' ;
%f_zener_vec = omega./(2*pi) ;
n_veri = length(PMbox.PMs(1,1).QstructWaveFD.Q_inv(:,1)) ;
omega=logspace(log10(2*pi*min(f_vbr_vec)),log10(2*pi*max(f_vbr_vec)),n_veri)' ;
f_zener_vec = omega./(2*pi) ;



f_WFD_vec = PMbox.VBRinfo.f_WFD_vec ;
f_WFD_min = min(f_WFD_vec) ;
f_WFD_max = max(f_WFD_vec) ;
Z_km = PMbox.info.Z_km ;
nZ = length(PMbox.info.Z_km) ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of elementary Zener units

f_Qznr_vec = PMbox.VBRinfo.f_Qznr_vec ;
K  = length(f_Qznr_vec) ;
f_a = min(f_Qznr_vec) ;
f_b = max(f_Qznr_vec) ;
Lbis = length(f_Qznr_vec) 

% Equidistributed in log-space
omega_a = 2*pi*f_a ; 
omega_b = 2*pi*f_b ;
Domega = (K-1)^(-1)*log(omega_b/omega_a) ;

% Interpolation pulsations
omega_itp=zeros(K,1) ;
for kk=1:K
omega_itp(kk)=omega_a*exp((kk-1)*Domega) ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% extraction of vertical profiles
%YI = INTERP1(X,Y,XI)

for z = 1:nZ
    Qinv_vbr = 1./(PMbox.PMs(j,k).AndradePsP.Q(:,z)) ;
    Qinv_vbr_lowf_Z(z) = interp1(f_vbr_vec,Qinv_vbr,f_WFD_min); 
    Qinv_vbr_hif_Z(z) = interp1(f_vbr_vec,Qinv_vbr,f_WFD_max);
    
    Qinv_zener = PMbox.PMs(j,k).QstructWaveFD.Q_inv(:,z) ;
    Qinv_zener_lowf_Z(z) = interp1(f_zener_vec,Qinv_zener,f_WFD_min); 
    Qinv_zener_hif_Z(z) = interp1(f_zener_vec,Qinv_zener,f_WFD_max); 
end



%% PLOTTING
%% ==================================================================

LBLFNT = 15 ;
LW = 2 ;

column = [0.1 0.1 0.2 0.7] ;
plot1 = [0.41 0.5 0.3 0.3] ;
plot2 = [0.41 0.1 0.3 0.3] ;

% COLUMN =========================================================
axes('Position', column); 

plot(log10(Qinv_vbr_lowf_Z),Z_km,'r-', 'LineWidth', LW+2); hold on; 
plot(log10(Qinv_vbr_hif_Z),Z_km,'r-', 'LineWidth', LW+2); hold on; 
plot(log10(Qinv_zener_lowf_Z),Z_km,'b-', 'LineWidth', LW); hold on; 
plot(log10(Qinv_zener_hif_Z),Z_km,'b-', 'LineWidth', LW); hold on; 

%plot(Qinv_vbr_lowf_Z,Z_km,'r-', 'LineWidth', LW+2); hold on; 
%plot(Qinv_vbr_hif_Z,Z_km,'r-', 'LineWidth', LW+2); hold on; 
%plot(Qinv_zener_lowf_Z,Z_km,'b-', 'LineWidth', LW); hold on; 
%plot(Qinv_zener_hif_Z,Z_km,'b-', 'LineWidth', LW); hold on; 

plot([-4 -1], [Z_km(zzz1) Z_km(zzz1)],'k-','LineWidth',1) ;
plot([-4 -1], [Z_km(zzz2) Z_km(zzz2)],'k-','LineWidth',1) ;

%axis([-4 -1 0 400]) ;
set(gca, 'YDir', 'reverse')
xlabel('log attenuation, Q^{-1}','fontname','Times New Roman','fontsize', LBLFNT) ;
ylabel('depth, (km)', 'fontname','Times New Roman','fontsize', LBLFNT)

set(gca,'fontname','Times New Roman','fontsize', LBLFNT)
set(gca,'box','on','xminortick','on','yminortick','on','ticklength',[0.03 0.03],'linewidth',1);




% AT ONE DEPTH =======================================================
axes('Position', plot1); 

Qinv_vbr = 1./(PMbox.PMs(j,k).AndradePsP.Q(:,zzz1)) ;
Qinv_zener = PMbox.PMs(j,k).QstructWaveFD.Q_inv(:,zzz1) ;
% NEED TO FIX THIS Qinv_zener_elem IN THE INTERP CODE !
Qinv_zener_elem(:,:) = PMbox.PMs(j,k).QstructWaveFD.Q_inv_elem(:,:,zzz1) ;
Q0_inv = PMbox.PMs(j,k).QstructWaveFD.Q0_inv_K(:,zzz1) ;

omega_nf = f_vbr_vec.*2*pi ;
%loglog(omega,Q_inv,'-r','LineWidth',2) ; hold on ;
%loglog(omega_nf,Q0_inv_nf,'-k','LineWidth',2) ; hold on ;
loglog(omega_nf,Qinv_vbr,'-r','LineWidth',LW+2) ; hold on ;
loglog(omega,Qinv_zener,'-b','LineWidth',LW) ; hold on ;

%   Plot the individual Zener elements.
for l=1:Lbis-2
loglog(omega,Qinv_zener_elem(:,l),'--','LineWidth',1) ; hold on;
end

%scatter(omega_itp,Q0_inv,50,'om','Filled','MarkerEdgeColor','k') ;
plot([2*pi*f_WFD_min 2*pi*f_WFD_min],[1e-4 5e-2],'k-','LineWidth',1) ;
plot([2*pi*f_WFD_max 2*pi*f_WFD_max],[1e-4 5e-2],'k-','LineWidth',1) ;


xlim([min(omega) max(omega)]) ;
%ylim([1e-4 1e-1]) ;
set(gca,'FontSize',LBLFNT) ; 
xlabel('angular freq., \omega','fontname','Times New Roman','fontsize', LBLFNT) ; 
ylabel('attenuation, Q^{-1}','fontname','Times New Roman','fontsize', LBLFNT) ;

set(gca,'fontname','Times New Roman','fontsize', LBLFNT)
set(gca,'box','on','xminortick','on','yminortick','on','ticklength',[0.03 0.03],'linewidth',1);


% AT ONE DEPTH =======================================================
axes('Position', plot2);  

Qinv_vbr = 1./(PMbox.PMs(j,k).AndradePsP.Q(:,zzz2)) ;
Qinv_zener = PMbox.PMs(j,k).QstructWaveFD.Q_inv(:,zzz2) ;
% NEED TO FIX THIS Qinv_zener_elem IN THE INTERP CODE !
%Qinv_zener_elem(:,:) = PMbox.PMs(j,k).QstructWaveFD.Q_inv_elem(:,:,zzz2) ;
Q0_inv = PMbox.PMs(j,k).QstructWaveFD.Q0_inv_K(:,zzz2) ;

omega_nf = f_vbr_vec.*2*pi ;
%loglog(omega,Q_inv,'-r','LineWidth',2) ; hold on ;
%loglog(omega_nf,Q0_inv_nf,'-k','LineWidth',2) ; hold on ;
loglog(omega_nf,Qinv_vbr,'-r','LineWidth',LW+2) ; hold on ;
loglog(omega,Qinv_zener,'-b','LineWidth',LW) ; hold on ;


for l=1:Lbis-2
 loglog(omega,Qinv_zener_elem(:,l),'--','LineWidth',1) ;
end

%scatter(omega_itp,Q0_inv,50,'om','Filled','MarkerEdgeColor','k') ;
plot([2*pi*f_WFD_min 2*pi*f_WFD_min],[1e-4 5e-2],'k-','LineWidth',1) ;
plot([2*pi*f_WFD_max 2*pi*f_WFD_max],[1e-4 5e-2],'k-','LineWidth',1) ;


xlim([min(omega) max(omega)]) ;
%ylim([1e-4 1e-1]) ;
set(gca,'FontSize',LBLFNT) ; 
xlabel('angular freq., \omega','fontname','Times New Roman','fontsize', LBLFNT) ; 
ylabel('attenuation, Q^{-1}','fontname','Times New Roman','fontsize', LBLFNT) ;

set(gca,'fontname','Times New Roman','fontsize', LBLFNT)
set(gca,'box','on','xminortick','on','yminortick','on','ticklength',[0.03 0.03],'linewidth',1);



saveas(gcf, 'FIG_InterpZ.eps', 'eps2c') % saveas also works



%% ===================
% tau tests
% ====================
%clf; 
%figure
%figure, close  
%plot(PMbox.PMs(1,1).QstructWaveFD.taue,PMbox.info.Z_km,'LineWidth',2); hold on; 
%plot(PMbox.PMs(j,k).QstructWaveFD.taue,PMbox.info.Z_km,'LineWidth',2); hold on;
%set(gca, 'YDir', 'reverse')

%saveas(gca,'FIG_tau_tests.eps','eps2c');
