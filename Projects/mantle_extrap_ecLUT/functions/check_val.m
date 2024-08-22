function [index, uho_, poe_] = check_val(VBR)
p = 1;
sz = size(VBR.in.SV.mf, 3);
    for id = 1:sz
    Tcheck=~any( (VBR.in.SV.T_K(:,:,1) - VBR.in.SV.T_K(:,:,id)) <= 1e-3 * min(VBR.in.SV.T_K(:,:,id), [], "all"));
    Ccheck=~any( (VBR.in.SV.Ch2o(:,:,1) - VBR.in.SV.Ch2o(:,:,id)) <= 1e-3 * min(VBR.in.SV.Ch2o(:,:,id), [], "all"));
    E1check=~any( (VBR.out.electric.UHO2014_ol.esig(:,:,1) - VBR.out.electric.UHO2014_ol.esig(:,:,id)) <= ...
        1e-3 * min(VBR.out.electric.UHO2014_ol.esig(:,:,id), [], "all"));
    E2check=~any( (VBR.out.electric.poe2010_ol.esig(:,:,1) - VBR.out.electric.poe2010_ol.esig(:,:,id)) <= ...
        1e-3 * min(VBR.out.electric.poe2010_ol.esig(:,:,id), [], "all"));
    % E2check=~any(VBR.out.electric.poe2010_ol.esig(:,:,1) == VBR.out.electric.poe2010_ol.esig(:,:,id));
    
    uho_ = find(E1check);
    poe_ = find(E1check);
    T_= find(Tcheck);
    C_= find(Ccheck);
    tf = isempty(find(Tcheck)) && isempty(find(Ccheck)) && isempty(find(E1check)) && isempty(find(E2check));
    if tf == 1
        continue
    else
        % num2str
        % check.Tcheck = 
        % check.Ccheck = 
        index(p) = id;
    end
    p = p +1;
    end
end