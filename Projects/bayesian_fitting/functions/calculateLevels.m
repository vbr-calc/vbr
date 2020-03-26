function [targ_cutoffs,confs,cutoffs] = calculateLevels(field,targets)

  nC=1000;
  cutoffs=linspace(min(field(:)),max(field(:)),nC);
  confs=zeros(size(cutoffs));
  for ic = 1:nC
    f=field(field>=cutoffs(ic));
    confs(ic)=sum(f(:));
  end

  targ_cutoffs=zeros(size(targets));
  for it = 1:numel(targets)
    targ=targets(it);
    c=cutoffs(confs>=targ);
    targ_cutoffs(it)=max(c(:));
    disp([it,targ,targ_cutoffs(it)])
  end


end
