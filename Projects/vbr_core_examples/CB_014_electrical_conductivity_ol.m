%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CB_014_electrical_conductivity_ol.m
%
%  Calculating electrical conductivity of Olivine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CB_014_electrical_conductivity_ol()
    % put the VBRc in the path %
    clear
    path_to_top_level_vbr='../../';
    addpath(path_to_top_level_vbr)
    vbr_init

    naif2021_CB()
    yosh2009_CB()
    SEO_CB()
    poe2010_CB()
    wang2006_CB()
    UHO2014_CB()
    Jones2012_CB()
end

function naif2021_CB
    clear
    % set required state variables
    VBR.in.SV.T_K = (1200) + 273; % K, temperature
    VBR.in.SV.Ch2o_ol = [0, logspace(0,3,31)]; % ppm, water content
    
    % add to electric methods list
    VBR.in.electric.methods_list={'yosh2009_ol','SEO3_ol','poe2010_ol','wang2006_ol','UHO2014_ol','jones2012_ol'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR);
    
    % plot Figure
    sz = size(VBR.in.SV.Ch2o_ol);
    dry = repmat(VBR.out.electric.SEO3_ol.esig, sz(1), sz(2)); % SEO3 (anhydrous Ol conduction)
    
    fig = figure("Name",'Naif_2021');
    loglog(VBR.in.SV.Ch2o_ol, 1./VBR.out.electric.yosh2009_ol.esig,  "LineWidth", 2.5), hold on
    loglog(VBR.in.SV.Ch2o_ol, 1./dry, "LineWidth", 2.5)
    loglog(VBR.in.SV.Ch2o_ol, 1./VBR.out.electric.poe2010_ol.esig, "LineWidth", 2.5)
    loglog(VBR.in.SV.Ch2o_ol, 1./VBR.out.electric.wang2006_ol.esig, "LineWidth", 2.5)
    loglog(VBR.in.SV.Ch2o_ol, 1./VBR.out.electric.UHO2014_ol.esig, "LineWidth",2.5)
    loglog(VBR.in.SV.Ch2o_ol, 1./VBR.out.electric.jones2012_ol.esig,"LineWidth", 2.5)
    
    name = {'yosh2009_{ol}','SEO3_{ol}','poe2010_{ol}','wang2006_{ol}','UHO2014_{ol}','jones2012_{ol}'};
    legend(name)
    title("Empirical Relations for Ol Resistivity @1200 C")
    xlabel("Water Content (ppm)")
    ylabel("Resistivity (Ohm-m)")

    % save figure
    figDir = fullfile(pwd,'figures/');
    saveas(fig,[figDir,'/CB_014_naif_2021.png'])
end

function yosh2009_CB
    clear 
    % set required state variables
    VBR.in.SV.T_K = linspace(500,2000,16); % K, temperature
    VBR.in.SV.Ch2o_ol = [0, logspace(1,4,4)]'; % ppm, water content (opposite vector orientation)
    VBR.in.electric.methods_list={'yosh2009_ol'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR);
    
    % plot Figure
    fig = figure("Name",'Yoshino_2009');
    for  i = 1:length(VBR.in.SV.Ch2o_ol)
        ch2o_ol =[num2str(VBR.in.SV.Ch2o_ol(i)/1d4) " wt%"];
        semilogy(1d3./VBR.in.SV.T_K, VBR.out.electric.yosh2009_ol.esig(i,:), ...
                 "LineWidth", 2.5, 'displayname', ch2o_ol), hold on
    end
    legend()
    title("Electrical conductivity of Ol at temperature for a given given wt% water")
    xlabel("Reciprical Temperature (1/K)")
    ylabel("Conductivity (S/m)")
    ylim([1d-8 1d-1])
    
    % save figure
    figDir = fullfile(pwd,'figures/');
    saveas(fig,[figDir,'/CB_014_yosh_2009.png'])
end

