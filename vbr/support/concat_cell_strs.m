function outstr = concat_cell_strs(input_cell, join_str)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% outstr = concat_cell_strs(input_cell)
%
% convert a cell array of strings to a single string
%
% Parameters
% ----------
% input_cell
%    a cell array of strings to concatenate
% join_str 
%    the string to use to join the cell array elements. Set to a blank 
%    string, '', to simply concatenate.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    outstr = '';
    active_join_str = '';
    for icell = 1:numel(input_cell)        
        outstr = [outstr, join_str, input_cell{icell}];
        if icell > 1
            active_join_str = join_str;
        end            
    end 
end 