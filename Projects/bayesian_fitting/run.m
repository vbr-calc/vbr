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

locs = [40.7, -117.5; 39, -109.8; 37.2, -100.9];
names = {'BasinRange', 'ColoradoPlateau', 'Interior'};
zrange = [75, 105; 120, 150; 120, 150];
location_colors={[1,0.6,0];[0,0.8,0];[0,0.3,0]};
% Yellowstone, [45,-111], [75,105], [1,0,0]

% Extract the relevant values for the input depth range.
% Need to choose the attenuation method used for anelastic calculations
%       see possible methods by running vbrListMethods()
q_method = 'xfit_premelt'; %'eburgers_psp' 'xfit_mxw', 'xfit_premelt' 'andrade_psp'
fetch_data('./'); % builds data directories and fetches data
filenames.Vs = './data/vel_models/Shen_Ritzwoller_2016.mat';
filenames.Q = './data/Q_models/Dalton_Ekstrom_2008.mat';
filenames.LAB = './data/LAB_models/HopperFischer2018.mat';


q_methods = {'eburgers_psp'; 'xfit_mxw'; 'xfit_premelt'; 'andrade_psp'};

gs_prior_case = 'log_normal_1cm';
switch gs_prior_case
  case 'log_uniform'  
    % uniform probability in log-space 
    fig_prefix_dir = 'gsLogUniform'; 
    grain_size_prior.gs_pdf_type = 'uniform_log'; 
  case 'log_normal_1mm'
    % 1 mm prior, lognormal distribution 
    fig_prefix_dir = 'gsLogNormal_1mm';
    grain_size_prior.gs_mean = .001 * 1e6; % [micrometres]
    grain_size_prior.gs_std = .25;% dimensionless (in log-space!)
    grain_size_prior.gs_pdf_type = 'lognormal';
  case 'log_normal_1cm'  
    % 1 cm prior, lognormal distribution; 
    fig_prefix_dir = 'gsLogNormal_1cm';
    grain_size_prior.gs_mean = .01 * 1e6; % [micrometres]
    grain_size_prior.gs_std = .25;% dimensionless (in log-space!)
    grain_size_prior.gs_pdf_type = 'lognormal';
  otherwise
    warning('unexpected gs_prior_case')
end 
  
RegionalFits=struct();
EnsemblePDF=struct();
EnsemblePDF_no_mxw=struct();
tradeoffDir = ['plots','/','output_plots','/',fig_prefix_dir];
if isdir(tradeoffDir) == 0 
    mkdir(tradeoffDir);
end 
firstRun=1;
for iq = 1:length(q_methods)
    q_method = q_methods{iq};
    disp(['Calculating inference for ',q_method])
    RegionalFits.(q_method)=struct();

    for il = 1:length(locs)
        location.lat = locs(il, 1); % degrees North\
        location.lon = locs(il, 2) + 360; % degrees East
        location.z_min = zrange(il, 1); % averaging min depth for asth.
        location.z_max= zrange(il, 2); % averaging max depth for asth.
        location.smooth_rad = 0.5;
        locname = names{il};
        disp(['     fitting ',locname])

        if firstRun==1
          [posterior_A,sweep] = fit_seismic_observations(filenames, location, q_method, grain_size_prior);
          firstRun=0;
        else
          [posterior_A,sweep] = fit_seismic_observations(filenames, location, q_method, grain_size_prior, sweep);
        end

        disp('        saving plots...')
        saveas(gcf, [tradeoffDir,'/', names{il}, '_VQ_', q_method, '.png']);
        close
        saveas(gcf, [tradeoffDir,'/', names{il}, '_Q_', q_method, '.png']);
        close
        saveas(gcf, [tradeoffDir,'/', names{il}, '_V_', q_method, '.png']);
        close
        disp('        plots saved to plots/output_plots/')

        % calculate marginal P(phi,T|S)
        posterior = posterior_A.pS;
        posterior = posterior ./ sum(posterior(:));
        %sh = size(posterior);
        %p_marginal = sum(sum(posterior, 1), 2);
        %p_marginal_box = repmat(p_marginal, sh(1), sh(2), 1);
        %p_joint = sum(posterior .* p_marginal_box, 3);
        %p_joint=p_joint/sum(p_joint(:));
        p_joint = sum(posterior,3);
        EnsemblePDF = storeEnsemble(EnsemblePDF,locname,q_method,p_joint,posterior_A,1);
        EnsemblePDF_no_mxw = storeEnsemble(EnsemblePDF_no_mxw,locname,q_method,p_joint,posterior_A,0);          

        % store regional fits for combo plot
        RegionalFits.(q_method).(locname)=struct();
        RegionalFits.(q_method).(locname).p_joint=p_joint;
        RegionalFits.(q_method).(locname).phi_post=posterior_A.phi;
        RegionalFits.(q_method).(locname).T_post=posterior_A.T;

    end

end

for il = 1:length(locs)
  locname = names{il};
  EnsemblePDF.(locname).p_joint=EnsemblePDF.(locname).p_joint/ 4; % equal weighting
  EnsemblePDF_no_mxw.(locname).p_joint=EnsemblePDF_no_mxw.(locname).p_joint/ 3; % equal weighting
end

plot_RegionalFits(RegionalFits,locs,names,location_colors,fig_prefix_dir,0,0,0);
plot_EnsemblePDFs(EnsemblePDF,EnsemblePDF_no_mxw,locs,names,location_colors,fig_prefix_dir,0,0,0,0,0);

AllEnsemble.RegionalFits  = RegionalFits;
AllEnsemble.EnsemblePDF  = EnsemblePDF;
AllEnsemble.EnsemblePDF_no_mxw  = EnsemblePDF_no_mxw;
save_ensembles(fig_prefix_dir,AllEnsemble);
