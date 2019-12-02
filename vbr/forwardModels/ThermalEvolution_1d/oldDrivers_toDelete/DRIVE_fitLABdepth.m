% DRIVE fitting a plate thickness, either from receiver functions or other
% i.e. Dalton EPSL 2016 based on attenuation. or Hopper et al. 2017...

% CH, this script needs the local Work. structure
% as DRIVE_TNA_SNA fit and DRIVE_VBR do..
% code lives here: /Users/ben/githole/vbr/vbr/2_PLATES/4pt0_1d_plates

clf;
clear; close all;

path = '~/Dropbox/0_VBR_WORK/0_y17_Projects/Boxes/'

%wMelt_flag = 0 ; % this isnt used !
T1orS2_flag = 1 ;

if T1orS2_flag == 1
  dirName = '2017-08-15-TNA_forGIA/'
  boxBaseName = '2017-08-15-TNA_forGIA_VBR'
  z_LAB_OBS_km = 75.0
elseif T1orS2_flag == 2
  dirName = '2017-07-20-SNA_forGIA/'
  boxBaseName = '2017-07-20-SNA_forGIA_VBR'
  z_LAB_OBS_km = 180.0
end


closetPath = strcat(path,dirName,'/') ;
boxName = strcat('Box_',boxBaseName,'.mat') % Box pre VBR
load(strcat(closetPath,boxName)) ;
display(Box(1,1).info)
display(Box(1,1).run_info)
freqs = Box(1,1).Frames(end).VBR.in.SV.f ;
display(strcat('freqs = ', num2str(freqs)))
display(strcat('periods = ', num2str(1./freqs)))

szBox = size(Box) ;
n_var1 = szBox(1) ;
n_var2 = szBox(2) ;

%return

% ==================================================
% loop over Box and calculate residuals
% between LAB constraint and prediction
% ==================================================
% how to define the LAB
% 1 =  the old way, using viscosity
% 2 = the vbr way, using the modulus at the frequency of observation
define_zlab_method = 2
Q_LAB = 500 ;

for i_var1 = 1:n_var1
    for i_var2 = 1:n_var2

        Z_km = Box(i_var1,i_var2).run_info.Z_km ;
        T_z = Box(i_var1,i_var2).Frames(end).T(:,1); % why is this not just a 1xN vector?
        Qz = Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.Qa(:,end) ;
        Qz = Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.Qa(:,end) ;
        % this is using the viscosity method in the VBR core (update this in the core later!!) :
        if define_zlab_method == 1
          Z_LAB_pred_km = Box(i_var1,i_var2).run_info.zLAB(end)/1e3 ;
        end
        % but we don't want to do that ! we want to use the frequency of observations
        % so for body wave receiver functions, use M1(f_obs) where M1 is the storage modulus
        % plot it later (after the fact), and see where it looks like a good place to find it..

        % average the values of M at each depth, or over the frequency band of observation, or one val.

        % find the critical values of M that is defined as the LAB
        if define_zlab_method == 2
          ind = find(Qz<=Q_LAB,1) ;
          Z_LAB_pred_km = Z_km(ind);
        end
        % then find the index at which that values occurs in Z..

        % calculate the residual between the predicted and the measured:
        Res = ((Z_LAB_pred_km - z_LAB_OBS_km)^2)/z_LAB_OBS_km ;
        Res_mat(i_var1,i_var2) = log10(Res) ;

        zLAB_mat(i_var1,i_var2).ind = ind ; %ind_zLAB ;
        zLAB_mat(i_var1,i_var2).Z_LAB_km = Z_LAB_pred_km ;
        zLAB_mat(i_var1,i_var2).T_LAB = T_z(ind) ;
        zLAB_mat(i_var1,i_var2).Q_LAB_val = Qz(ind) ;
        zLAB_mat(i_var1,i_var2).Q_LAB = Q_LAB ;


        % finding the solidus to compare to LAB location...
        %zSOL_km = Box(i_var1,i_var2).run_info.zSOL(end)/1e3 ;
        %ind_zSOL = find(Z_km > zSOL_km,1); % -1
        %T_SOL = T_z(ind_zSOL) ;
        % zSOL_mat(i_var1,i_var2).zSOL_km = zSOL_km ;
        % zSOL_mat(i_var1,i_var2).ind_zSOL = ind_zSOL ;
        % zSOL_mat(i_var1,i_var2).T_SOL = T_SOL ;
        %zSOL_mat.zSOL_km(i_var1,i_var2) = zSOL_km ;
        %zSOL_mat.ind_zSOL(i_var1,i_var2) = ind_zSOL ;
        %zSOL_mat.T_SOL(i_var1,i_var2) = T_SOL ;

    end
