%% 
clear all; close all; clc;

%% 

prefix = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies';
prefix = 'D:\sydne\Documents\snow_flies'
prefix_alt = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies'
sessions = {'12.29.20', '12.28.20', '1.1.21', '1.2.21', '1.3.21', '1.11.21', '1.15.21',...
            '1.16.21', '2.1.21', '2.5.21', '2.10.21', '3.1.21', '3.9.21', '3.18.21'};
order = 60; % for median filter
        
for i=1:length(sessions)
    session = sessions{i};
    prefix2 = fullfile(prefix, session);
    files2 = dir(prefix2);
    flies = files2([files2.isdir]);
    
    for j=3:numel(flies)     
        prefix3 = fullfile(prefix2, flies(j).name);
        files3 = dir(prefix3);
        trials = files3([files3.isdir]);
        
        for k=3:numel(trials)            
            
            prefix4 = fullfile(prefix3, trials(k).name);
            videos = dir(fullfile(prefix4, '*.csq'));
            video = videos(end).name;

            path = fullfile(prefix4, video)
            mask_path = fullfile(prefix4, 'roi.png');
            corr_path = fullfile(prefix4, 'temp_data_corrections_visible.csv');
            outfile = fullfile(prefix_alt, session, flies(j).name, trials(k).name, 'sf_region_temps.mat');       

            if ~isfile(corr_path) || isfile(outfile)
                continue
            end 
            
            % get mask
            if isfile(mask_path) 
                mask = imbinarize(imread(mask_path));
            end 
            
            % read data
            corr_data = readtable(corr_path);

            % background subtraction
            v = FlirMovieReader(path);
            v.unit = 'temperatureFactory';
            [I_0, metadata] = step(v); % initial image
            t = 1; % frame
            s = 80;
            sd2 = floor(s/2);

            x_filtered = medfilt1(corr_data.x_new, order);
            y_filtered = medfilt1(corr_data.y_new, order);
            regions = {};

            disp('processing...');
            % figure;
            while ~isDone(v)

                I_t = step(v);
                row = y_filtered(t);
                col = x_filtered(t);

                dim = size(I_t);
                x1 = max(1, col-sd2);
                y1 = max(1, row-sd2);
                x2 = min(col + sd2 - 1 , dim(2));
                y2 = min(row + sd2 - 1, dim(1));

                im_masked = I_t;
                im_masked(~mask(:,:,1)) = NaN;
                regions{t} = im_masked(y1:y2, x1:x2);
                %imagesc(im_masked(y1:y2, x1:x2));
                %drawnow; 

                t = t + 1;
            end 

            disp('saving...');
            save(outfile, 'regions');
            display(outfile)            
           
        end
       
    end
    
end 