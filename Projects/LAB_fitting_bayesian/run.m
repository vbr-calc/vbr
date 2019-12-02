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


location.lat = 40; %lat; % degrees North
location.lon = 240; %lon; % degrees East
location.z_min = 100; % averaging min depth for asth.
location.z_max=150; % averaging max depth for asth.
location.smooth_rad = 5;


filenames.Vs = './data/vel_models/Shen_Ritzwoller_2016.mat';
filenames.Q = './data/Q_models/Gung_Romanowicz_2002.mat';
filenames.LAB = './data/LAB_models/HopperFischer2018.mat';

% Extract the relevant values for the input depth range.
% Need to choose the attenuation method used for anelastic calculations
%       see possible methods by running vbrListMethods()
q_method = 'andrade_psp';


posterior_A = fit_seismic_observations(filenames, location, q_method);

posterior_L = fit_plate(filenames, location, q_method, posterior_A);


