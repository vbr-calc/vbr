function dg_um = PiezometerWH2006(sig_MPa)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % d_um = PiezometerWH2006(sig_MPa)
        %
        % returns an array of the same size as sig with grainsizes in um calculcated
        % using the rectysallized grain-size piezometer for olivine of Warren and
        % Hirth (2006). If no stress is specified the function simply produces a
        % plot of the piezometer, the data it was regressed to, and its uncertainty.
        %
        % Citation:
        %   Warren, J. M., & Hirth, G. (2006). Grain size sensitive deformation
        %   mechanisms in naturally deformed peridotites. Earth and Planetary
        %   Science Letters, 248(1-2), 438-450.
        %   https://doi.org/10.1016/j.epsl.2006.06.006
        %
        % Parameters:
        % ----------
        % sig_MPa: array | scalar
        %    differential stress in MPa. Can be an array of any shape or a scalar.
        %    If not provided, this function will make a plot.
        %
        % Output:
        % ------
        % d_um: array | scalar
        %     grain size in um, same shape as the input sig_MPa
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if exist("sig_MPa",'var')
            dg_um = 10.^(log10(sig_MPa).*-1.3370+4.1755); %mu, grain size
        else
            % Piezometer: Karato et al. (1980) and Van der Wal et al. (1993)
            % The original data in the next lines was used in a linear least squares
            % regression to obtain the values below for the piezometer:
            dk=[193.981 135.123 86.447 118.934 86.447 46.159 45.670 59.580 40.199 39.773 30.488 24.910]';	% Microns
            sk=[25.035 34.719 41.538 49.697 55.225 63.342 72.652 85.106 86.921 102.901 121.820 135.372]';	% MPa
            dvdw=[21 18 14 57 29 8.2 52 28 30 30 17 16 14 18 19 21 17 15]';	% Microns
            svdw=[146 174 212 58 119 284 63 85 88 90 127 146 188 120 132 102 150 266]';	% MPa
            gs = logspace(0,4,10); %um, grainsize
            sigma_range = logspace(-1,3,10); %MPa, differential stress
            m=-1.3370;		% Slope from lsqfitma regression of x on y and y on x
            sm=0.0791;		% Standard deviation of the slope
            b=4.1755;		% Intercept from lsqfitma regression of x on y and y on x
            sb=0.1133;		% Standard deviation of the y-intercept
            sfit(:,1)=((log10(gs')-b)./m);				% Log10(Stress) in MPa
            sfit(:,2)=((log10(gs')-(b-sb))./(m+sm));	% Error in stress
            sfit(:,3)=((log10(gs')-(b+sb))./(m-sm));	% Error in stress

            dfit = 10.^(log10(sigma_range).*m+b); %mu, grain size

            % plot
            figure; hold on
            scatter(dk,sk,'red','filled','o')
            scatter(dvdw,svdw,'blue','filled','d')
            plot(gs',10.^sfit(:,1),'k-','linewidth',2);	% Regression line through exp. data
            plot(gs',10.^sfit(:,2),'k:','linewidth',0.5);	% Plot error
            plot(gs',10.^sfit(:,3),'k:','linewidth',0.5);	% Plot error
            plot(dfit,sigma_range,'k--','linewidth',2)
            xlabel('Grainsize (\mum)')
            ylabel('Stress (MPa)')
            set(gca,'XScale','log')
            set(gca,'YScale','log')
            legend('Karato et al. (1980)', 'Van der Wal et al. (1993)', 'Combined regression', 'error')
            box on
        end