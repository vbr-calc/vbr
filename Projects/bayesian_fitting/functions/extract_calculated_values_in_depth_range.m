function [mean_val, z_inds] = extract_calculated_values_in_depth_range(...
    sweep, obs_name, q_method, depth_range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sweep = extract_calculated_values_in_depth_range(sweep, depth_range)
%
% For each element and Q method in the large (pre-calculated) sweep,
% find the calculated mean Vs and mean Q in the relevant depth range.
%
% Parameters:
% -----------
%      sweep               structure with the following fields
%               z               vector of depths [m]
%               Box             structure, described separately below
%               (also other fields recording values relevant to the
%               calculation)
%
%       sweep.Box          (numel(sweep_params.T) x numel(sweep_params.phi)
%                           x numel(sweep_params.gs)) structure.  Each 
%                          element contains a field for each of the 
%                          anelastic methods in given in
%                          sweep.VBR.in.anelastic.methods_list
%
%       sweep.Box.[anelastic method name]
%                           structure with the following fields
%               meanVs          vector of calculated Vs (mean within the
%                               given frequency range) [km/s]
%               meanQinv        vector of calculated attentuation (mean
%                               within the given frequency range) 
%
%       obs_name            string of the observation name, e.g. Vs, Qinv
%                           there must be a field
%                              sweep.Box.[anelastic method].mean_[obs_name]
%
%       q_method            string of the method to use for calculating
%                           the anelastic effects on seismic properties
%
%       depth range         Two element vector giving the [min. depth, 
%                           max. depth] of interest [km]
%
% Output:
% -------
%       mean_val        numel(sweep.Box) vector of mean calculated values
%                       from the specified depth range only
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


mean_val = zeros(size(sweep.Box));
depth_range = depth_range .* 1e3;
z_inds = find(depth_range(1) <= sweep.z & sweep.z <= depth_range(2));

for k = 1:numel(sweep.Box)
    mean_val(k) = mean( ...
        sweep.Box(k).(q_method).(['mean', obs_name])(z_inds));
    
end

end