end

Tpot_vec = Box(1,1).info.var2range ; % this flipped from var1range
%Tval_best = 5 ;
zPlate_vec = Box(1,1).info.var1range ;
%[val,ind_best] = min(min(Res_mat(:,:))) ;
%display(['best fit is ', num2str(zPlate_vec(ind_best)), ' at index ', num2str(ind_best)] )

Rmin = min(min(Res_mat))
[i_best,j_best] = find(Res_mat==Rmin)
Res_mat(i_best,j_best)

% or pick it off Residual Map, then export
i_best = 5 ; % z_plate, plate thickness
j_best = 5 ; % T_pot

save("zLAB_mat.mat", "zLAB_mat")

% ============
%return
% ============

% ==================================
% PLOTTING
% ==================================
fig  =  figure ;
orient(fig,'landscape')

LBLFNT = 15 ;
LW = 2 ;
wid = 0.17
ht = 0.7
dx = 0.05
lb = 0.05
column1 = [lb  0.1 wid ht] ;
column2 = [lb+dx+wid  0.1 wid ht] ;
column3 = [lb+2*(dx+wid)  0.1 wid ht] ;
plot1 = [lb+3*(dx+wid) 0.3 0.2 0.35] ;
%plot2 = [0.65 0.1 0.3 0.3] ;
%colors = colormap(hsv(3*n_var2)) ;
colors = colormap(hot(3*n_var2)) ;
depth_var = 10 ; % LAB uncertainty
% COLUMN =========================================================
axes('Position', column1);
% PLOT THE Q PROFILES TO SHOW THE FIT !

for i_var1 = 1:n_var1
    for i_var2 = 1:n_var2
        T_vec_C = Box(i_var1,i_var2).Frames(end).T(:) ;
        Qz = Box(i_var1,i_var2).Frames(end).VBR.out.anelastic.AndradePsP.Qa(:,end) ;
        Z_km = Box(i_var1,i_var2).run_info.Z_km(:) ;
        %col = colors(i_var1+round(2*n_var1),:) ;
        %plot(T_vec_C,Z_km, 'color', col); hold on;
        %col = colors(i_var2+round(2*n_var2),:) ;
        col = colors(i_var2,:) ;
        Z_lab = zLAB_mat(i_var1,i_var2).Z_LAB_km ;
        Q_LAB_val = zLAB_mat(i_var1,i_var2).Q_LAB_val ;
        plot(Q_LAB_val,Z_lab, 'r.', 'markersize', 12 ); hold on; %'color', col,
        plot(Qz,Z_km, 'b-', 'color', col,'linewidth', 1 ); hold on; %'color', col,

      end
end

Q_min = 1 ;
Q_max = 1000 ;
% lower left corner x,y , width height
w = Q_max - Q_min ;
h = 2*depth_var ;
rectangle('position',[Q_min,z_LAB_OBS_km-depth_var,w,h]);
line([Q_min,Q_max],[z_LAB_OBS_km,z_LAB_OBS_km], 'linewidth', 3);
line([Q_LAB,Q_LAB],[Z_km(1),Z_km(end)],'color', 'black');

xlim([Q_min,Q_max])
title(['Fit $Q_{LAB}=$' , num2str(Q_LAB), ' to LAB depth:'], 'interpreter', 'latex')
xlabel('Quality factor Q')
ylabel('Depth [km]')
set(gca,'box','on','xminortick','on','yminortick','on','Ydir','rev',...
            'fontname','Times New Roman','fontsize', LBLFNT)



% COLUMN =========================================================
axes('Position', column2);
% TEMPERATURE

for i_var1 =  1:n_var1 % Tval_best
    for i_var2 = 1:n_var2   % ind_best
        T_vec_C = Box(i_var1,i_var2).Frames(end).T(:) ;
        Z_km = Box(i_var1,i_var2).run_info.Z_km(:) ;
        %col = colors(i_var2+round(2*n_var2),:) ;
        col = colors(i_var2,:) ;
        plot(T_vec_C,Z_km, 'color', col); hold on;

        T_lab = zLAB_mat(i_var1,i_var2).T_LAB ;
        Z_lab = zLAB_mat(i_var1,i_var2).Z_LAB_km ;
        plot(T_lab,Z_lab, 'r.', 'color', col, 'markersize', 12 ); hold on;

        %T_sol = zSOL_mat(i_var1,i_var2).T_SOL ;
        %Z_sol = zSOL_mat(i_var1,i_var2).zSOL_km ;
        %if isempty(T_sol)==0
        %plot(T_sol,Z_sol, 'go', 'markersize', 8 ,'color', [0 0.6 0 ]); hold on; %
    end
