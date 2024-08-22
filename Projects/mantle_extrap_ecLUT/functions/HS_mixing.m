function VBR = HS_mixing(VBR)
    % melt models: sifre2014, ni2011, gail2008
    VBR = ec_HS1962(VBR,VBR.out.electric.SEO3_ol.esig,VBR.out.electric.sifre2014_melt.esig);
    VBR.out.electric.sifre2014_melt.esig = VBR.out.electric.HS.esig_up; % VBR.out replacement
    VBR = ec_HS1962(VBR,VBR.out.electric.SEO3_ol.esig,VBR.out.electric.ni2011_melt.esig);
    VBR.out.electric.ni2011_melt.esig = VBR.out.electric.HS.esig_up; % VBR.out replacement
    VBR = ec_HS1962(VBR,VBR.out.electric.SEO3_ol.esig,VBR.out.electric.gail2008_melt.esig);
    VBR.out.electric.gail2008_melt.esig = VBR.out.electric.HS.esig_up; % VBR.out replacement

    % Remove HS fieldnames
    VBR.out.electric = rmfield(VBR.out.electric, {'HS'});
end