function VBR = ec_sifre2014(VBR) %(T, Ch2o_m, Cco2_m)
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
  ele = VBR.in.electric.sifre2014_melt;
  T = VBR.in.SV.T_K; % K (Temmperature)
  Ch2o = VBR.in.SV.Ch2o; % ppm (water content)
  phi = VBR.in.SV.phi; % v_f (melt fraction)
  D = ele.D; % unitless
  Cco2_m = 0; % wt_f

        % H2O melt
        a_h2o = ele.h2o_a;
        b_h2o = ele.h2o_b;
        c_h2o = ele.h2o_c;
        d_h2o = ele.h2o_d;
        e_h2o = ele.h2o_e;

         % C2O melt
        a_c2o = ele.c2o_a;
        b_c2o = ele.c2o_b;
        c_c2o = ele.c2o_c;
        d_c2o = ele.c2o_d;
        e_c2o = ele.c2o_e;

  % Calculations
  Ch2o_m = Ch2o./(D+(1-D).*phi); % partition of water
  Ch2o_m = Ch2o_m./1d4; % ppm to wt_f

  % H2O
        H_h2o = a_h2o.*exp(-b_h2o.*Ch2o_m) + c_h2o;
        lS_h2o = d_h2o.*H_h2o + e_h2o;
        S_h2o = exp(lS_h2o);
        melt_h2o = arr(T, S_h2o, H_h2o);
        
   %CO2 melt
        H_co2 = a_c2o.*exp(-b_c2o.*Cco2_m) + c_c2o;
        lS_co2 = d_c2o.*H_co2 + e_c2o;
        S_co2 = exp(lS_co2);
        melt_co2 = arr(T, S_co2, H_co2);
        
        % Bulk Melt Esig
        esig = melt_co2 + melt_h2o;
        
        % Store in the VBR structure
        sifre2014_melt.esig = esig;
        VBR.out.electric.sifre2014_melt = sifre2014_melt;
end

    function sig  = arr(T, S, H)
        R = 8.314; % J/(mol*K)
        exponent = -H./(R.*T);
        sig = S.*exp(exponent);
    end
