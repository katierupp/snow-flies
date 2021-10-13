close all; clear all; clc;

%% 
data_prefix = 'C:\Users\sydne\Downloads';
file = 'cold_tolerance_summary - snow flies.csv';
data_path = fullfile(data_prefix, file);
data = readtable(data_path, 'PreserveVariableNames', true, 'format', 'auto');

%%
prefix = 'C:\Users\sydne\Documents\thermal_experiments\data\';
prefix  = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies';

%% create short videos of the supercooling point for each snowfly

files = dir(prefix);
dates = files([files.isdir]);

paths_all = [];
amax_all = [];
amin_all = [];

for i=3:numel(dates)
    date = dates(i).name;
    prefix2 = fullfile(prefix, date);
    files2 = dir(prefix2);
    flies = files2([files2.isdir]);
    
    for j=3:numel(flies)     
        prefix3 = fullfile(prefix2, flies(j).name);
        files3 = dir(prefix3);
        trials = files3([files3.isdir]);
        
        for k=3:numel(trials)            
            
            prefix4 = fullfile(prefix3, trials(k).name)
            mask_path = fullfile(prefix4, 'roi.png');
            if isfile(mask_path) 
                mask = imbinarize(imread(mask_path));
            end 
            
            videos = dir(fullfile(prefix4, '*.csq'));
            if length(videos) < 1
                continue
            end 
            vidname = videos(length(videos)).name;
            [~, vid, ext] = fileparts(vidname);
            path = fullfile(prefix4, vidname);
            outpath = fullfile(prefix4, append(vid, '_scp', '.avi'))

            match = {vidname}
            row_data = data(strcmp(data.video, match), :);

            if length(row_data.scp_frame) == 0 || length(row_data.scp_frame{1}) == 0
                continue
            end 
            
            if isfile(outpath)
                continue
            end

            t = 1;
            ix = 1;
            scp_frame = str2num(row_data.scp_frame{1});
            t_start = scp_frame - 500
            t_end = scp_frame + 500
            nframes = t_end - t_start;
            max_temps = zeros(1, nframes);
            min_temps = zeros(1, nframes);

            v = FlirMovieReader(path);
            v.unit = 'temperatureFactory';

            while (t < t_end) % || ~isDone(v)

                [im, metadata] = step(v);

                if (t >= t_start) && (t < t_end)
                    im_norm = mat2gray(im);
                    % im_norm_masked = im_norm.*mask;
                    max_temps(ix) = max(im(:));
                    min_temps(ix) = min(im(:));
                    ix = ix + 1;
                end 
                t = t + 1;
            end 

            t = 1;
            amax = max(max_temps);
            amin = min(min_temps);
            v = FlirMovieReader(path);
            v.unit = 'temperatureFactory';

            v_new = VideoWriter(outpath, 'Uncompressed AVI');
            open(v_new);

            while (t < t_end) % || ~isDone(v)

                [im, metadata] = step(v);

                if (t >= t_start) && (t < t_end)
                    im_norm = mat2gray(im, [amin, amax]);
                    % im_norm_masked = im_norm.*mask;
                    writeVideo(v_new, im_norm);
                end 
                t = t + 1;
            end 
            close(v_new); 
            
            paths_all = [paths_all path];
            amax_all = [amax_all amax];
            amin_all = [amin_all amin];
        end
    end
end    


%% save min and max temps to csv

out_prefix = 'C:\Users\sydne\Documents\thermal_experiments\data\summaries';
out_fname = fullfile(out_prefix, 'scp_min_max_temps.csv');
temp_data = [paths_all; amax_all; amin_all]; 
temp_data_table = array2table(transpose(temp_data));
temp_data_table.Properties.VariableNames(1:9) = {'filename', 'max_temp', 'min_temp'};
writetable(temp_data_table, out_fname);
