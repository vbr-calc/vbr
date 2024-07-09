function VBR = ec_vol2part(VBR, method,~) % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_vol2part(VBR, method)
  %
  % Volatile (H2O & CO2) bulk contents to melt partions and residual
  % volatile contents
  % 
  %
  % Parameters:
  % ----------
  % VBR           the VBR structure
  % mehtod      the string name of choice method
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.in.SV.Ch2o_ol
  %                                                  VBR.in.SV.Ch2o_m
  %                                                  VBR.in.SV.Cco2_m
  % 
  %  optional:                                  VBR.in.SV.phi
  %                                                  VBR.in.SV.mf  
  %           
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
      if strcmp(method,'sifre2014')
        % read in parameters
        Ch2o = VBR.in.SV.Ch2o; % ppm, bulk water content
        Cco2 = VBR.in.SV.Cco2; % ppm, bulk water content
        mf = VBR.in.SV.mf; % mass fraction, melt fraction
    
        % Set constants 
        den_p = 3.3; % g/cm^-3, density peridotite
        den_h2o = 1.4; %  g/cm^-3, density of water
        den_carb = 2.4; %  g/cm^-3, density of molten carbonates [Liu and Lange, 2003]
        den_basalt = 2.8; %  g/cm^-3, density of molten basalt [Lange and Carmichael, 1990]
        D_p = 0.007; % unitelss, D_{perid/melt}
        D_o = 0.002; % unitelss, D_{ol/melt}
    
        % Partioning
        Ch2o = Ch2o./1d4; % ppm => wt percent
        Cco2 = Cco2./1d4; % ppm => wt percent
    
        Ch2o_m = Ch2o./(mf+(1-mf)*D_p); % wt percent, Ch2o in melt
        Cco2_m = Cco2./(mf); % wt percent, Cco2 in melt
    
            % Incipient melt correction (Cco2_m > 45 wt percent)
            if ~exist(melt_correct,"var")
                melt_correct = 'off';
            end

            switch melt_correct 
                case 'on'
                    Cco2_m(Cco2_m > 0.0045*1d4) = 0.0045*1d4;
                case 'off'
                 disp("\n Melt wt% corrections for Sifre 2014 volatile partition set to off \n")
                 disp(" Examine C{volatiles}_m in structure VBR.in.SV ")
            end
    
        Ch2o_p = D_p.*Ch2o./(mf+(1-mf)*D_p); % wt percent, Ch2o in peridotite
        Ch2o_ol = Ch2o_p.*(D_o/D_p); % 
    
            % NaN replacement
            Cco2_m(isnan(Cco2_m)) = 0;
            Ch2o_m(isnan(Ch2o_m)) = 0;
        
        Ccarb_m = 2*Cco2_m; % wt percent, carbonate in melt
        den_m = (Ch2o_m/1d2)*(den_h2o) + (Ccarb_m/1d2)*(den_carb) + (1-((Ch2o_m+Ccarb_m)/1d2))*(den_basalt); % g/cm^-3, density of mantle
        
        phi = (1+((1./mf)-1).*(den_m./den_p)).^-1; % volume fraction of melt
    
        if isfield(VBR.in.SV, 'Cco2_m')
          Cco2_m = VBR.in.SV.Cco2_m; % wt percent, Cco2 in melt
        end
    
        if isfield(VBR.in.SV, 'Ch2o_m')
          Ch2o_m = VBR.in.SV.Ch2o_m; % wt percent, Cco2 in melt
        end
    
        % store in VBR structure
        VBR.in.SV.Ch2o_ol = Ch2o_ol;
        VBR.in.SV.phi = phi;
        VBR.in.SV.Ch2o_m = Ch2o_m;
        VBR.in.SV.Cco2_m = Cco2_m;
      end
    
      if strcmp(method, 'standard')
        % read in parameters
        Ch2o = VBR.in.SV.Ch2o; % ppm, bulk water content
        Cco2 = VBR.in.SV.Cco2; % ppm, bulk water content
        phi = VBR.in.SV.phi; %

        % set constants
        den_p = 3.3; % g/cm^-3, density peridotite
        den_h2o = 1.4; %  g/cm^-3, density of water
        den_basalt = 2.8; %  g/cm^-3, density of molten basalt [Lange and Carmichael, 1990]
        D = 0.006; % unitelss, D_{ol/melt} [Ni et al 2011]

        % Partitioning
        Ch2o_m = Ch2o./(D+(1-D).*phi); % ppm, Ch2o in melt
        Cco2_m = Cco2./(phi); % ppm, Cco2 in melt

            % Given 1 million gram of melt (volatiles included)
            vol_m= Ch2o_m./den_h2o + Cco2_m./den_carb + (1d6-(Ch2o_m+Cco2_m))./den_basalt; % cm^3, Volume melt
            vol = vol_m./phi; % cm^3, volume total
            vol_ol = vol - vol_m; % cm^3, volume olivine
            mass_ol = vol_ol.*den_p; % grams, mass of olivine
            Ch2o_ol = Ch2o.*(mass_ol + 1d6) - Ch2o_m; % grams, mass of H2O in olivine
            Ch2o_ol = (Ch2o_ol/mass_ol)*1d6; % ppm, Residal H2O concentration in olivine
            mf = 1d6./mass_ol; % mass fraction of melt
    
        % store in VBR structure
        VBR.in.SV.Ch2o_m = Ch2o_m;
        VBR.in.SV.Cco2_m = Cco2_m;
        VBR.in.SV.Ch2o_ol = Ch2o_ol;
        VBR.in.SV.mf = mf;
    
      end
end