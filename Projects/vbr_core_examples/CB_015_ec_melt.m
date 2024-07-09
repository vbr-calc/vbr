% put the VBRc in the path %
clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

% ni2011_CB
% gail2008_CB
% sifre2014_CB
sifre2014_CB2

function ni2011_CB
clear
 % set required state variables
VBR.in.SV.T_K = (1400) + 273; % K, temperature
VBR.in.SV.Ch2o(:,1) = [125 600]; % ppm, water content
VBR.in.SV.phi = linspace(0,0.06, 100);

% add to electric methods list
VBR.in.electric.methods_list={'ni2011_melt'};

% call VBR_spine
[VBR] = VBR_spine(VBR);

%
phi = VBR.in.SV.phi;
sz = size(VBR.out.electric.ni2011_melt.esig);
esig_ol = 0.01 .* ones(sz(1), sz(2));
esig_m = VBR.out.electric.ni2011_melt.esig;

% Hashin-Shtrikman Uppper
num = 3.*(1-phi).*(esig_m-esig_ol); % numerator
den = 3.*esig_m-phi.*(esig_m-esig_ol); % denominator
esigHS = esig_m.*(1-(num./den)); % HS conductivity

% Parallel
esigP(1,:) = phi.*esig_m(1,:) + (1-phi).*esig_ol(1,:);
esigP(2,:) = phi.*esig_m(2,:) + (1-phi).*esig_ol(2,:);

% plot figure
fig = figure("Name",'Ni_2011');
plot(phi,esigHS(2,:), "Linewidth", 2.5, "Color", 'b'), hold on
plot(phi,esigP(2,:), "Linewidth", 2.5, "Color", 'b', "LineStyle", "--")
plot(phi,esigHS(1,:), "Linewidth", 2.5, "Color", 'r')
plot(phi,esigP(1,:), "Linewidth", 2.5, "Color", 'r', "LineStyle", "--")

xlabel('Melt Fraction (\Phi)','FontWeight','bold')
ylabel('\Sigma (S/m)','FontWeight','bold')
legend('HS+ (600 ppm)','parallel (600 ppm)', 'HS+ (125 ppm)','parallel (125 ppm)',"Location","best")
ylim([0.01 0.8])
set(gca,'Yscale','log')

% save figure
figDir = fullfile(pwd,'figures/');
saveas(fig,[figDir,'/CB_015_ni_201.png'])
end

function gail2008_CB
clear
% set required state variables
    % ThermalSettings.Tpots=[1420];
    [SVs, HF] = genThermalMod_ec();
    VBR.in.SV=SVs;
    VBR.in.SV.phi = [0.35 0.035 0.005]./100; % volume fraction

% add to electric methods list
VBR.in.electric.methods_list={'SEO3_ol','gail2008_melt'};

% call VBR_spine
[VBR] = VBR_spine(VBR);

%Hashin-Shtrikman
[VBR] = ec_HS1962(VBR, VBR.out.electric.SEO3_ol.esig, VBR.out.electric.gail2008_melt.esig);

% plot figures
fig = figure("Name",'Gaillard_2008');
plot(VBR.out.electric.HSup.esig(:,1), HF.z_km,"LineWidth",2.5,"LineStyle","-"), hold on
plot(VBR.out.electric.HSup.esig(:,2), HF.z_km,"LineWidth",2.5,"LineStyle","--")
plot(VBR.out.electric.HSup.esig(:,3), HF.z_km,"LineWidth",2.5,"LineStyle","-.")

set(gca,"YDir",'reverse')
set(gca,"XScale",'log')
ylim([70 200])
xlim([0.001 10])
xlabel('Conductivity (S * m^{-1})')
ylabel('Depth (km)')
title('20 Ma Plate Conductivity')
legend('Dry Ol + 0.35% carbonatite','Dry Ol + 0.035% carbonatite','Dry Ol + 0.005% carbonatite')
set(gca,"XDir",'reverse')

% save figure
figDir = fullfile(pwd,'figures/');
saveas(fig,[figDir,'/CB_015_Gail_2008.png'])
end

function sifre2014_CB
clear
% set required state variables
VBR.in.SV.T_K = linspace(1d4/9, 1d4/5, 25); % K, temperature
VBR.in.SV.Cco2_m(:,1) = [25.9 23.3 18.2 10.4]; % wt_percent, CO2 in melt
VBR.in.SV.Ch2o_m(:,1) = [10.2 9.2 7.3 4.4]; % wt_percent, bulk water content
VBR.in.SV.mf = 1; % mass fraction of melt

% add to electric methods list
VBR.in.electric.methods_list={'sifre2014_melt'};
    
% call VBR_spine
[VBR] = VBR_spine(VBR);

% plot figures
fig = figure("Name",'Sifre_2014_Fig1');
hold on;
for id = 1:numel(VBR.in.SV.Cco2_m)
    plot(VBR.in.SV.T_K-273,VBR.out.electric.sifre2014_melt.esig(id,:),"Linewidth",2.5)
