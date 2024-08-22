function fpath = get_data_file_path(model_type, model_file)

    data_dir = get_data_dir();
    fsep = filesep;
    fpath = [data_dir, fsep, model_type, fsep, model_file];

end