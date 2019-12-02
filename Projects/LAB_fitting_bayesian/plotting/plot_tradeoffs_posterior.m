function plot_tradeoffs_posterior(posterior, sweep, obs_name, q_method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_tradeoffs_posterior(posterior, sweep, obs_name)
%
% Plot the posterior probability distribution across the parameter ranges
% in sweep.
%
% Parameters:
% -----------
%      posterior           (size(sweep.Box)) matrix of posterior
%                          probability for each parameter combination
%
%      sweep               structure with the following fields
%               state_names     cell of the names of the varied parameters
%               [param name]    vector of the range of values that were
%                               calculated
%               Box             output of VBR calculation
%               (also other fields recording values relevant to the
%               calculation)
%
%       obs_name            string of the observation name, e.g. Vs, Qinv
%                           Only used to label the figure.
%       
%       q_method            string of the method to use for calculating
%                           the anelastic effects on seismic properties.
%                           Only used to label the figure.
%
% Output:
% -------
%       Plot of the posterior probability distribution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

q_method = strrep(q_method, '_', '\_');


f = figure('position', [400, 200, 1300, 700], 'color', 'w');
posterior = posterior ./ sum(posterior(:));

% Write out names and units
fields = sweep.state_names;
fnames{length(fields)} = '';
fnames_short{length(fields)} = '';
for n = 1:length(fields)
    switch fields{n}
        case 'T'
            fnames{n} = 'Temperature (\circC)';
            fnames_short{n} = 'T';
        case 'phi'
            fnames{n} = 'Melt Fraction, \phi';
            fnames_short{n} = '\phi';
        case 'gs'
            fnames{n} = 'Grain Size (mm)';
            fnames_short{n} = 'd';
            sweep.(fields{n}) = sweep.(fields{n}) ./ 1e3; % convert to mm
    end
end

sweep.fnames = fnames;

% Plot up panels to show the trade-offs

plot_box(posterior, sweep, 2, 3, 1);
plot_box(posterior, sweep, 1, 3, 2);
plot_box(posterior, sweep, 1, 2, 3);

titstr = '';
for nm = 1:length(fnames_short)
    titstr = [titstr, fnames_short{nm}, ', '];
end
titstr = [titstr(1:end-2), ' | ', obs_name];
tax = axes('position', [0, 0, 1, 1], 'visible', 'off');
text(0.37 - length(obs_name)/300, 0.95,...
    ['p(', titstr, '), using ', q_method], 'fontsize', 16, 'fontweight', 'bold')





end

function plot_box(posterior, sweep, i1, i2, i3)


xpos = 0.1 + 0.3 * (i3 - 1);
ax = axes('position', [xpos, 0.5, 0.225, 0.4]);

sh = size(posterior);
sh(i3) = 1;


% Calculate limits for the color scales so all subplots will be on 
% the same scale
marg_sc = max([...
    max(sum(sum(posterior, 1), 2)), ...
    max(sum(sum(posterior, 2), 3)), ...
    max(sum(sum(posterior, 1), 3))]);
joint_sc = max([...
    max(median(sum(posterior, 1))), ...
    max(median(sum(posterior, 2))), ...
    max(median(sum(posterior, 3))), ...
    ]) * marg_sc;

% For each pair of parameters, plot the joint probability
% i.e. p(T, phi) = sum_over_g(p(T, phi | g) p(g))
p_marginal = sum(sum(posterior, i1), i2);
p_marginal_box = repmat(p_marginal, sh(1), sh(2), sh(3));
p_joint = sum(posterior .* p_marginal_box, i3);
imagesc(sweep.(sweep.state_names{i2}), sweep.(sweep.state_names{i1}), ...
    reshape(p_joint, sh(i1), sh(i2)));
xlabel(sweep.fnames{i2})
ylabel(sweep.fnames{i1});
set(ax, 'ydir', 'normal')
caxis([0, joint_sc])

ax2 = axes('position', [xpos, 0.375, 0.225, 0.05]);
plot(reshape(sweep.(sweep.state_names{i3}), 1, []), ...
    reshape(p_marginal, 1, []))
set(ax2, 'color', 'none', 'ycolor', 'none', 'box', 'off');
xlabel(sweep.fnames{i3});
ylim([0, marg_sc])

ax3 = axes('position', [xpos, 0.15, 0.225, 0.05]);
patch(sweep.P_GPa(sweep.z_inds([1, end, end, 1, 1])), [0, 0, 1, 1, 0], 'b');
xlim(sweep.P_GPa([1, end]))
set(ax3, 'color', 'none', 'ycolor', 'none', 'box', 'off', ...
    'xaxislocation', 'top');
xlabel('Pressure (GPa)');
ax4 = axes('position', [xpos, 0.15, 0.225, 0.01]);
plot_z = zeros(size(sweep.P_GPa));
plot(sweep.z./1000, plot_z, 'linestyle', 'none')
set(ax4, 'color', 'none', 'ycolor', 'none', 'box', 'off');
xlabel('Depth (km)')


end