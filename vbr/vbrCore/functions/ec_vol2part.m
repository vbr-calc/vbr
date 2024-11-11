function VBR = ec_vol2part(VBR, method, varargin) % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  WARNING!!! THIS FUNCTION PRODUCES CHANGES TO THE 
%       VBR.in.SV structure
%
% [ VBR ] = ec_vol2part(VBR, method)
%
% Volatile (H2O & CO2) bulk contents to melt partions and residual
%   volatile content in phases
%
% Parameters:
% ----------
%
% VBR           the VBR structure
% method      the string name of choice method
% varargin      optional corrections for incipient melt and melt induction
%
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
    % read in State Variables (SVs)
    Ch2o = VBR.in.SV.Ch2o; % ppm, bulk water content
    mf = VBR.in.SV.mf; % mass fraction, melt 
    if isfield(VBR.in.SV, 'Cco2')
        Cco2 = VBR.in.SV.Cco2; % ppm, bulk water content
    else
        Cco2 = 0; % ppm, bulk water content
    end
    
    % Set constants 
    den_p = 3.3; % g/cm^-3, density peridotite
    den_h2o = 1.4; %  g/cm^-3, density of water
    den_carb = 2.4; %  g/cm^-3, density of molten carbonates [Liu and Lange, 2003]
    den_basalt = 2.8; %  g/cm^-3, density of molten basalt [Lange and Carmichael, 1990]
    D_p = 0.007; % unitelss, D_{perid/melt}
    D_o = 0.002; % unitelss, D_{ol/melt}
    
    % Correction
    Ch2o = Ch2o./1d4; % weight percent, water content bulk
    Cco2 = Cco2./1d4; % weight percent, CO2 content bulk
    
    % Partioning
    Ch2o_m = Ch2o./(mf+(1-mf)*D_p); % weight percent, water content melt
    Cco2_m = Cco2./(mf); % weight percent, Cco2 in melt
     
        % Incipient melt correction (Volatile Saturation)
        if numel(varargin) >= 1
            correction = varargin{1};
            
            switch correction 
                case 'vol'
                    Cco2_m(Cco2_m > 0.0045*1d4) = 0.0045*1d4;
                    Ch2o_m(Ch2o_m > 0.0020*1d4) = 0.0020*1d4;
                    disp(" ")
                    disp(" ec_vol2part ")
                    disp(" ' Melt volatile content capped at saturation level!! ' ")
                    disp(" ' VBR.in.SV.Ch2o_m =< 450000 ppm ' ")
                    disp(" ' VBR.in.SV.Ch2o_m =< 200000 ppm ' ")
                    disp(" ")
                case 'melt'
                    disp(" ")
                    disp(" ec_vol2part ")
                    disp(" ' Melt volatile content NOT capped at saturation level!!! ' ")
                    disp(" ' VBR.in.SV.Ch2o_m > 450000 ppm permitted ' ")
                    disp(" ' VBR.in.SV.Ch2o_m > 200000 ppm permitted ' ")
                    disp(" ")
            end
        end
    
    Ch2o_p = D_p.*Ch2o./(mf+(1-mf)*D_p); % weight percent, water content peridotite
    Ch2o_ol = Ch2o_p.*(D_o/D_p); % weight percent, residual water content olivine
    
    Ccarb_m = 2*Cco2_m; % weight percent, carbonate melt
    den_m = (Ch2o_m/1d2)*(den_h2o) + (Ccarb_m/1d2)*(den_carb) + (1-((Ch2o_m+Ccarb_m)/1d2))*(den_basalt); % g/cm^-3, density of mantle
    
    phi = (1+((1./mf)-1).*(den_m./den_p)).^-1; % volume fraction, melt
    phi(isnan(den_m)) = 0;

        % Incipient melt correction (Volatile Induced Melting)
        if numel(varargin) >= 1
            melt_correct = varargin{1};

            switch melt_correct 
                case 'melt'
    
                    low_melt = find(phi < 0); % Melt fractions below minimum incipient melt levels
    
                    if ~isempty(low_melt)
                        s = min(phi(phi > 0), [],"all");
                        disp(" ' Increased incipient melt due to excessive volatile content ' ")
                        fprintf(' phi >= %d ONLY!!! \n', s);
                        phi(phi < 0) = s;
                    end
    
                case 'vol'
                    disp(" ")
                    disp(" ' Increased incipient melt due to excessive volatile content not considered ' ")
                    disp(" ' Melt volume fractions (phi) may be to less than viable given decreased melt density ' ")
                    disp(" ")
            end
        end
    
    % Correction
    Ch2o_m = Ch2o_m*1d4; % ppm, water content melt
    Cco2_m = Cco2_m*1d4; % ppm, CO2 content melt
    Ch2o_ol = Ch2o_ol*1d4; % ppm, water content olivine
    
    % store in VBR structure
    VBR.in.SV.Ch2o_m = Ch2o_m; % ppm, water content melt
    VBR.in.SV.Cco2_m = Cco2_m; % ppm, CO2 content melt
    VBR.in.SV.Ch2o_ol = Ch2o_ol; % ppm, residual water content olivine
    VBR.in.SV.phi = phi; % volume fraction, melt
    end
    
    if strcmp(method, 'standard')
    % read in State Variables (SVs)
    Ch2o = VBR.in.SV.Ch2o; % ppm, bulk water content
    phi = VBR.in.SV.phi; % volume fraction, melt
     if isfield(VBR.in.SV, 'Cco2')
        Cco2 = VBR.in.SV.Cco2; % ppm, bulk water content
    else
        Cco2 = 0; % ppm, bulk water content
     end
    
    % set constants
    den_p = 3.3; % g/cm^-3, density peridotite
    den_basalt = 2.8; %  g/cm^-3, density of molten basalt [Lange and Carmichael, 1990]
    D = 0.006; % unitelss, D_{ol/melt} [Ni et al 2011]

    % Partitioning
    Ch2o_m = Ch2o./(D+(1-D).*phi); % ppm, Ch2o in melt
    Cco2_m = Cco2./(phi); % ppm, Cco2 in melt

    % Mass Fraction Calculation (assuming dry basalt density)
    mf = ((1-phi)/phi.*(den_p/den_basalt)+1)^-1; % mass fraction, melt

    % Correction
    mf(isnan(mf)) = 0;
    
    % store in VBR structure
    VBR.in.SV.Ch2o_m = Ch2o_m; % ppm, water content melt
    VBR.in.SV.Cco2_m = Cco2_m; % ppm, CO2 content melt
    VBR.in.SV.mf = mf; % mass fraction, melt
    
    end
end