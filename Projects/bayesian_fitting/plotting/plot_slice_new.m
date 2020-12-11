function plot_slice_new(sweep, fixed_vals, fnameout)

f = figure('position', [400, 400, 2050, 1200], 'color', 'w',...
    'paperorientation','landscape','paperunits','inches','paperposition',[0,0,18,10]);

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


[sweep.meanVs, sweep.z_inds] = extract_calculated_values_in_depth_range(...
    sweep, 'Vs', 'andrade_psp', [55, 65]);    
sweep.meanQ = extract_calculated_values_in_depth_range(sweep, ...
    'Q', 'andrade_psp', [55, 65]);    

sweep = apply_limits(sweep);


% Plot up panels to show the trade-offs
  fieldnames = {'Vs';'Q'};
  for ifld = 1:numel(fieldnames)
    fieldname = fieldnames{ifld};
    
    val = sweep.(['mean', fieldname]);
    a1 = plot_panel(squeeze(val(ref_inds(1), :, :)), sweep, [2, 3, 1], fixed_vals,ifld);
    a2 = plot_panel(squeeze(val(:, ref_inds(2), :)), sweep, [1, 3, 2], fixed_vals,ifld);
    a3 = plot_panel(squeeze(val(:, :, ref_inds(3))), sweep, [1, 2, 3], fixed_vals,ifld);

    switch fieldname
        case 'Vs'
            c_label = 'Vs (km/s)';
            cl = [4.1,4.6];
        case 'Q'
            c_label = fieldname;
            cl = [10,150]; 
    end
    make_colourbars_uniform([a1, a2, a3], c_label,cl)

    titstr = '';
    for nm = 1:length(fnames_short)
        titstr = [titstr, fnames_short{nm}, ', '];
    end
    
    
  end
  
  titstr = sprintf('Vs, Q as a function of %s  (%.1g GPa, %.0f - %.0f s)', ...
      titstr(1:end-2), mean(sweep.P_GPa(sweep.z_inds)), ...
      sweep.per_bw_min, sweep.per_bw_max);
  axes('position', [0, 0, 1, 1], 'visible', 'off');
  text(0.4, 0.93, titstr, 'fontsize', 14, 'fontweight', 'bold')

saveas(f,[fnameout,'.png'])
saveas(f,[fnameout,'.eps'],'epsc')
end

function ax = plot_panel(value, sweep, order, fixed_vals,ifld)

    i1 = order(1); i2 = order(2); i3 = order(3);
    xpos = 0.1 + 0.3 * (i3 - 1);
    ypos = 0.55 - 0.35 * (ifld -1);
    % disp(ypos)
    ax = axes('position', [xpos, ypos, .225, 0.3]);
    % [left bottom width height]
    % [xpos, 0.15, 0.225, 0.7]

    % For each pair of parameters, plot the tradeoff in the seismic
    % property
    fields = sweep.state_names;
    % imagesc(sweep.(fields{i2}), sweep.(fields{i1}), value);
    contourf(sweep.(fields{i2}), sweep.(fields{i1}), value,100,'linestyle','none');
    hold on 
    contour(sweep.(fields{i2}), sweep.(fields{i1}), value,'--k');
    hold off
    if ifld == 1
      xlabel('')
    else 
      xlabel(sweep.fnames{i2})
    end 
    ylabel(sweep.fnames{i1});
    set(ax, 'ydir', 'normal', 'fontsize', 12)
    
    if ifld == 1
      titstr = strsplit(sweep.fnames{order(end)}, '(');
      if length(titstr) > 1
          title(sprintf('%s fixed at %g %s', titstr{1}, ...
              fixed_vals(order(end)), titstr{2}(1:end-1)));
      else
          title(sprintf('%s fixed at %g', titstr{1}, ...
              fixed_vals(order(end))));
      end
    end 

end

function make_colourbars_uniform(ax_handles, c_label, cl)
  
    column_num = 1;
    for ax = ax_handles
        axes(ax)
        if column_num < 4
            c = colorbar;    
            ylabel(c, c_label)
        end 
        set(ax, 'CLim', cl,'fontsize',14)
        colormap([linspace(220, 0, 25)' ./ 255, ...
            linspace(50, 90, 25)' ./ 255, ...
            linspace(32, 181, 25)' ./ 255]);
        column_num = column_num + 1; 
    end
end

function meanvals = limitmeanvals(sweep,meanvals,phimax,Tmax) 
    meanvals = meanvals(:,sweep.phi<=phimax,:);
    meanvals = meanvals(sweep.T<=Tmax,:,:);
end 
function sweep = apply_limits(sweep)
  
  
  
  phimax = 0.03; 
  Tmax = 1700; 
  sweep.meanVs = limitmeanvals(sweep,sweep.meanVs,phimax,Tmax); 
  sweep.meanQ = limitmeanvals(sweep,sweep.meanQ,phimax,Tmax); 
  sweep.phi = sweep.phi(sweep.phi<=phimax);
  sweep.T = sweep.T(sweep.T<=Tmax);
  
end 