function SEO_CB
    clear
    % set required state variables
    VBR.in.SV.T_K = linspace(700,1600,10) + 273; % K, temperature
    
    % add to electric methods list
    VBR.in.electric.methods_list={'SEO3_ol'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR) ;
    
    % plot Figure
    fig  = figure("Name",'SEO3');
    subplot(1,2,1)
    semilogy(VBR.in.SV.T_K - 273,VBR.out.electric.SEO3_ol.esig, "LineWidth",2.5 )
    xlabel('Temperature (C)')
    ylabel('Conductivity (S/m)')
    title('Anhydrous Conductivity of Ol')
    legend('SEO3 - QFM')

    subplot(1,2,2)
    semilogy(1d3./VBR.in.SV.T_K, 1./VBR.out.electric.SEO3_ol.esig, "LineWidth",2.5 )
    xlabel('Reciprical Temperature (1000/K)')
    ylabel('Resistivity (Ohm-m)')
    title('Anhydrous Resistivity of Ol')
    legend('SEO3 - QFM')
    set(gca, 'YDir','reverse')
    set(gca,'YAxisLocation','right')
    
    % save figure
    figDir = fullfile(pwd,'figures/');
    saveas(fig,[figDir,'/CB_014_SEO3_2006.png'])
end

function poe2010_CB
    clear
    % set required state variables
    VBR.in.SV.T_K(:,1) = linspace(500,1600,12) + 273; % K, temperature (opposite vector orientation)
    VBR.in.SV.Ch2o_ol = logspace(3,0,7); % ppm, water content
    
    % add to electric methods list
    VBR.in.electric.methods_list={'poe2010_ol'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR) ;
    
    % plot figure
    fig = figure("Name",'Poe_2010');
    subplot(1,2,1)
    for  i = 1:length(VBR.in.SV.Ch2o_ol)
        h2o_name = [sprintf("%.2f", VBR.in.SV.Ch2o_ol(i)) ' ppm H_{2}O'];
        semilogy(1./VBR.in.SV.T_K, VBR.out.electric.poe2010_ol.esig_H(:,i), ...
                 "LineWidth",2.5, 'displayname', h2o_name)
        hold on
    end
    legend("Location", "southwest")
    xlabel('Reciprical Temperature 1/T (K^{-1}')
    ylabel('Conductivtity (S/m)')
    title('Hydrous Ol Conductivity')

    subplot(1,2,2)
    [x, y] = meshgrid(log10(VBR.in.SV.Ch2o_ol),VBR.in.SV.T_K);
    pcolor(x,y,log10(VBR.out.electric.poe2010_ol.esig))
    set(gca, "YTick", [800:200:2000])
    shading interp  
    colormap(hsv)
    colorbar('title', 'Conductivity');
    hold on
    contour(x,y,log10(VBR.out.electric.poe2010_ol.esig),'k', 'ShowText','on');
    xlabel('log (ppm water)')
    ylabel('Temperature (K)')
    title('Bulk Conductivity vs Temperature/Water Content')
    
    % save figure
    figDir = fullfile(pwd,'figures/');
    saveas(fig,[figDir,'/CB_014_poe_2010.png'])
end

