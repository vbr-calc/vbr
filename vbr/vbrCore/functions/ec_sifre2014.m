function VBR = ec_sifre2014(VBR) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_sifre2014( VBR )
  %
  % parameterization of electrical conductivity in peridotite melt from 
  % volatile content in the incipient melt
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.sifre2014_melt structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  % read in electric parameters
  params = VBR.in.electric.sifre2014_melt;
  T = VBR.in.SV.T_K; % K, Temperature
  Ch2o = VBR.in.SV.Ch2o; % ppm, bulk water content
  mf = VBR.in.SV.mf; % v_f, melt fraction

  if ~isfield(VBR.in.SV, 'Cco2') 
      Cco2 = 0; % ppm, Cco2 in melt
  else 
      Cco2 = VBR.in.SV.Cco2; % ppm, Cco2 in melt
  end

        % H2O melt
        a_h2o = params.h2o_a;
        b_h2o = params.h2o_b;
        c_h2o = params.h2o_c;
        d_h2o = params.h2o_d;
        e_h2o = params.h2o_e;

         % C2O melt
        a_c2o = params.c2o_a;
        b_c2o = params.c2o_b;
        c_c2o = params.c2o_c;
        d_c2o = params.c2o_d;
        e_c2o = params.c2o_e;

        % Partition Coefficients
        D_p = params.D_p; % unitelss, D_{perid/melt}
        D_o = params.D_o; % unitelss, D_{ol/melt}

        % Densities
        den_p = params.den_p; % g/cm^-3, density
        den_h2o = params.den_h2o; %  g/cm^-3, density of water
        den_carb = params.den_carb; %  g/cm^-3, density of molten carbonates [Liu and Lange, 2003]
        den_basalt = params.den_basalt; %  g/cm^-3, density of molten basalt [Lange and Carmichael, 1990]

  % Calculations
    % Partioning
    Ch2o = Ch2o./1d4; % ppm => wt_percent
    Cco2 = Cco2./1d4; % ppm => wt_percent

    Ch2o_m = Ch2o./(mf+(1-mf)*D_p); % wt_percent, Ch2o in melt
    Cco2_m = Cco2./(mf); % wt_percent, Cco2 in melt

        % Incipient melt correction (Cco2_m > 45 wt%)
        Cco2_m(Cco2_m > 0.0045*1d4) = 0.0045*1d4; % wt_percent, Cco2 in melt

    Ch2o_p = D_p.*Ch2o./(mf+(1-mf)*D_p); % wt_percent, Ch2o in peridotite
    Ch2o_ol = Ch2o_p.*(D_o/D_p); % 

        % NaN replacement
        Cco2_m(isnan(Cco2_m)) = 0;
        Ch2o_m(isnan(Ch2o_m)) = 0;
    
    Ccarb_m = 2*Cco2_m; % wt_percent, carbonate in melt
    den_m = (Ch2o_m/1d2)*(den_h2o) + (Ccarb_m/1d2)*(den_carb) + (1-((Ch2o_m+Ccarb_m)/1d2))*(den_basalt); % g/cm^-3, density of mantle
    phi = (1+((1./mf)-1).*(den_m./den_p)).^-1; % volume fraction of melt


    % Phi = 0, replace NaN
    phi(isnan(phi)) = 0;

    if isfield(VBR.in.SV, 'Cco2_m')
      Cco2_m = VBR.in.SV.Cco2_m.*1d4; % ppm, Cco2 in melt
    end

    if isfield(VBR.in.SV, 'Ch2o_m')
      Ch2o_m = VBR.in.SV.Ch2o_m.*1d4; % ppm, Cco2 in melt
    end

    % Esig  H2O melt
    H_h2o = a_h2o.*exp(-b_h2o.*Ch2o_m) + c_h2o;
    lS_h2o = d_h2o.*H_h2o + e_h2o;
    S_h2o = exp(lS_h2o);
    melt_h2o = S_h2o.*exp(-H_h2o./(8.314*T)); % arrhenius relation
        
    % Esig CO2 melt
    H_co2 = a_c2o.*exp(-b_c2o.*Cco2_m) + c_c2o;
    lS_co2 = d_c2o.*H_co2 + e_c2o;
    S_co2 = exp(lS_co2);
    melt_co2 = S_co2.*exp(-H_co2./(8.314*T)); % arrhenius relation
        
    % Bulk Melt Esig
    esig = melt_co2 + melt_h2o;

    % Residual H2O
    Ch2o_ol = Ch2o_ol*1d4; % wt_percent => ppm, Residual h2o in olivine

% Store in the VBR structure

sifre2014_melt.esig = esig; % S/m
sifre2014_melt.Ch2o_ol = Ch2o_ol; % ppm
sifre2014_melt.phi = phi; % v_f
VBR.out.electric.sifre2014_melt = sifre2014_melt;

end

