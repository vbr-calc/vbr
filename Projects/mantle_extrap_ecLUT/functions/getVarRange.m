function PossibleRanges=getVarRange(VBR,target_val,target_var,cutoff)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Ranges=getVarRange(VBR,target_val,target_var,cutoff)
  %
  % finds parameter ranges within cutoff percent of target_val. Only a simple
  % gridsearch, does not account for co-varying parameters. 
  %
  % Parameters
  % ----------
  % VBR          the VBR structure
  % target_val
  % target_var
  % cutoff
  %
  % Output
  % ------
  % Ranges       structure with resulting ranges for each method.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  meths=fieldnames(VBR.out.electric);
  Nmeths=numel(meths);

SVflds={'T_K';'Ch2o';'mf'};
  for imeth=1:Nmeths
    meth=meths{imeth};
    var=squeeze(VBR.out.electric.(meth).(target_var));
    dvar=abs(var-target_val)./target_val*100;
    ind=dvar<=cutoff;
    Tkeep=VBR.in.SV.T_K(ind);
    Ckeep=VBR.in.SV.Ch2o(ind);
    Mkeep=VBR.in.SV.mf(ind);
    goodvals=[Tkeep Ckeep Mkeep];

    % dvar = dvar(:,:,1);

    for ifl=1:numel(SVflds)
      fldn=SVflds{ifl};
      if strcmp(fldn,'T_K')
        fldn='T_C';
        offset=-273;
      else
        offset=0;
      end
      PossibleRanges.(meth).(fldn).N=numel(goodvals(:,ifl));
      PossibleRanges.(meth).(fldn).min=min(goodvals(:,ifl)+offset);
      PossibleRanges.(meth).(fldn).max=max(goodvals(:,ifl)+offset);
      PossibleRanges.(meth).(fldn).std=std(goodvals(:,ifl)+offset);
      PossibleRanges.(meth).(fldn).goodvals=goodvals;
      PossibleRanges.(meth).dvar=dvar;

      if PossibleRanges.(meth).(fldn).N > 1
        PossibleRanges.(meth).(fldn).meanval=mean(goodvals+offset);
      end

    end

  end

  fprintf(['Possible Ranges in T, Ch2o, mf for ',target_var,' within ',num2str(cutoff),' perc. of ',num2str(target_val),' S/m :\n'])
  fprintf('\n method -- T min [C], T max [C] -- Ch2o min [ppm], Ch2o max [ppm]  -- mf min, mf max \n')
  SVflds={'T_C';'Ch2o';'mf'};
  for imeth=1:Nmeths
    meth=meths{imeth};
    thisline=meths{imeth};
    for ifl=1:numel(SVflds)
      fldn=SVflds{ifl};
      thisline=[thisline,' -- ',num2str(PossibleRanges.(meth).(fldn).min),', ',num2str(PossibleRanges.(meth).(fldn).max),' '];
    end
    thisline=[thisline,'\n'];
    fprintf(thisline)
  end
end