end
xlabel('10,000/T (K^-1)')
ylabel('log [conductivity (S m^-1)]')
set(gca,"Xdir",'reverse')
set(gca,"Yscale",'log')
names = [string(VBR.in.SV.Ch2o_m) string(VBR.in.SV.Cco2_m)];
legend([names(:,1) + ' wt % H_2O + ' + names(:,2) + ' wt% CO_2 '])
xlim([900 1500])

% save figure
figDir = fullfile(pwd,'figures/');
saveas(fig,[figDir,'/CB_015_Sifre_2014.png'])
end

function sifre2014_CB2
clear
% set required state variables
% VBR.in.SV.T_K(:,1) = linspace(950,1450,11) + 273 ; % K, temperature
VBR.in.SV.T_K(:,1) = linspace(950,1450,31) + 273 ; % K, temperature
Cco2 = [0 200 5000]; % ppm, bulk CO2
Ch2o = [200 200 5000]; % ppm, bulk H2O
VBR.in.SV.mf = [0 logspace(-5,0, 61)]; % mass fraction of melt

fig = figure("Name",'Sifre_2014_Fig2');
for id =1:numel(Cco2)

    VBR.in.SV.Cco2 = Cco2(id); % ppm, bulk CO2 
    VBR.in.SV.Ch2o = Ch2o(id); % ppm, bulk H2O
    
    % add to electric methods list
    VBR.in.electric.methods_list={'sifre2014_melt'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR);
    
    % reset specific state variables
    clear VBR.in.SV.Ch2o
    VBR.in.SV.Ch2o = VBR.out.electric.sifre2014_melt.Ch2o_ol; % residual H2O in Ol
    
    % add to electric methods list
    VBR.in.electric.methods_list={'jones2012_ol','SEO3_ol'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR);
    
    % Mixing Model, Hashin-Shtrikman 
    VBR.in.SV.phi = VBR.out.electric.sifre2014_melt.phi;
    VBR = ec_HS1962(VBR,VBR.out.electric.jones2012_ol.esig,VBR.out.electric.sifre2014_melt.esig);

    % plot subplots
    subplot(3,1,id)
    [x, y] = meshgrid(VBR.in.SV.phi, VBR.in.SV.T_K);
    xlim([0.01 10])
    shading interp
    hold on
    colormap("hsv")
    [lines, hand] = contourf(x*100,y-273,log10(VBR.out.electric.HSup.esig),'k', 'ShowText','on');
    cb = colorbar();
    cb.Label.String = 'log(Sigma) (S/m)';
    cb.Label.FontWeight = "bold";
    ylabel('Temperature (C)')
    xlabel('Melt Percent (vol %)')
    xticks([0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10])
    hand.LevelStep = 0.1;
    hand.TextList = [-2.5:0.5:0.5];
    title('Bulk H_{2}O = ' + string(Ch2o(id)) + ' p.p.m.,  Bulk CO_{2} = ' + string(Cco2(id)) + ' p.p.m')
    set(gca,"Xscale",'log')

end

% save figure
figDir = fullfile(pwd,'figures/');
saveas(fig,[figDir,'/CB_015_Sifre_2014_II.png'])
end

%%

function [SVs,HF] = genThermalMod_ec()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % SVs = genThermalModels(ThermalSettings)
  %
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  disp('Generating halfspace cooling profiles...')
  HF.Tsurf_C=0; % surface temperature [C]
  HF.Tasth_C=1420; % asthenosphere temperature [C]
  HF.V_cmyr=8; % half spreading rate [cm/yr]
  HF.Kappa=1e-6; % thermal diffusivity [m^2/s]
  HF.rho=3300; % density [kg/m3]
  HF.t_Myr=20; % seaflor age [Myrs]
  HF.z_km=linspace(0,200,100)'; % depth, opposite vector orientation [km]
  dTdz_ad=0.3; % C/km

% HF calculations
  HF.s_in_yr=(3600*24*365); % seconds in a year [s]
  HF.t_s=HF.t_Myr*1e6*HF.s_in_yr; % plate age [s]
  HF.x_km=HF.t_s / (HF.V_cmyr / HF.s_in_yr / 100) / 1000; % distance from ridge [km]

% calculate HF cooling model for each plate age
  HF.dT=HF.Tasth_C-HF.Tsurf_C;
  HF.T_C=zeros(numel(HF.z_km),numel(HF.x_km));
  for HFi_t = 1:numel(HF.t_s)
    HF.erf_arg=HF.z_km*1000/(2*sqrt(HF.Kappa*HF.t_s(HFi_t)));
    HF.T_C(:,HFi_t)=HF.Tsurf_C+HF.dT * erf(HF.erf_arg)+dTdz_ad*HF.z_km;
  end

  % state variables
  SVs.T_K = HF.T_C+273; % set HF temperature, convert to K

  % construct pressure as a function of z, build matrix same size as T_K:
  HF.P_z=HF.rho*9.8*HF.z_km*1e3/1e9; %
  SVs.P_GPa = repmat(HF.P_z,1,numel(HF.t_s)); % pressure [GPa]

  % set the other state variables as matrices of same size
  sz=size(HF.T_C);

  [Solidus] = SoLiquidus(SVs.P_GPa*1e9,zeros(sz),zeros(sz),'hirschmann');
  SVs.Tsolidus_K=Solidus.Tsol+273;

end