function wang2006_CB
    clear
    % set required state variables
    VBR.in.SV.T_K(:,1) = [linspace(1273,873, 5) 1673]; % K, temperature (opposite vector orientation)
    VBR.in.SV.Ch2o_ol = 1d4.*logspace(-4,0, 21); % ppm, water content
    
    % add to electric methods list
    VBR.in.electric.methods_list={'wang2006_ol'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR);
    
    % plot figure
    fig = figure("Name",'Wang_2006');
    subplot(2,1,1)
    for i = 1:length(VBR.in.SV.T_K)-1
        T_name = [num2str(VBR.in.SV.T_K(i)) ' K'];
        loglog(VBR.in.SV.Ch2o_ol./1d4, VBR.out.electric.wang2006_ol.esig(i,:), ...
               "LineWidth", 2.5, 'displayname', T_name), hold on
    end
    legend()
    xlabel('Water Content (wt %)')
    ylabel('Temperature (K)')
    set(gca,'YTick', [0.0001 0.001 0.01 0.1 1 10]);

    subplot(2,1,2)
    dry = repmat(VBR.out.electric.wang2006_ol.esig_A(end),1,numel(VBR.in.SV.Ch2o_ol)); % Wang Andhydrous Ol conduction
    loglog(VBR.in.SV.Ch2o_ol./1d4,dry, "LineWidth", 2.5); hold on
    [x, y] = meshgrid(VBR.in.SV.Ch2o_ol./1d4, logspace(-4,1, numel(VBR.in.SV.Ch2o_ol)));
    ineq = (y>1d-2) & (y<1d-1);
    ineq = double(ineq);
    ineq(ineq==0) = NaN ;
    pcolor(x, y,ineq);
    shading interp
    colormap('gray')
    loglog(VBR.in.SV.Ch2o_ol./1d4,VBR.out.electric.wang2006_ol.esig(end,:), "LineWidth", 2.5);
    xlim([1d-4 1d-1])
    ylim([1d-4 1d1])
    legend('Dry Olivine','Upper Mantle Conductivity Range','Wang2006',"Location","best")
    set(gca,'YTick', [0.0001 0.001 0.01 0.1 1 10]);
    xlabel('Water Content (wt %)')
    ylabel('\sigma (S m^{-1})')

    % save figure
    figDir = fullfile(pwd,'figures/');
    saveas(fig,[figDir,'/CB_014_wang_2006.png'])
end

function UHO2014_CB
    clear 
    % set required state variables
    VBR.in.SV.T_K(:,1) = [1200 600] + 273; % K, temperture (opposite vector orientation)
    VBR.in.SV.Ch2o_ol = logspace(0,4,17); % ppm, water content
    
    % add to electric methods list
    VBR.in.electric.methods_list={'UHO2014_ol'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR);

    % plot figure
    fig = figure("Name",'UHO_2014');
    subplot(2,1,1)
    loglog(VBR.in.SV.Ch2o_ol, VBR.out.electric.UHO2014_ol.esig(1,:),"LineWidth",2.5)
    xlabel('C_{H_{2}O} (wt. ppm)')
    ylabel('\sigma (S/m)')
    title('Hydrous Conductivity @1200 C')
    xlim([3 3000])
    ylim([1d-3 1d0])

    subplot(2,1,2)
    loglog(VBR.in.SV.Ch2o_ol, VBR.out.electric.UHO2014_ol.esig(2,:),"LineWidth",2.5)
    xlabel('C_{H_{2}O} (wt. ppm)')
    ylabel('\sigma (S/m)')
    title('Hydrous Conductivity @ 600 C')
    xlim([3 3000])
    ylim([1d-7 1d-1])

    % save figure
    figDir = fullfile(pwd,'figures/');
    saveas(fig,[figDir,'/CB_014_UHO_2014.png'])
end

function Jones2012_CB
    clear
    % set required state variables
    VBR.in.SV.T_K = linspace(600,1200,61) + 273; % K, temperature
    VBR.in.SV.Ch2o_ol(:,1) = logspace(-1,4,61); % ppm, water content (opposite vector orientation)
    
    % add to electric methods list
    VBR.in.electric.methods_list={'jones2012_ol'};
    
    % call VBR_spine
    [VBR] = VBR_spine(VBR);

    % plot figure
    fig = figure("Name",'Jones_2012');
    [x, y] = meshgrid(VBR.in.SV.T_K,VBR.in.SV.Ch2o_ol);
    shading interp
    hold on
    colormap("jet")
    contourf(x-273,y,log10(VBR.out.electric.jones2012_ol.esig), ...
             [-0.5 -1.25:-0.25:-3.5 -5.5], 'linecolor', 'k', ...
             'ShowText','on');

    xlim([600 1200])
    ylim([0 1000])
    caxis([-5.5, -0.5])
    colorbar('title', 'log(Sigma) (S/m)');

    xlabel('Temperature (C)')
    ylabel('Water Content (ppm)')
    title('Proton Conduction vs Temperature/Water Content')

    % save figure
    figDir = fullfile(pwd,'figures/');
    saveas(fig,[figDir,'/CB_014_jones_2012.png'])
end
