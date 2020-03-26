function [obs_value, obs_error] = process_SeismicModels( ...
    obs_name, location, model_file, ifplot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [prior, obs_error] = process_SeismicModels(obs_name, location, model_file)
%
% Load in seismic observations saved in model_file and return the prior.
%
% For a seismic observable 'obs_name' (Vs, Q, LAB), extract the observed
% value at a location gived in 'location' from the .mat file 'model_file'.
% Then calculate the prior probability distribution for that observable.
%
% Note that the prior distribution is assumed to be normal, with the
% observation defining the mean of the distribution and the uncertainty
% on the observation defining the standard deviation of the distribution.
%
% Parameters:
% -----------
%       obs_name    string of observation name, e.g. 'Vs', 'Qinv', 'LAB'
%
%       location    structure with the following required fields
%           lat         latitude [degrees North]
%           lon         longitude - assumed to be positive [degrees East]
%           z_min       minimum depth for observation range [km]
%           z_max       maximum depth for observation range [km]
%          (smooth_rad) half-width of box size in which to average
%                       observations - if this field is not in location,
%                       a default value of 0.5 is assumed [degrees E and N]
%
%       model_file  string with path to saved .mat file of observations
%                   This .mat file is expected to contain a single variable
%                   [obs_name]_Model with the following structure.
%           [obs_name]_Model    structure with the following fields
%               Latitude    n_lat vector of latitude points [degrees N]
%               Longitude   n_lon vector of longitude points [degrees E]
%                           (will add 360 degrees to negative values)
%               (Depth)     n_dep vector of depth points [km]
%                           (some observables, e.g. LAB, are not f(Depth))
%               [obs_name]  (n_lat, n_lon, n_dep) matrix of values of this
%                           seismic property based on observations
%               (Error)     (n_lat, n_lon, n_dep) matrix of uncertainty of
%                           this seismic property based on observations.
%                           This is often not reported!  In which case,
%                           a default value is assumed, with a message
%                           printed to the command line.
%
%       ifplot      set to True if want to plot the observation as a 
%                   function of depth
%
%
% Output:
% -------
%
%       obs_value   value of the observation at input location
%
%       obs_error   standard deviation of the observation, taken to be the
%                   maximum of the reported uncertainty on the measurement
%                   and the standard deviation within the averaging lat,
%                   lon, depth volume
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the models
Model = load(model_file);
varname = fieldnames(Model); % rename variable from its saved name
Model = Model.(varname{1});  % e.g. 'Vs_Model' to just 'Model'

% Check if there are any uncertainties saved in the model - if there
% are none, put in a constant error
Model=check_errors(Model, obs_name);


% Check model coordinate overlap and then limit measurements to
% coordinate ranges
[Model, returnCode] = check_overlap(Model, location);
if ~ returnCode
    return
end
Model = limit_by_coords(Model, obs_name, location);

% Find median and error
obs_value_z = find_median(Model, obs_name);
median_error_z = find_median(Model, 'Error');
lateral_error_z = find_lateral_error(Model, obs_name);
%fprintf('\n%s:  %g, %g\n', fieldname, median_error, lateral_error)
obs_error_z = max(median_error_z, lateral_error_z);


% Find the average value in depth
if isfield(Model, 'Depth')    
    [obs_value, obs_error] = limit_by_depth(obs_value_z, obs_error_z,...
        Model.Depth, location);
    
    if ifplot
        plot_seismic_obs(obs_value_z, obs_error_z, obs_name,...
            Model.Depth, location, obs_value, obs_error)
    end
else
    obs_value = obs_value_z;
    obs_error = obs_error_z;
end


end

function Model = check_errors(Model, field_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Model = check_errors(Model, field_name)
%
% Check to see if an 'Error' field exists in the model.  If it does not,
% create a field with some default, constant value.  Print to the command
% line that the error field was missing and the constant value assumed.
%
% Parameters:
% -----------
%       Model       structure with the following fields
%           Latitude    n_lat vector of latitude points [degrees N]
%           Longitude   n_lon vector of longitude points [degrees E]
%                       (will add 360 degrees to negative values)
%           (Depth)     n_dep vector of depth points [km]
%                      (some observables, e.g. LAB, are not f(Depth))
%           [obs_name]  (n_lat, n_lon, n_dep) matrix of values of this
%                       seismic property based on observations
%           (Error)     (n_lat, n_lon, n_dep) matrix of uncertainty of
%                       this seismic property based on observations.
%                       This is often not reported, in which case this
%                       field will be missing from this structure.
%
%       obs_name    string of observation name
%                       e.g. 'Vs', 'Qinv', 'LAB_Depth'
%
%
% Output:
% -------
%       Model       as input structure - if input was missing the field
%                   'Error', this has been filled in by some default,
%                   constant value.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(Model, 'Error')
    return
end

switch field_name
    case 'Vs'
        constant_error = 0.05;
    case 'LAB_Depth'
        constant_error = 5;
    case 'Q'
        constant_error = 10;
end

fprintf(['\nError field does not exist for %s - \n\t\t', ...
    'using a constant value of %g\n'], field_name, constant_error)

Model.Error = constant_error * ones(size(Model.(field_name)));

end

function [Model, returnCode] = check_overlap(Model, location)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [Model, returnCode] = check_overlap(Model, location)
%
% Check to see if the Model actually contains the location specified in
% 'location'.  Also, if the longitude values in Model are given as 
% negative numbers, add 360 degrees to them.
%
% Parameters:
% -----------
%       Model       structure with the following fields
%           Latitude    n_lat vector of latitude points [degrees N]
%           Longitude   n_lon vector of longitude points [degrees E]
%                       (will add 360 degrees to negative values)
%           (Depth)     n_dep vector of depth points [km]
%                      (some observables, e.g. LAB, are not f(Depth))
%           [obs_name]  (n_lat, n_lon, n_dep) matrix of values of this
%                       seismic property based on observations
%           (Error)     (n_lat, n_lon, n_dep) matrix of uncertainty of
%                       this seismic property based on observations.
%                       This is often not reported, in which case this
%                       field will be missing from this structure.
%
%       location    structure with the following required fields
%           lat         latitude [degrees North]
%           lon         longitude - assumed to be positive [degrees East]
%           z_min       minimum depth for observation range [km]
%           z_max       maximum depth for observation range [km]
%
%
% Output:
% -------
%       Model       as input structure - if longitude included negative
%                   values, these have been converted to positive (+ 360)
%
%       returnCode  Indication of if Model overlaps with desired location.
%                   Equal to 1 if ok, equal to 0 if there is an issue.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
returnCode=1;

% check for negative Longitudes, convert to positive
Model.Longitude(Model.Longitude < 0) = ...
    Model.Longitude(Model.Longitude < 0) + 360;

% global model limits
model_lims = [min(Model.Latitude), max(Model.Latitude);...
    min(Model.Longitude), max(Model.Longitude)];

% check that chosen coordinates are within measurements
if ~(...
        location.lat + location.smooth_rad >= model_lims(1,1) ...
        && location.lat - location.smooth_rad <= model_lims(1,2) ...
        && location.lon + location.smooth_rad >= model_lims(2,1) ...
        && location.lon - location.smooth_rad <= model_lims(2,2) ...
        )
    disp('Your coordinates are not within the model lat/lon bounds')
    returnCode=0;
    return
end

if isfield(Model, 'Depth')
    if ~(location.z_min >= Model.Depth(1) ...
            && location.z_max <= Model.Depth(end))
        disp('Your coordinates are not within the model depth bounds:')
        disp(Model.Depth([1, end]));
        returnCode=0;
        return
    end
    
end

end

function Model = limit_by_coords(Model, field_name, location)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Model = limit_by_coords(Model, field_name, location)
%
% Take the slice of Model that is defined by the box described in
% 'location'.  Keep the whole profile in depth.
%
%
% Parameters:
% -----------
%       Model       structure with the following fields
%           Latitude    n_lat vector of latitude points [degrees N]
%           Longitude   n_lon vector of longitude points [degrees E]
%                       (will add 360 degrees to negative values)
%           (Depth)     n_dep vector of depth points [km]
%                      (some observables, e.g. LAB, are not f(Depth))
%           [obs_name]  (n_lat, n_lon, n_dep) matrix of values of this
%                       seismic property based on observations
%           Error       (n_lat, n_lon, n_dep) matrix of uncertainty of
%                       this seismic property based on observations.
%                       This is often not reported, in which case this
%                       field will be missing from this structure.
%
%       field_name  string of observation name
%                       e.g. 'Vs', 'Qinv', 'LAB_Depth'
%
%       location    structure with the following required fields
%           lat         latitude [degrees North]
%           lon         longitude - assumed to be positive [degrees East]
%           z_min       minimum depth for observation range [km]
%           z_max       maximum depth for observation range [km]
%          (smooth_rad) half-width of box size in which to average
%                       observations - if this field is not in location,
%                       a default value of 0.5 is assumed [degrees E and N]
%
% Output:
% -------
%       Model       as input structure, but with only values retained
%                   in the box defined by 
%                       location.lat +- location.smooth_rad
%                       location.lon +- location.smooth_rad
%                       location.z_min to location.z_max
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create lat/lon masks
if isfield(location, 'smooth_rad')
    d_deg = location.smooth_rad;
else
    d_deg = 0.5; % default radius over which to average seismic model
end

lat = location.lat;
lon = location.lon;
lat_mask = (Model.Latitude >= lat - d_deg ...
    & Model.Latitude <= lat + d_deg);
lon_mask = (Model.Longitude >= lon - d_deg ...
    & Model.Longitude <= lon + d_deg);

% apply masks
Model.Longitude=Model.Longitude(lon_mask);
Model.Latitude=Model.Latitude(lat_mask);
Model.(field_name) = Model.(field_name)(lat_mask, lon_mask, :);
Model.Error = Model.Error(lat_mask, lon_mask, :);

end

function [obs_value, obs_error] = limit_by_depth(obs_value, obs_error,...
        depth, location)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [obs_value, obs_error] = limit_by_depth(obs_value, obs_error,...
%        depth, location)
%
% Take the observed values and errors as a function of depth and return
% the median value from the desired depth range.
%
%
% Parameters:
% -----------
%       obs_value   value of observation at the input location as a
%                   function of depth
%
%       obs_error   standard deviation of the observation as a 
%                   function of depth 
%
%        depth     n_dep vector of depth points [km] for observeable
%
%       location    structure with the following required fields
%           z_min       minimum depth for observation range [km]
%           z_max       maximum depth for observation range [km]
%
%
% Output:
% -------
%       obs_value   value of observation at the input location at a 
%                   given depth
%
%       obs_error   standard deviation of the observation at a given 
%                   depth
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

depth_mask = (depth >= location.z_min & depth <= location.z_max);
obs_value = median(obs_value(depth_mask), 'omitnan');
obs_error = median(obs_error(depth_mask), 'omitnan');



end



function medianVal = find_median(Model, field_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% medianVal = find_median(Model, field_name)
%
% Find the median value for 'field_name'(e.g. Vs, Qinv, LAB, Error).  It is
% assumed that Model has already been passed through limit_by_coords() -
% that is, that the median can be taken over all remaining values passed in
% via Model.
%
%
% Parameters:
% -----------
%       Model       structure with the following fields
%           Latitude    n_lat vector of latitude points [degrees N]
%           Longitude   n_lon vector of longitude points [degrees E]
%                       (will add 360 degrees to negative values)
%           (Depth)     n_dep vector of depth points [km]
%                      (some observables, e.g. LAB, are not f(Depth))
%           [obs_name]  (n_lat, n_lon, n_dep) matrix of values of this
%                       seismic property based on observations
%           Error       (n_lat, n_lon, n_dep) matrix of uncertainty of
%                       this seismic property based on observations.
%                       This is often not reported, in which case this
%                       field will be missing from this structure.
%
%       field_name  string of observation name
%                       e.g. 'Vs', 'Qinv', 'LAB_Depth', 'Error'
%
% Output:
% -------
%       medianVal   the median of all values in Model (as a function of
%                   depth if the observeable is known as f(depth))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allVals=Model.(field_name);
if isfield(Model, 'Depth')
    n_z = length(Model.Depth);
    medianVal = median(...
        reshape(allVals, numel(allVals) / n_z, n_z), 1, 'omitnan');
else
    medianVal = median( ...
        reshape(allVals, numel(allVals), 1), 1, 'omitnan');
end

end

function lateral_error = find_lateral_error(Model, field_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% lateral_error = find_lateral_error(Model, field_name)
%
% Calculate an estimate of the uncertainty on your model value by taking
% the standard deviation of all values within the observation box.
%
%
% Parameters:
% -----------
%       Model       structure with the following fields
%           Latitude    n_lat vector of latitude points [degrees N]
%           Longitude   n_lon vector of longitude points [degrees E]
%                       (will add 360 degrees to negative values)
%           (Depth)     n_dep vector of depth points [km]
%                      (some observables, e.g. LAB, are not f(Depth))
%           [obs_name]  (n_lat, n_lon, n_dep) matrix of values of this
%                       seismic property based on observations
%           Error       (n_lat, n_lon, n_dep) matrix of uncertainty of
%                       this seismic property based on observations.
%                       This is often not reported, in which case this
%                       field will be missing from this structure.
%
%       field_name  string of observation name
%                       e.g. 'Vs', 'Qinv', 'LAB_Depth'
%
% Output:
% -------
%       lateral_error   the standard deviation of all values in Model
%                       as a function of depth if the observeable is f(z)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allVals = Model.(field_name);
if isfield(Model, 'Depth')
    n_z = length(Model.Depth);
    lateral_error = std(...
        reshape(allVals, numel(allVals) / n_z, n_z), 0, 1, 'omitnan');
else
    lateral_error = std( ...
        reshape(allVals, numel(allVals), 1), 0, 1, 'omitnan');
end

end
