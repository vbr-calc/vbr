function plot_slice(sweep, fieldname, fixed_vals)




f = figure('position', [400, 400, 2050, 600], 'color', 'w');

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

% Find indices of fixed values
ref_inds = zeros(size(fixed_vals));
for i_f = 1:length(fixed_vals)
    [~, ref_inds(i_f)] = min(abs(sweep.(fields{i_f}) - fixed_vals(i_f)));
end

% Pick 

% Plot up panels to show the trade-offs
val = sweep.(['mean', fieldname]);
a1 = plot_panel(squeeze(val(ref_inds(1), :, :)), sweep, [2, 3, 1], fixed_vals);
a2 = plot_panel(squeeze(val(:, ref_inds(2), :)), sweep, [1, 3, 2], fixed_vals);
a3 = plot_panel(squeeze(val(:, :, ref_inds(3))), sweep, [1, 2, 3], fixed_vals);

switch fieldname
    case 'Vs'
        c_label = 'Vs (km/s)';
    case 'Q'
        c_label = fieldname;
end
make_colourbars_uniform([a1, a2, a3], c_label)

titstr = '';
for nm = 1:length(fnames_short)
    titstr = [titstr, fnames_short{nm}, ', '];
end
titstr = sprintf('%s as a function of %s  (%.1g GPa, %.0f - %.0f s)', ...
    fieldname, titstr(1:end-2), mean(sweep.P_GPa(sweep.z_inds)), ...
    sweep.per_bw_min, sweep.per_bw_max);
axes('position', [0, 0, 1, 1], 'visible', 'off');
text(0.37, 0.95, titstr, 'fontsize', 20, 'fontweight', 'bold')



end

function ax = plot_panel(value, sweep, order, fixed_vals)

i1 = order(1); i2 = order(2); i3 = order(3);
xpos = 0.1 + 0.3 * (i3 - 1);
ax = axes('position', [xpos, 0.15, 0.225, 0.7]);

% For each pair of parameters, plot the tradeoff in the seismic
% property
fields = sweep.state_names;
imagesc(sweep.(fields{i2}), sweep.(fields{i1}), value);
xlabel(sweep.fnames{i2})
ylabel(sweep.fnames{i1});
set(ax, 'ydir', 'normal', 'fontsize', 18)
titstr = strsplit(sweep.fnames{order(end)}, '(');
if length(titstr) > 1
    title(sprintf('%s fixed at %g %s', titstr{1}, ...
        fixed_vals(order(end)), titstr{2}(1:end-1)));
else
    title(sprintf('%s fixed at %g', titstr{1}, ...
        fixed_vals(order(end))));
end

end

function make_colourbars_uniform(ax_handles, c_label)

cl = 1e10 * [1, -1];

for ax = ax_handles
    cl_a = get(ax, 'CLim');
    cl(1) = min(cl(1), cl_a(1));
    cl(2) = max(cl(2), cl_a(2));
end

cl = cl + diff(cl) / 8 * [1, -1];

for ax = ax_handles
    axes(ax)
    c = colorbar;    
    ylabel(c, c_label);
    set(ax, 'CLim', cl)
    colormap([linspace(220, 0, 25)' ./ 255, ...
        linspace(50, 90, 25)' ./ 255, ...
        linspace(32, 181, 25)' ./ 255]);
end



end