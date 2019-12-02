function plotFits(BoxFile,fits,seismic_obs,settings)
%    %    %    %    %    %    %    %
%          PLOT EVERYTHING         %
%    %    %    %    %    %    %    %
Layout = buildLayout(1);
figure('color','w','position',[50 30 1200 600]);

% Q(Z) plot
load(BoxFile)
freq_range=sort([1/settings.per_bw_max 1/settings.per_bw_min]);
freqs=VBR(1).in.SV.f;
f_mask=(freqs>=freq_range(1) & freqs <= freq_range(2));
% plot_Q_profiles(Layout.Qz, VBR, fits, seismic_obs, f_mask,settings);

Qplot.varname='Q';
Qplot.axlims = [10^1 10^8; 0 350];
Qplot.use_log=1;
Qplot.unit_conv_factor=1;
Qplot.title_text='Fit LAB depth with Q_L_A_B';
Qplot.xlabel_text='Log_1_0(Q)';
Qplot.ylabel_text='Depth (km)';
plot_profiles(Qplot,Layout.Qz, VBR, fits, seismic_obs, f_mask,settings);

Vsplot.varname='V';
Vsplot.axlims = [4.0 5.05; 0 350];
Vsplot.use_log=0;
Vsplot.unit_conv_factor=1e-3;
Vsplot.title_text='Fit V_s in asth.';
Vsplot.xlabel_text='V_s (km/s)';
Vsplot.ylabel_text='Depth (km)';
plot_profiles(Vsplot,Layout.Vsz, VBR, fits, seismic_obs, f_mask,settings);

% % Residuals (can plot up to two 'temps' at a time)
layout = Layout.rh;  clr = [1 0 0];
Tpot_vec = VBR(1).BoxParams.var1range;
zPlate_vec = VBR(1).BoxParams.var2range;
residPlots(layout, Tpot_vec, zPlate_vec, fits, clr)

end

function plot_profiles(PlotSets,layout, Box, fits, seismic_obs,f_mask,settings)
%  *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   %
%  Plots all of the Q profiles and the best fitting profiles   %
%  *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   %

  q_method=settings.q_method;
  varname=PlotSets.varname;
  use_log=PlotSets.use_log;
  unit_conv_factor=PlotSets.unit_conv_factor;

  axes('position',layout); hold on; box on;
  [n_var1, n_var2] = size(Box);

  % plot Q profiles
  for i_var1 = 1:n_var1
      for i_var2 = 1:n_var2
          Z_km = Box(i_var1, i_var2).Z_km;
          var_fz = Box(i_var1, i_var2).out.anelastic.(q_method).(varname);
          var_fz=var_fz(:,f_mask);
          var_z=unit_conv_factor*mean(var_fz,2);
          if use_log
            var_z=log10(var_z);
          end
          p1 = plot(var_z,Z_km,'k-','linewidth',1);

          % p1.Color(4) = 0.2; % breaks Octave
      end
  end

  % best Q
  clr = [1 0 0];
  alph=0.9;
  i_best = fits.bestJoint.var1_i;
  j_best = fits.bestJoint.var2_i;
  Z_km = Box(i_best,j_best).Z_km;
  var_fz = Box(i_best,j_best).out.anelastic.(q_method).(varname);
  var_fz=var_fz(:,f_mask);
  var_z=unit_conv_factor*mean(var_fz,2);
  if use_log
    var_z=log10(var_z);
  end
  plot(var_z,Z_km,'-','color',clr,'linewidth',2);


  % Plot best fitting Z_LAB from best Q profile
  Z_LAB_Q_km = fits.fixed_Tp.zPlate;
  fprintf('\nLAB depth from Q:   %.1f km\n', Z_LAB_Q_km);
  x_locs=PlotSets.axlims(1,:);
  if use_log
    x_locs=log10(x_locs);
  end
  p2 = plot(x_locs,Z_LAB_Q_km*[1 1],':','color',clr,'linewidth',2);
  % p2.Color(4) = 0.5;
  %
  % Observed plate thickness line
  p3 = plot(x_locs, seismic_obs.LAB*[1 1],'-','color',clr,'linewidth',7);
  % p3.Color(4) = 0.2;

  xlim(x_locs); ylim(PlotSets.axlims(2,:));
  title(PlotSets.title_text); xlabel(PlotSets.xlabel_text);
  ylabel(PlotSets.ylabel_text); axis ij; set(gca,'XAxisLocation','Top')


