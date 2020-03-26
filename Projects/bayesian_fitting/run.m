%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Fit asthenospheric Vs and Q (using fit_seismic_observations.m) with the
% most likely state variables, varying temperature, melt fraction and
% grain size in the asthenosphere.
%
% Then, use this constraint on potential temperature and seismic LAB depth
% observations to fit a plate model, i.e. thermal plate thickness, zPlate
% (using fit_plate.m).
%
% This wrapper contains only the most commonly varied inputs - the location
% (lat, lon, depth, smoothing radius) that you would like to fit; the
% names of your files containing seismic observeables (Vs, Q, LAB depth);
% and the anelastic framework in which you would like to do your
% calculations.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clc

locs = [45, -111; 40.7, -117.5; 39, -109.8; 37.2, -100.9];
names = {'Yellowstone', 'BasinRange', 'ColoradoPlateau', 'Interior'};
zrange = [75, 105; 75, 105; 120, 150; 120, 150];
location_colors={[1,0,0];[1,0.6,0];[0,0.8,0];[0,0.3,0]};

% Extract the relevant values for the input depth range.
% Need to choose the attenuation method used for anelastic calculations
%       see possible methods by running vbrListMethods()
q_method = 'xfit_premelt'; %'eburgers_psp' 'xfit_mxw', 'xfit_premelt' 'andrade_psp'
fetch_data('./'); % builds data directories and fetches data 
filenames.Vs = './data/vel_models/Shen_Ritzwoller_2016.mat';
filenames.Q = './data/Q_models/Dalton_Ekstrom_2008.mat';
filenames.LAB = './data/LAB_models/HopperFischer2018.mat';


q_methods = {'eburgers_psp', 'xfit_mxw', 'xfit_premelt', 'andrade_psp'};

f = figure('color', 'w');
axStruct.andrade_psp=subplot(2,2,1);
 set(gca,'xticklabels',{},'box','on')
 ylabel('Temperature (^\circC)');
axStruct.eburgers_psp=subplot(2,2,2);
 set(gca,'xticklabels',{},'box','on')
 set(gca,'yticklabels',{})
axStruct.xfit_mxw=subplot(2,2,3);
 ylabel('Temperature (^\circC)');
 xlabel('Melt Fraction \phi');
 set(gca,'box','on')
axStruct.xfit_premelt=subplot(2,2,4);
 ylabel('Temperature (^\circC)');
 xlabel('Melt Fraction \phi');
 set(gca,'yticklabels',{})
 set(gca,'box','on')

EnsemblePDF=struct();
N_models=0;
for iq = 1:length(q_methods)
    q_method = q_methods{iq};


    for il = 1:length(locs)
        location.lat = locs(il, 1); % degrees North\
        location.lon = locs(il, 2) + 360; % degrees East
        location.z_min = zrange(il, 1); % averaging min depth for asth.
        location.z_max= zrange(il, 2); % averaging max depth for asth.
        location.smooth_rad = 0.5;
        locname = names{il};

        posterior_A = fit_seismic_observations(filenames, location, q_method);

        saveas(gcf, ['plots/output_plots/', names{il}, '_VQ_', q_method, '.png']);
        close
        saveas(gcf, ['plots/output_plots/', names{il}, '_Q_', q_method, '.png']);
        close
        saveas(gcf, ['plots/output_plots/', names{il}, '_V_', q_method, '.png']);
        close

        % calculate marginal P(phi,T|S)
        posterior = posterior_A.pS;
        posterior = posterior ./ sum(posterior(:));
        sh = size(posterior);
        p_marginal = sum(sum(posterior, 1), 2);
        p_marginal_box = repmat(p_marginal, sh(1), sh(2), 1);
        p_joint = sum(posterior .* p_marginal_box, 3);
        p_joint=p_joint/sum(p_joint(:));
        p_joint = sum(posterior,3);

        if ~strcmp(q_method,'xfit_mxw')
        disp(['adding ',q_method,' to ensemble average for ',locname])
        if ~isfield(EnsemblePDF,locname)
          disp('initialize ensemble ave')
          EnsemblePDF.(locname)=p_joint;
        else
          disp('add to ensemble ave')
          EnsemblePDF.(locname)=EnsemblePDF.(locname)+p_joint;
        end
        N_models=N_models+1;
        end


        figure(f)
        axes(axStruct.(q_method)); hold on
        [targ_cutoffs,confs,cutoffs] = calculateLevels(p_joint,[0.7,0.8,0.9,0.95]);
        szs=fliplr([.75,1.,1.5,2,2.5]);
        for icutoff=1:numel(targ_cutoffs)
          levs=[targ_cutoffs(icutoff),targ_cutoffs(icutoff)];
          sz=szs(icutoff);
          hold all
          this_clr=location_colors{il};
          contour(posterior_A.phi, posterior_A.T, p_joint, levs, 'linewidth', sz,'color',this_clr,'displayname',locname)
        end


    end

    axes(axStruct.(q_method));
    title(strrep(q_method, '_', ' '));
    %legend('location','southoutside')
end
saveas(f, ['plots/regional_fits.eps'],'epsc');
saveas(f, ['plots/regional_fits.png'],'png');
close all

% plot ensemble PDFs
f_en = figure('color', 'w');
ax = axes();
set(gca,'box','on')
hold on
ylabel('Temperature (^\circC)');
xlabel('Melt Fraction \phi');

for il = 1:length(locs)
   locname = names{il};
   PDF=EnsemblePDF.(locname) / N_models; % equal weighting
   [targ_cutoffs,confs,cutoffs] = calculateLevels(PDF,[0.7,0.8,0.9,0.95]);
   szs=fliplr([.75,1.,1.5,2,2.5]);
   for icutoff=1:numel(targ_cutoffs)
     levs=[targ_cutoffs(icutoff),targ_cutoffs(icutoff)];
     sz=szs(icutoff);
     this_clr=location_colors{il};
     contour(posterior_A.phi, posterior_A.T, PDF, levs, 'linewidth', sz,'color',this_clr,'displayname',locname)
   end
end

saveas(f_en, ['plots/ensemble_fits.eps'],'epsc');
saveas(f_en, ['plots/ensemble_fits.png'],'png');
close all
