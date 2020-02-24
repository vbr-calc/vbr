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


filenames.Vs = './data/vel_models/Shen_Ritzwoller_2016.mat';
filenames.Q = './data/Q_models/Dalton_Ekstrom_2008.mat';
filenames.LAB = './data/LAB_models/HopperFischer2018.mat';

f = figure('color', 'w'); 
a = axes('position', [0.15, 0.15, 0.75, 0.75]); box on; hold on;

for il = 1:length(locs)
    location.lat = locs(il, 1); % degrees North\
    location.lon = locs(il, 2) + 360; % degrees East
    location.z_min = zrange(il, 1); % averaging min depth for asth.
    location.z_max= zrange(il, 2); % averaging max depth for asth.
    location.smooth_rad = 0.5;
    locname = names{il};

    
    % Extract the relevant values for the input depth range.
    % Need to choose the attenuation method used for anelastic calculations
    %       see possible methods by running vbrListMethods()
    q_method = 'andrade_psp'; %'eburgers_psp' 'xfit_mxw', 'xfit_premelt' 'andrade_psp'
    
    posterior_A = fit_seismic_observations(filenames, location, q_method);

    
    
    % Plot
    figure(f)
    cutoff = 0.00075;
    posterior = posterior_A.pS;
    posterior = posterior ./ sum(posterior(:));
    sh = size(posterior);
    p_marginal = sum(sum(posterior, 1), 2);
    p_marginal_box = repmat(p_marginal, sh(1), sh(2), 1);
    p_joint = sum(posterior .* p_marginal_box, 3);
    p_joint(p_joint > cutoff) = il;
    p_joint(p_joint <= cutoff) = il - 0.5;
    contour(posterior_A.phi, posterior_A.T, p_joint, [1, 2, 3, 4], 'linewidth', 2)

    
end

colormap(flipud(jet))
xlabel('Melt Fraction \phi');
ylabel('Temperature (\circC)');
title(strrep(q_method, '_', ' '));


