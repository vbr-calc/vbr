function FitData_YT24(use_data)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FitData_YT24()
    %
    % Plots viscosity, modulus, Qinv for borneol near and above the solidus
    % temperature following premelting scaling of Yamauchi and Takei, 2024, JGR.
    %
    % Parameters
    % ----------
    % use_data
    %   if 1, will attempt to fetch data from zenondo
    %
    % Output
    % ------
    % figures to screen and to Projects/1_LabData/1_Attenuation/figures/
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % put VBR in the path
    vbr_path = getenv('vbrdir');
    if isempty(vbr_path)
        vbr_path='../../../';
    end
    addpath(vbr_path)
    vbr_init

    % check on data
    full_data_dir = 0;
    if use_data == 1
        full_data_dir = download_YT24('data');
    end


    plot_fig2(full_data_dir)





end


function plot_fig2(full_data_dir)

    f1 = figure();
    f2 = figure();
    if full_data_dir ~= 0

        samp_nums = [41, 42, 50 ]
        for isamp = 1:numel(samp_nums)
            samp_num = samp_nums(isamp);
            disp(isamp)
            current_run = load_sample_data(samp_num, full_data_dir);

            T_arr = [];
            for iT = 1:numel(current_run)  % temperature loop
                T_arr =[T_arr, current_run(iT).T];
            end
            min_T  = min(T_arr);
            max_T  = max(T_arr);
            dT = max_T - min_T;
            for iT = 1:numel(current_run)  % temperature loop
                T = current_run(iT).T;
                r = (T - min_T) / dT;
                b = 1 - r;
                rgb = [r, 0.0, b];

                cdata = current_run(iT).data;
                f = cdata(:,1);
                f_normed = cdata(:,2);
                E = cdata(:,3);
                E_normed = cdata(:,4);
                Qinv =  cdata(:,5);

                set(0, 'currentfigure', f1);
                subplot(2, 3, 1+(isamp-1))
                hold all
                semilogx(f, E, '.', 'color', rgb)
                ylim([0.25, 2.75])

                subplot(2, 3, 3+isamp)
                hold all
                loglog(f, Qinv,'.', 'color', rgb)
                ylim([1e-3, 2])

                set(0, 'currentfigure', f2);
                subplot(2, 3, 1+(isamp-1))
                hold all
                semilogx(f_normed, E_normed, '.', 'color', rgb)
                

                subplot(2, 3, 3+isamp)
                hold all
                loglog(f_normed, Qinv,'.', 'color', rgb)

            end
        end

    end

end

function run_data = load_sample_data(sample_number, full_data_dir)

    sample_str = num2str(sample_number);
    sample_file = fullfile(full_data_dir, ['anela',sample_str,'.mat']);
    struct_name = ['anela',sample_str];
    sample_data = load(sample_file); % e.g., sample_data.anela42
    data = getfield(sample_data, struct_name); % e.g., anela42
    run_data = data.run;

end



function unzipped_data_dir = download_YT24(datadir)
    % downloads, unzips data from zenodo

    unzipped_data_dir = fullfile(datadir,'YT24');
    if exist(datadir) ~= 7
        mkdir(datadir)
        mkdir(unzipped_data_dir)
    end

    YT24data_url = 'https://zenodo.org/api/records/10201689/files-archive';
    zipfilename = '10201689.zip';

    local_data = fullfile(unzipped_data_dir, zipfilename);
    if exist(local_data) ~= 2
        urlwrite(YT24data_url, zipfilename)
        movefile(zipfilename, unzipped_data_dir)
        unzip(local_data, unzipped_data_dir)
    end
end