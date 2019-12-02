%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                       init_BCs                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simple dirichlet or neumann BCs                                    %
%                                                                    %
% [BCs]=init_BCs(variable,boundary,b_type,value)                     %
%                                                                    %
% Input:                                                             %
%   BC              boundary condition structure to add to           %
%   variable        a string with the name of the variable           %
%   boundary        a string, either 'zmin' or 'zmax'                %
%   b_type          a string,  'dirichlet' or 'neumann'              %
%   value           a scalar, the value of the boundary condition    %
%                                                                    %
% Output:                                                            %
%   BCs.type_i(1:2) sets the BC type for the top (1) and bottom (2), %
%                   where the type can be:                           %
%                     1 dirichlet with specified value               %
%                     2 neumann with specified value                 %
%   BCs.val_i(1:2)  sets the BC value for the top (1) and bottom (2).%
%                                                                    % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [BCs]=init_BCs(BCs,variable,boundary,b_type,value)

%%%%%%%%%%%%%%%%%%%%%%     
%   temperature      
%%%%%%%%%%%%%%%%%%%%%%

     val_name=['val_' variable];
     type_name=['type_' variable];     
     bid = strcmp(boundary,'zmin') + strcmp(boundary,'zmax')*2;
     BCs.(val_name)(bid) = value; 
     
     type_id = strcmp(b_type,'dirichlet') + strcmp(b_type,'neumann')*2; 
     BCs.(type_name)(bid) = type_id; 
 
       
end
