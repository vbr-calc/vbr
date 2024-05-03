function VBR = ec_HS1962(VBR) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_HS1962( VBR )
  %
  % Hashin_Shtrikman Lower and upper bound 
  % geophysical mixing model for electrical conductivity of 2 phases
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.HSup.esig{index,1}
  %            & VBR structure, with VBR.out.electric.HSlo.esig{index,1}
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  non = find(strcmp({'HS1962'}, VBR.in.electric.methods_list)); % check for HS1962 in method_list and store its index
  VBR.in.electric.methods_list(non) = []; % delete HS1962 from method list to run all other methods as phases

  if isfield(VBR.out, 'electric') && length(fieldnames(VBR.out.electric))>2
      % read in electric parameters
      phi = VBR.in.SV.phi; % v_f (melt fraction)
      meths = VBR.in.electric.methods_list;
      n_meths = numel(meths);

      for i_meth = 1:n_meths
        meth = meths{i_meth}; % the current method
        esig_1 = VBR.out.electric.(meth).esig; % current method esig becomes phase
        alt = find(i_meth~=1:n_meths); % indexes of alternative(s); other methods\

        for index = alt
            esig_2 = VBR.out.electric.(meths{index}).esig; % all other methods iterate as esig phase 2
            esig_HSup = HS1962_up(esig_1, esig_2, phi); % S/m, HS upper 
            esig_HSlo = HS1962_lo(esig_1, esig_2, phi); % S/m, HS lower
            
            meth_str = [meth, '__',meths{index}]; % method combo
            HSup.esig.(meth_str) = esig_HSup;
            HSlo.esig.(meth_str) = esig_HSlo;
            cell.(meth_str) = {};
            
        end
      end

      % Store in the VBR structure
      m = fieldnames(cell); 
      cell_up = struct2cell(HSup.esig); % cell storage HSup for reassignement 
      cell_lo = struct2cell(HSlo.esig); % cell storage HSlo for reassignement
      VBR.out.electric.HSup.esig = cell_up;
      VBR.out.electric.HSlo.esig = cell_lo;
      VBR.out.electric.HS.methods = m;
      
   else
      disp('')
      disp('WARNING!!!!!')
      disp('Two outputs in struct VBR.out.elctric required for HS1962 method')
      disp(' run vbrListMethods() for valid list')
      disp('')
 end

end

    function esig = HS1962_up(esig_1, esig_2,phi) % Hashin-Strickman Upper
    num = 3.*(1-phi).*(esig_2-esig_1); % numerator
    den = 3.*esig_2-phi.*(esig_2-esig_1); % denominator
    esig = esig_2.*(1-(num./den));
    end

    function esig = HS1962_lo(esig_1, esig_2,phi) % case specific
    num = 3.*(phi).*(esig_2-esig_1); % numerator
    den = 3.*esig_1+(1-phi).*(esig_2-esig_1); % denominator
    esig = esig_1.*(1+(num./den));
    end