function plot_seismic_obs(obs_value_z, obs_error_z, obs_name, depth, ...
    location, median_obs, median_obs_std)


units = '';
switch obs_name
    case 'Vs'
        units = 'km/s';
end



figure('position', [400, 200, 500, 700], 'color', 'w');
axes('position', [0.2, 0.2, 0.7, 0.7], 'xaxislocation', 'top');
hold on;
patch([obs_value_z + obs_error_z, fliplr(obs_value_z - obs_error_z)], ...
    [depth, fliplr(depth)], [0.8, 0.8, 0.8], 'linestyle', 'none')
plot(obs_value_z, depth, 'linewidth', 2); 
axis ij
if isempty(units)
    xlabel(obs_name)
else
    xlabel([obs_name, ' (', units ')'])
end
ylabel('Depth (km)')

xl = get(gca, 'xlim');
plot(xl([1, 2, 2, 1, 1]), [location.z_min, location.z_min, ...
    location.z_max, location.z_max, location.z_min], 'r:')
title(sprintf(['%s = %.2g ', 177, ' %.2g %s (%g - %g km)'], ...
    obs_name, median_obs, median_obs_std, units, location.z_min, ...
    location.z_max));
    





end