%% 
close all; clear all; clc;

%%
prefix = 'C:\Users\sydne\Documents\thermal_experiments\data\';
prefix  = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies';

%% save a folder of frames from each video 

files = dir(prefix);
dates = files([files.isdir]);

% for i=3:numel(dates)
%     date = dates(i).name;
date = '1.15.21';
prefix2 = fullfile(prefix, date);
files2 = dir(prefix2);
flies = files2([files2.isdir]);
for j=3:numel(flies)     
    prefix3 = fullfile(prefix2, flies(j).name);
    files3 = dir(prefix3);
    trials = files3([files3.isdir]);

    for k=3:numel(trials)            

        prefix4 = fullfile(prefix3, trials(k).name);
        videos = dir(fullfile(prefix4, '*.csq'));
        if length(videos) < 1
            continue
        end 

        mask_path = fullfile(prefix4, 'roi.png');
        if ~isfile(mask_path) 
            continue
        end

        mask = imbinarize(imread(mask_path));
        vidname = videos(length(videos)).name;
        [~, vid, ext] = fileparts(vidname);
        path = fullfile(prefix4, vidname);
        outpath = fullfile(prefix4, 'snapshots')

        numel(dir(outpath))
        if numel(dir(outpath)) > 4
            continue
        else 
            mkdir(outpath);
        end

        outpath

        t = 0;
        ix = 0;
        v = FlirMovieReader(path);
        v.unit = 'temperatureFactory';

        while ~isDone(v)

            [im, metadata] = step(v);

            if mod(t, 60) == 0
                im_norm = mat2gray(im);
                im_norm_masked = im_norm.*mask;
                im_name = append('img', num2str(ix, '%05.f'), '.png');
                im_out = fullfile(outpath, im_name);
                imwrite(im_norm_masked, im_out);
                ix = ix + 1;
            end 
            t = t + 1;
        end            
    end
end
% end    