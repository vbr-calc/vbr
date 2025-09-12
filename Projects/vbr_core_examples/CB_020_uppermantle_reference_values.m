function VBR = CB_020_uppermantle_reference_values()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CB_020_uppermantle_reference_values.m
%
%  Demonstrates usage of the upper mantle scaling
%  calculating unrelaxed moduli.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    VBR = struct();

    % use upper_mantle for reference, temperature and pressure scaling
    VBR.in.elastic.methods_list={'anharmonic';};
    VBR.in.elastic.anharmonic.reference_scaling = 'upper_mantle';
    VBR.in.elastic.anharmonic.temperature_scaling = 'upper_mantle';
    VBR.in.elastic.anharmonic.pressure_scaling = 'upper_mantle';

    VBR.in.SV.T_K = linspace(1000, 1300, 100)+273;
    sz_T = size(VBR.in.SV.T_K);
    VBR.in.SV.P_GPa = linspace(2, 3, 100);
    VBR.in.SV.rho = 3300 * ones(sz_T);

    VBR = VBR_spine(VBR);

    % calculate a default case at same conditions
    VBR2 = struct();
    VBR2.in.elastic.methods_list={'anharmonic';};
    VBR2.in.SV = VBR.in.SV;
    VBR2 = VBR_spine(VBR2);

    if ~vbr_tests_are_running()
        figure('PaperPosition',[0,0,7,4],'PaperPositionMode','manual')
        subplot(1,2,1)
        plot(VBR.in.SV.P_GPa, VBR.out.elastic.anharmonic.Gu/1e9,'k',...
             'displayname','upper mantle', 'linewidth',1.5)
        xlabel("P [GPa]", 'fontsize',12)
        ylabel("G_u [GPa]", 'fontsize',12)
        hold on 

        plot(VBR2.in.SV.P_GPa, VBR2.out.elastic.anharmonic.Gu/1e9,'color',[0,0.8,0.],...
        'displayname','default olivine',  'linewidth',1.5)

        legend('location', 'southwest')

        subplot(1,2,2)
        plot(VBR.in.SV.P_GPa, VBR.in.SV.T_K-273,'k', 'linewidth',1.5)
        xlabel('P [GPa]', 'fontsize',12)
        ylabel('T [C]', 'fontsize',12)
        saveas(gcf,'./figures/CB_020_uppermantle_reference_values.png')
    end



end