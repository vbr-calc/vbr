function WithGhosts = addghosts(NoGhosts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  WithGhosts = addghosts(NoGhosts)
%
% appends ghosts nodes to a vertical array(:,1). Values filled assuming
% zero neumann condition, overwrite this with BCs outside.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 WithGhosts = [NoGhosts(1); NoGhosts; NoGhosts(end)];
end
