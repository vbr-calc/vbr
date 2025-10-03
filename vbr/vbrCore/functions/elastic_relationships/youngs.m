function E = youngs(K, G)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % E = youngs(K, G)
    %
    % Calculates the Young's modulus from Bulk and Shear moduli
    %
    % Parameters
    % ----------
    % K : scalar or array 
    %   bulk modulus, in same units as G
    % G : scalar or array 
    %   shear modulus, in same units as K
    %
    % Returns
    % -------
    % E : scalar or array 
    %   Young's modulus in the same units as the input K and G
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    E = 9*K .* G ./(3*K+G); 
end 