end


T_min = 0 ;
T_max = 1800 ;

% lower left corner x,y , width height
w = T_max - T_min ;
h = 2*depth_var ;
rectangle('position',[T_min,z_LAB_OBS_km-depth_var,w,h]);
line([T_min,T_max],[z_LAB_OBS_km,z_LAB_OBS_km]);
xlim([T_min,T_max])

xlabel('Temperature [C]')
% ylabel('Depth [km]')
set(gca,'box','on','xminortick','on','yminortick','on','Ydir','rev',...
            'fontname','Times New Roman','fontsize', LBLFNT)


% COLUMN =========================================================
axes('Position', column3);
% VISCOSITY STRUCTURE

for i_var1 = 1:n_var1 % Tval_best
    for i_var2 = 1:n_var2 % ind_best
        log10_eta = log10(Box(i_var1,i_var2).Frames(end).eta(:)) ;
        Z_km = Box(i_var1,i_var2).run_info.Z_km(:) ;
        %col = colors(i_var2+round(2*n_var2),:) ;
        col = colors(i_var2,:) ;
        plot(log10_eta,Z_km, 'color', col); hold on;

        eta_lab = log10_eta(zLAB_mat(i_var1,i_var2).ind) ;
        Z_lab = zLAB_mat(i_var1,i_var2).Z_LAB_km ;
        plot(eta_lab,Z_lab, 'r.', 'color', col, 'markersize', 12 ); hold on;
    end
end

eta10_min = 17 ;
eta10_max = 26 ;
% lower left corner x,y , width height
w = eta10_max - eta10_min ;
h = 2*depth_var ;
rectangle('position',[eta10_min,z_LAB_OBS_km-depth_var,w,h]);
line([eta10_min,eta10_max],[z_LAB_OBS_km,z_LAB_OBS_km]);
xlim([eta10_min,eta10_max])

xlabel('log_{10} \eta, viscosity [Pa.s]')
set(gca,'box','on','xminortick','on','yminortick','on','Ydir','rev',...
            'fontname','Times New Roman','fontsize', LBLFNT)


% COLUMN =========================================================
axes('Position', plot1);


colormap('gray');
var1range = Box(1,1).info.var1range ; % zPlate
var2range = Box(1,1).info.var2range ; % T_pot

%[var1_mesh,var2_mesh] = meshgrid(var1range,var2range) ;
 %   h1 = imagesc(VarInfo.Var2_range(3:end),VarInfo.Var1_range,log10(misfit(:,3:end)+1e-20));
imagesc(var1range,var2range,Res_mat') ; hold on;
plot(var1range(i_best),var2range(j_best),'r.', 'markersize', 12) ;
%surf(var1_mesh,var2_mesh,Res_mat');

title('Residual $(\log_{10}[(pred-obs)^2/obs])$', 'interpreter', 'latex') ;
xlabel(Box(1,1).info.var1name) ;
ylabel(Box(1,1).info.var2name) ;
set(gca,'box','on','xminortick','on','yminortick','on',...
            'fontname','Times New Roman','fontsize', LBLFNT)


% OLD STUFF:
% if T1orS2_flag == 1
%     testDir = 'y161210_TNA_fit'
%     z_LAB_OBS_km = 75.0
% elseif T1orS2_flag == 2
%     testDir = 'y161210_SNA_fit'
%     z_LAB_OBS_km = 200.0
% end


%
% %
% [Tpot_mesh,Zplate_mesh] = meshgrid(Tpot_vec,zPlate_vec) ;
%
% colormap('gray');
%
%  %   h1 = imagesc(VarInfo.Var2_range(3:end),VarInfo.Var1_range,log10(misfit(:,3:end)+1e-20));
% %imagesc(Tpot_vec ,zPlate_vec,Res_mat) ;
% surf(Tpot_mesh,Zplate_mesh,Res_mat);
% set(gca,'View', [0 90]) ;
% axis tight
% title('Residual $(\log_{10}[(pred-obs)^2/obs])$', 'interpreter', 'latex') ;
% ylabel(Box(1,1).info.var1name) ;
% xlabel(Box(1,1).info.var2name) ;
% set(gca,'box','on','xminortick','on','yminortick','on',...
%             'fontname','Times New Roman','fontsize', LBLFNT)
