% DRIVE_AddMelt
% read in a box, make a new array of boxes and add melt profiles
% (constructed from error functions)
clear all;
clf; close all;

% CH, this script needs the local Work. structure
% as DRIVE_TNA_SNA fit and DRIVE_VBR do..
% ===================================
% (1) read in box.. and look at it..
T1orS2_flag = 1 ;

if T1orS2_flag == 1
  %dirName = '2017-08-15-TNA_forGIA/'
  %boxBaseName = '2017-08-15-TNA_forGIA_VBR'
  z_LAB_OBS_km = 75.0
elseif T1orS2_flag == 2
  %dirName = '2017-07-20-SNA_forGIA/'
  %boxBaseName = '2017-07-20-SNA_forGIA_VBR'
  z_LAB_OBS_km = 180.0
end


testDir = '2017-08-15-TNA_forGIA'

%closetPath = strcat('../../../VBRcloset/',testDir,'/')
closetPath = strcat('~/Dropbox/0_VBR_WORK/0_y17_Projects/Boxes/',testDir,'/')

boxName = strcat('Box_',testDir,'.mat') % Box pre VBR

load(strcat(closetPath,boxName))
display(Box(1,1).info)
display(Box(1,1).run_info)

addpath('./01_functions/');
newBoxName = strcat('Box_',testDir,'_wMelt.mat')
newBoxpath = strcat(closetPath,newBoxName)

% index of zPlate val that best fits zLAB:
% SET THIS AFTER FIRST FITTING EXPERIMENT !
i_varFIXgood = 5 ; % about 80 km for TNA
Box(1,1).info.var1name
Box(1,1).info.var1range(i_varFIXgood)

szBox = size(Box) ;
n_var1 = szBox(1) ;
n_var2 = szBox(2) ;

 LBLFNT = 12 ;


% ===================================
% MAKE THE NEW BOX !@#
phi_vec = [0.0:0.002:0.03] ;
% pick, from the previous results, the row to keep:
n_var2new = length(phi_vec) ;

for i_var1 = 1:n_var1
    for i_var2 = 1:n_var2new
        Box_new(i_var1,i_var2).info = Box(i_varFIXgood,i_var1).info ;
        Box_new(i_var1,i_var2).run_info = Box(i_varFIXgood,i_var1).run_info ;
        Box_new(i_var1,i_var2).Frames = Box(i_varFIXgood,i_var1).Frames ;

        Box_new(i_var1,i_var2).info.var1range = Box(i_varFIXgood,i_var1).info.var2range
        Box_new(i_var1,i_var2).info.var1units = Box(i_varFIXgood,i_var1).info.var2units
        Box_new(i_var1,i_var2).info.var1name = Box(i_varFIXgood,i_var1).info.var2name
        Box_new(i_var1,i_var2).info.var1val = Box(i_varFIXgood,i_var1).info.var2val

        Box_new(i_var1,i_var2).info.var2range = phi_vec ;
        Box_new(i_var1,i_var2).info.var2units = 'melt fraction' ;
        Box_new(i_var1,i_var2).info.var2name = 'phi' ;
        Box_new(i_var1,i_var2).info.var2val = phi_vec(i_var2);

        Z_km = Box_new(i_var1,i_var2).run_info.Z_km ;
        T_z = Box_new(i_var1,i_var2).Frames(end).T(:,1);

        % get zLAB, zSOL, zTcrit? and its index
        % (2) find points below which melt fraction could be added:
        Z_phiBumpCenter_km = Box_new(i_var1,i_var2).run_info.zLAB(end)/1e3 ;
        ind_phiBumpCenter = find(Z_km > Z_phiBumpCenter_km,1)-1 ;
        T_phiBumpCenter = T_z(ind_phiBumpCenter) ;

        % BH (mmarch 2018): integrate the new LAB finding approach in -- 
        
        zLAB_mat(i_var1,i_var2).Z_km = Z_phiBumpCenter_km ;
        zLAB_mat(i_var1,i_var2).ind = ind_phiBumpCenter ;
        zLAB_mat(i_var1,i_var2).T_LAB = T_phiBumpCenter ;
        %Res_mat(i_var1,i_var2) = log10(Res) ;

        % =======================
        % add the melt fraction !
        N = length(Z_km) ;
        N_z_steps = floor(N/10);
        i_mid_step = ind_phiBumpCenter ;
        [step_vec] = make_meltStep(N,N_z_steps,i_mid_step) ;
        phi = phi_vec(i_var2) ;
        phi_step = step_vec.*phi ;

        Box_new(i_var1,i_var2).Frames(end).phi(:) = phi_step ;

    end
end



% ==================================
% PLOTTING
% ==================================

LBLFNT = 15 ;
LW = 2 ;

column1 = [0.1 0.1 0.2 0.7] ;
column2 = [0.35 0.1 0.2 0.7] ;
plot1 = [0.65 0.3 0.3 0.35] ;


% TEMPERATURE : ====================================
axes('Position', column1);
%colors = colormap(hsv(3*n_var1)) ;
colors = colormap(hot(3*n_var2)) ;
for i_var1 = 1:n_var1
    for i_var2 = 1:n_var2new
        Z_km = Box_new(i_var1,i_var2).run_info.Z_km ;
        T_z = Box_new(i_var1,i_var2).Frames(end).T(:,1);
        %col = colors(i_var1+round(2*n_var1),:) ;
        col = colors(i_var1,:) ;
        plot(T_z,Z_km, 'color', col); hold on;
        T_dot = zLAB_mat(i_var1,i_var2).T_LAB ;
        Z_dot = zLAB_mat(i_var1,i_var2).Z_km ;
        %plot(T_dot,Z_dot, 'r.', 'color', col, 'markersize', 12); hold on;
    end
end

T_min = 0 ;
T_max = 1800 ;

% lower left corner x,y , width height
depth_var = 10 ; 
w = T_max - T_min ;
h = 2*depth_var ;
rectangle('position',[T_min,z_LAB_OBS_km-depth_var,w,h]);
line([T_min,T_max],[z_LAB_OBS_km,z_LAB_OBS_km]);

xlim([T_min,T_max])
xlabel('Temperature [C]')
ylabel('Depth [km]')
set(gca,'box','on','xminortick','on','yminortick','on','Ydir','rev',...
            'fontname','Times New Roman','fontsize', LBLFNT)

% =============================================
% MELT FRACTION PLOTS !
axes('Position', column2);

colors = colormap(summer(n_var2new+10)) ;
for i_var1 = 1:n_var1
    for i_var2 = 1:n_var2new
        Z_km = Box_new(i_var1,i_var2).run_info.Z_km ;
        phi_z = Box_new(i_var1,i_var2).Frames(end).phi(:,1);
        col = colors(i_var2,:) ;
        plot(phi_z,Z_km, 'color', col); hold on;
        %plot(T_phiBumpCenter,Z_phiBumpCenter_km, 'r.', 'markersize', 10); hold on;
    end
end

phi_min = 0 ;
phi_max = 0.03 ;
xlim([phi_min,phi_max])
xlabel('\phi, melt fraction')
set(gca,'box','on','xminortick','on','yminortick','on','Ydir','rev',...
            'fontname','Times New Roman','fontsize', LBLFNT)


% ===================================
% save the box... (then run VBR)

clear Box
Box = Box_new ;
%save(newBoxpath) ;
