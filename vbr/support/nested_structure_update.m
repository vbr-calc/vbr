function output_struct = nested_structure_update(struct_1, struct_2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  output_struct = nested_structure_update(struct_1, struct_2)
%
%  update struct_1 with fields from struct_2. Unique fields from both
%  structures are preserved. For fields that are shared, the fields from
%  struct_2 are copied over unless the field is a structure, in which case
%  it triggers a recursive structure comparison for that field.
%
%  Parameters
%  ----------
%  struct_1
%    the structure to update
%  struct_2
%    the structure to copy in fields from
%
%  Returns
%  -------
%
%  struct
%    a new structure with fields from struct_1 and struct_2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    output_struct = struct();
    struct_1_fields = fieldnames(struct_1);
    struct_2_fields = fieldnames(struct_2);

    [shared_fields_12, unique_fields_12] = get_shared_unique_fields(struct_1, struct_2);
    [shared_fields_21, unique_fields_21] = get_shared_unique_fields(struct_2, struct_1);
    % disp(shared_fields_12)
    % disp(shared_fields_21)
    % disp(unique_fields_12)
    % disp(unique_fields_21)

    % first handle the unique fields
    for ifield = 1:numel(unique_fields_12)
        current_field = unique_fields_12{ifield};
        output_struct.(current_field) = struct_1.(current_field);
    end
    for ifield = 1:numel(unique_fields_21)
        current_field = unique_fields_21{ifield};
        output_struct.(current_field) = struct_2.(current_field);
    end

    % now collide the shared fields, defaulting to whatever is in struct 2 unless it is
    % itself a structure (in which case we recursively check those structures)
    for ifield = 1:numel(shared_fields_12)
        current_field = shared_fields_12{ifield};
        if isstruct(struct_1.(current_field))
            nested1 = struct_1.(current_field);
            nested2 = struct_2.(current_field);
            output_struct.(current_field) = nested_structure_update(nested1, nested2);
        else
            output_struct.(current_field) = struct_2.(current_field);
        end
    end
end

function [shared_fields, unique_fields] = get_shared_unique_fields(struct_1, struct_2)
    struct_1_fields = fieldnames(struct_1);

    shared_fields = {};
    n_shared = 0;

    unique_fields = {};
    n_unique = 0;

    for ifield = 1:numel(struct_1_fields)
        current_field = struct_1_fields{ifield};
        if isfield(struct_2, current_field)
            n_shared = n_shared + 1;
            shared_fields(n_shared) = current_field;
        else
            n_unique = n_unique + 1;
            unique_fields(n_unique) = current_field;
        end
    end
end
