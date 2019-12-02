function [VBR]=checkInput(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR]=checkInput(VBR)
  %
  % checkInput() looks for some dependency errors. e.g., the xfit_mxw method
  % requires a viscous method to run, all the anelastic calculation require a
  % pure elastic calculation.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % initialize error storage
  VBR.status=1;
  VBR.error_message='';

  % build requirements lists
  % each row = 'structure field containing method','the method','structure field(s) required under VBR.in'
  Reqs={'anelastic','xfit_mxw','viscous','method';
        'anelastic','xfit_mxw','elastic','method';
        'anelastic','eburgers_psp','elastic','method';
        'anelastic','andrade_psp','elastic','method';
        'anelastic','xfit_premelt','elastic','method';
        'anelastic','xfit_premelt','SV.Tsolidus_K','SV'};

  % list of messages to display for each of those requirements
  Msgs={'xfit_mxw requires a viscosity method. e.g., VBR.in.viscous.methods_list={''HZK2011''};';
        'xfit_mxw requires an elasticity method. e.g., VBR.in.elastic.methods_list={''anharmonic''}';
        'eburgers_psp requires an elasticity method. e.g., VBR.in.elastic.methods_list={''anharmonic''}';
        'andrade_psp requires an elasticity method. e.g., VBR.in.elastic.methods_list={''anharmonic''}';
        'xfit_premelt requires an elasticity method. e.g., VBR.in.elastic.methods_list={''anharmonic''}';
        'xfit_premelt requires a solidus state variable e.g., VBR.in.SV.Tsolidus_K=1200*ones(size(T))'};

  Defs={'HZK2011';
        'anharmonic';
        'anharmonic';
        'anharmonic';
        'anharmonic';
        'null'} ;

  % defaults for GlobalSettings
  GlobalDefaults.melt_enhancement=0; % global melt enhacement flag on/off.

  % loop over requirements, check them.
  for ri = 1:size(Reqs,1)
      typ=Reqs{ri,1}; % general method field
      if isfield(VBR.in,typ)
        % check if the method is invoked
        method=Reqs{ri,2};
        methods=VBR.in.(typ).methods_list;
        if any(strcmp(methods,method))
          % check the required fields/methods for this method
          fieldvars=strsplit(Reqs{ri,3},'.');
          missing=0;
          if isfield(VBR.in,fieldvars{1})==0
               missing=1;
          else
            if isfield(VBR.in.(fieldvars{1}),'methods_list')==0 && strcmp(Reqs{ri,4},'method')
               missing=1;
            end
          end

          % if missing, try to apply a default
          if missing==1
            if strcmp(Defs{ri},'null')==0
              VBR.in.(fieldvars{1}).methods_list={Defs{ri}};
              msg=['VBR.in.',typ,'.',method,' does not have a required method set, setting:'];
              msg_2=["\n   VBR.in.",fieldvars{1},'.methods_list={''',Defs{ri},'''}',"\n"];
              msg=strcat(msg,msg_2);
              fprintf(msg)
            else
              VBR.status=0;
            end
          else
            if numel(fieldvars)>1
              if isfield(VBR.in.(fieldvars{1}),fieldvars{2})==0
                VBR.status=0;
              end
            end
          end

          % save the message & exit if error caught
          if VBR.status==0
            msg=Msgs{ri};
            msg=strcat("\n!!! VBR FAILURE !!!\n",msg);
            msg=strcat(msg,"\n!!! VBR FAILURE !!!\n");
            VBR.error_message=msg;
            return;
          end
        end
      end

  end

  % check GlobalSettings
  if ~isfield(VBR.in,'GlobalSettings')
    VBR.in.GlobalSettings=struct();
  end

  allfields=fieldnames(GlobalDefaults);
  for i_field = 1:numel(allfields)
    thisfield=allfields{i_field};
    if ~isfield(VBR.in.GlobalSettings,thisfield)
      VBR.in.GlobalSettings.(thisfield)=GlobalDefaults.(thisfield);
    end
  end

  % some optional state variable fields
  if ~isfield(VBR.in.SV,'Ch2o')
    VBR.in.SV.Ch2o=zeros(size(VBR.in.SV.T_K)); % no effect when at 0
  end
  if ~isfield(VBR.in.SV,'chi')
    VBR.in.SV.chi=ones(size(VBR.in.SV.T_K)); % all olivine when 1
  end

end
