function Cp = SpecificHeat(T, FracFo)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Cp = SpecificHeat(T,FracFo)
    %
    % Calculates specific heat as a function of temperature using a polynomial.
    %
    % Parameters
    % ----------
    %
    %   T: array or scalar
    %      temperature in degrees K
    %   FracFo: array or scalar
    %       volume fraction forsterite
    %
    % Returns
    % -------
    %   Cp: array or scalar
    %       Specific Heat [J kg^-1 K^-1]
    %
    % References
    % ----------
    % Berman, R. G., and L. Ya Aranovich. "Optimized standard     %
    %   state and solution properties of minerals." Contributions to Mineralogy%
    %   and Petrology 126.1-2 (1996): 1-24.
    %
    % Notes
    % -----
    %
    % Papers report heat capacity (J/mol/K) as polynomial functions of
    % temperature with coefficients determined by fitting. To get to specific
    % heat (J/kg/K), we divide the reported coefficients by molecular weight of
    % the minerals. The function form is typically:
    %
    %  Cp = B(1) + B(2)*T + B(3)*T^2 + B(4)*T^-2 + B(5)*T^-3 + ...
    %       B(6)*T^-0.5 + B(7)/T
    %
    % In this implementation, the array B initially has two rows, with values
    % for forsterite (Fo) in the first row and fayalite (Fa) in the second row.
    % The two are then linearly weighted by the fraction of forsterite in the
    % mantle before calculating Cp.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Need molecular weights of forsterite (Mg2Si04) and fayalite (Fe2SiO4):
    % (reminder, 1 atomic unit = 1 g / mol = 1e-3 kg / mol)
      wt_Fo = (24.305*2+28.085 + 15.999*4)/1000; % [kg/mol]
      wt_Fa = (55.845*2+28.085 + 15.999*4)/1000; % [kg/mol]

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHOOSE WHICH FIT TO USE %
    % (pretty much the same)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                                        %
    % Fitting 1: Saxena, S. K. "Earth mineralogical model: Gibbs free energy %
    % minimization computation in the system MgO-FeO-SiO2." Geochimica et    %
    % cosmochimica acta 60.13 (1996): 2379-2395.                             %
    %                                                                        %
    % Fitting 2: Berman, R. G., and L. Ya Aranovich. "Optimized standard     %
    % state and solution properties of minerals." Contributions to Mineralogy%
    % and Petrology 126.1-2 (1996): 1-24.                                    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % % FITTING 1
    %    B = [165.80 0.1855*1e-1 0.0 -3971000 0.28161*1e9 0.0 -5610.0; ...
    %         104.45 0.4032*1e-2 0.0 2947000 -.3941*1e9 0.0 -173330.0];

    % FITTING 2: Berman and Aranovich, Contrib. Mineral. Petrol. 1996
    B = zeros(2,7);
    B(1,1)=233.18; B(1,6)=-1801.6;B(1,5)=-26.794*1e7;  % Fo values
    B(2,1)=252;B(2,6)=-2013.7; B(2,5)=-6.219*1e7;  % Fe values


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % convert from heat capacity to specific heat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    B(1,:) = B(1,:) / wt_Fo; % [J/mol/K to J/kg/K]
    B(2,:) = B(2,:) / wt_Fa; % [J/mol/K to J/kg/K]

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate specific heat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FracFa = 1 - FracFo;
    % using a loop here to allow for FracFo as a matrix
    for i_order = 1:7
        % calcuate composition-weighted polynomial coefficient
        B_i = B(1, i_order) * FracFo + B(2, i_order) * FracFa;
        % add on the contribution from the current polynomial order
        if i_order == 1
            Cp = B_i ;
        elseif i_order == 2
            Cp = Cp + B_i .* T;
        elseif i_order == 3
            Cp = Cp + B_i .* T.^2;
        elseif i_order == 4
            Cp = Cp + B_i .* T.^(-2);
        elseif i_order == 5
            Cp = Cp + B_i .* T.^(-3);
        elseif i_order == 6
            Cp = Cp + B_i .* T.^(-0.5);
        elseif i_order == 7
            Cp = Cp + B_i ./ T;
        end
    end
    % for reference, the following is the vectorized version if FracFo is always
    % a scalar:
    % B = B(1,:)*FracFo + B(2,:)*(1-FracFo);
    % Cp = B(1) + B(2).*T + B(3).*T.^2 + B(4).*T.^(-2) + B(5).*T.^(-3) + ...
    %      B(6).*T.^(-0.5) + B(7)./T;

end
