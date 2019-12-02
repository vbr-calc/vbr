function Var=BC_setghosts(Var,BCvals,BCtype,dz)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Var=BC_setghosts(Var,BCvals,BCtype,dz)
  %
  % sets ghost cells of Var to enforce BCs.
  %
  % Parameters
  % ----------
  %   Var     array with Var(1) and Var(end) being ghost cells
  %   BCvals  2-element array with the values to set for first and last cell
  %   BCtype  2-element array with BC type indicator for first and last cell
  %           BCtype = 1 for dirichlet, 2 for neumann, 3 for a continuous flux condition
  %   dz      mesh spacing
  %
  % Output
  % ------
  %   Var     the variable with updated ghost cells
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % bottom condition at z=zmax
  if BCtype(2)==1 % dirichlet
   Var(end) = 2*BCvals(2) - Var(end-1);
  elseif BCtype(2)==2 % neumann
   Var(end) = BCvals(2)*dz + Var(end-1);
  elseif BCtype(2)==3 % continuous flux
   dVdz = (Var(end-1) - Var(end-2) ) / dz;
   Var(end) = Var(end-1) + dVdz * dz;
  end

  % top condition at z = 0
  if BCtype(1)==1 % dirichlet
   Var(1) = 2*BCvals(1) - Var(2);
  elseif BCtype(1)==2 % neumann
   Var(1) = Var(2) - BCvals(1)*dz ;
  elseif BCtype(1)==3 % continuous flux
   dVdz = (Var(3) - Var(2) ) / dz;
   Var(1) = Var(2) - dVdz * dz;
  end

end