end

function residPlots(layouts, Tpot_vec, zPlate_vec, fits, clr)
  %  *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   %
  %  Plots the residual profiles                                 %
  %  *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   %

  ij_best = fits.fixed_Tp.ij_best;
  ij_best = [fits.bestJoint.var1_i fits.bestJoint.var2_i];

  % imagesc pixel locations
  x_pts=[zPlate_vec(1) zPlate_vec(end)];
  y_pts=[Tpot_vec(1) Tpot_vec(end)];

  % imagesc limits
  dx = zPlate_vec(2) - zPlate_vec(1);
  dy = Tpot_vec(2) - Tpot_vec(1);
  x_lims = [zPlate_vec(1)-dx/2 zPlate_vec(end)+dx/2];
  y_lims = [Tpot_vec(1)-dy/2 Tpot_vec(end)+dy/2];

  % Plot the residuals for ZLAB
  axes('position', layouts.c1); hold on; box on;
  imagesc(x_pts, y_pts,log10(fits.resids.P_zLAB));
  colormap(gray)
  scatter(zPlate_vec(ij_best(2)), Tpot_vec(ij_best(1)), 10, clr,'filled')
  title(['Res: Z_L_A_B']);
  xlabel('Z_p_l_a_t_e (km)'); ylabel('T_p_o_t (\circC)');
  xlim(x_lims); ylim(y_lims); axis ij

  % Plot the residuals for Vs_adavg
  axes('position', layouts.c2); hold on; box on;
  imagesc(x_pts, y_pts, log10(fits.resids.P_Vs));
  colormap(gray)
  scatter(zPlate_vec(ij_best(2)), Tpot_vec(ij_best(1)), 10, clr,'filled')
  title('Res: V_s');
  xlabel('Z_p_l_a_t_e (km)');
  set(gca,'YTickLabel', []);
  xlim(x_lims); ylim(y_lims); axis ij;

  % Plot the residuals for Vs_adavg
  axes('position', layouts.c3); hold on; box on;
  imagesc(x_pts, y_pts, log10(fits.resids.P_Joint));
  colormap(gray)
  scatter(zPlate_vec(ij_best(2)), Tpot_vec(ij_best(1)), 10, clr,'filled')
  title('Joint Prob');
  xlabel('Z_p_l_a_t_e (km)');
  set(gca,'YTickLabel', []);
  xlim(x_lims); ylim(y_lims); axis ij


end

function Layout = buildLayout(num_inpt)

  % Depth plots
  L1 = 0.06;
  B1 = 0.1;
  W1 = 0.15;
  H1 = 0.7;

  Layout.Qz  = [L1, B1, W1, H1];
  Layout.Vsz = [L1+W1+0.05, B1, W1, H1];


  % Residual plots
  hdel = 0.015;
  hdX = 10.5*hdel;
  if num_inpt == 2
      % top row
      Layout.rh.c1 = [Layout.Vsz(1)+Layout.Vsz(3)+hdel*4, B1+0.5, 0.165,0.275];
      Layout.rh.c2 = [Layout.rh.c1(1)+hdX+hdel, Layout.rh.c1(2:end)];
      Layout.rh.c3 = [Layout.rh.c2(1)+hdX+hdel, Layout.rh.c1(2:end)];

      % bottom row
      Layout.rb.c1 = [Layout.Vsz(1)+Layout.Vsz(3)+hdel*4, B1+0.05, 0.165, 0.275];
      Layout.rb.c2 = [Layout.rb.c1(1)+hdX+hdel, Layout.rb.c1(2:end)];
      Layout.rb.c3 = [Layout.rb.c2(1)+hdX+hdel, Layout.rb.c1(2:end)];
  elseif num_inpt == 1
      Layout.rh.c1 = [Layout.Vsz(1)+Layout.Vsz(3)+hdel*4, B1+mean([0.05,0.5]),...
          0.165,0.275];
      Layout.rh.c2 = [Layout.rh.c1(1)+hdX+hdel, Layout.rh.c1(2:end)];
      Layout.rh.c3 = [Layout.rh.c2(1)+hdX+hdel, Layout.rh.c1(2:end)];
  end


end
