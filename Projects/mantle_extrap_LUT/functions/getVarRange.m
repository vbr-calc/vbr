function Ranges=getVarRange(VBR,target_val,target_var,freq_target,cutoff,scl)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Ranges=getVarRange(VBR,target_val,target_var,freq_target,cutoff,scl)
  %
  % finds parameter ranges within cutoff percent of target_val. Only a simple
  % gridsearch, does not account for co-varying parameters. 
  %
  % Parameters
  % ----------
  % VBR          the VBR structure
  % target_val
  % target_var
  % freq_target
  % cutoff
  % scl
  %
  % Output
  % ------
  % Ranges       structure with resulting ranges for each method.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  meths=meths=fieldnames(VBR.out.anelastic);
  Nmeths=numel(meths);

  [val,ifreq]=min(abs(VBR.in.SV.f-freq_target));
  SVflds={'T_K';'dg_um';'phi'};
  for imeth=1:Nmeths
    meth=meths{imeth};
    var=squeeze(VBR.out.anelastic.(meth).(target_var)(:,:,:,ifreq))*scl;
    dvar=abs(var-target_val)./target_val*100;

    T=VBR.in.SV.T_K(dvar<=cutoff)-273;
    d=VBR.in.SV.dg_um(dvar<=cutoff);
    phi=VBR.in.SV.phi(dvar<=cutoff);

    for ifl=1:numel(SVflds)
      goodvals=VBR.in.SV.(SVflds{ifl})(dvar<=cutoff)(:);
      fldn=SVflds{ifl};
      if strcmp(fldn,'T_K')
        fldn='T_C';
        offset=-273;
      else
        offset=0;
      end
      Ranges.(meth).(fldn).N=numel(goodvals);
      Ranges.(meth).(fldn).min=min(goodvals+offset);
      Ranges.(meth).(fldn).max=max(goodvals+offset);
      Ranges.(meth).(fldn).std=std(goodvals+offset);
      if Ranges.(meth).(fldn).N > 1
        Ranges.(meth).(fldn).meanval=mean(goodvals+offset);
      end

    end

  end

  fprintf(['Possible Ranges in T,d,phi for ',target_var,' within ',num2str(cutoff),' perc. of ',num2str(target_val),':\n'])
  fprintf('\nmethod,T min [C], T max [C], d min [um], d max [um], phi min, phi max\n')
  SVflds={'T_C';'dg_um';'phi'};
  for imeth=1:Nmeths
    thisline=meths{imeth};
    for ifl=1:numel(SVflds)
      fldn=SVflds{ifl};
      thisline=[thisline,',',num2str(Ranges.(meth).(fldn).min),',',num2str(Ranges.(meth).(fldn).max)];
    end
    thisline=[thisline,'\n'];
    fprintf(thisline)
  end
end
