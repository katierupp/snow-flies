%% 
clear all; close all; clc;

%% 

prefix = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies';
sessions = {'12.29.20', '12.28.20', '1.1.21', '1.2.21', '1.3.21', '1.11.21', '1.15.21',...
            '1.16.21', '2.1.21', '2.5.21', '2.10.21', '3.1.21', '3.9.21', '3.18.21'};
        
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
            
            prefix4 = fullfile(prefix3, trials(k).name)
            
            if ~isfile(fullfile(prefix4, 'temp_data_corrections.csv'))
                continue
            end 
            
            if isfile(fullfile(prefix4, 'temp_data_final.csv'))
                continue
            end 

            corr_path = fullfile(prefix4, 'temp_data_corrections.csv')
            corr_data = readtable(corr_path);
            
            videos = dir(fullfile(prefix4, '*.csq'));
            video = videos(end).name
            % track_snow_fly(prefix4, video);
            
            path = fullfile(prefix4, video);
            outpath = fullfile(prefix4, 'temp_data_final.csv');

            % get mask
            mask_path = fullfile(prefix4, 'roi.png');
            if isfile(mask_path) 
                mask = imbinarize(imread(mask_path));
            else 
                continue
            end 

            % background subtraction
            v = FlirMovieReader(path);
            v.unit = 'temperatureFactory';
            [I_0, metadata] = step(v);

            I_0 = I_0; % initial image
            I_bar = mean(I_0(:));
            B_0 = I_0; % background
            J_0 = I_0 - I_bar - B_0; % background subtracted image

            alpha = 0.99; % 0 <= alpha <= 1;
            t = 1; % frame

            s = 70;
            sd2 = floor(s/2);
            px_thresh = 0.7;

            xpos = [];
            ypos = [];
            true_max = [];
            max_temps = [];
            avg_temps = [];
            cold_plate_temp = [];
            intensity = [];
            movement = [];

            disp('processing...');
            figure;
            while ~isDone(v)

                I_t = step(v); % next frame
                I_bar = mean(I_t(:));
                B_t = B_0 * alpha + (1 - alpha)*(I_t - I_bar); % update background image
                J_t = I_t - I_bar - B_t; % background subtracted image

                % J_t(J_t < 0) = 0;
                J_t = abs(J_t);
                J_t = J_t.*mask; % apply mask
                
                % determine location of max pixel value
                [max_val,idx] = max(J_t(:));
                row = corr_data.y_new(t);
                col = corr_data.x_new(t);

                % extract max temperature
                xpos = [xpos col];
                ypos = [ypos row];
                max_temp =  I_t(row, col);
                max_temps = [max_temps max_temp];
                J_tn = J_t / max_val; % normalize image

                dim = size(J_t);
                x1 = max(1, col-sd2);
                y1 = max(1, row-sd2);
                x2 = min(col + sd2 - 1 , dim(2));
                y2 = min(row + sd2 - 1, dim(1));
                fly_roi = zeros(s);
                region = J_tn(y1:y2, x1:x2);
                region_norm = region / max(region(:));

                % quantify pixel intensity 
                sf_region = region(region > px_thresh);
                px_intensity = sum(sf_region) / length(sf_region);
                intensity = [intensity, px_intensity];
                movement = [movement length(sf_region)];

                % compute average cold plate temperature
                cold_plate = I_t.*mask;
                cold_plate(y1:y2, x1:x2) = 0; 
                cp_temp = sum(cold_plate(:)) / nnz(cold_plate);
                cold_plate_temp = [cold_plate_temp cp_temp];

                bin_region = imbinarize(region_norm);
                if length(bin_region(bin_region == 1)) > length(bin_region(bin_region == 0))
                    bin_region = imcomplement(bin_region);
                end 
                bin_region_thresh = imbinarize(region_norm, px_thresh);

                % compute average temperature
                I_t_masked = I_t.*mask;
                region_temps = I_t_masked(y1:y2, x1:x2);
                region_temps = region_temps.*bin_region;
                % tmax = max(region_temps(:));
                % true_max = [true_max tmax];
                avg_temp = sum(region_temps(:)) / nnz(region_temps);
                if nnz(region_temps) == 0
                    avg_temp = NaN;
                end 
                avg_temps = [avg_temps avg_temp];

                % update variables
                t = t + 1;
                B_0 = B_t;

            end 

            % detect and filter tracking errors from positions 
            thresh = 50; 
            [xpos_filt, ypos_filt, max_temps, avg_temps, intensity, movement] = filter_positions(thresh, xpos, ypos, max_temps, avg_temps, intensity, movement);

            % save data to csv
            disp('saving...');
            temp_data_final = [xpos; ypos; xpos_filt; ypos_filt; max_temps; avg_temps; cold_plate_temp; intensity; movement]; 
            temp_data_table = array2table(transpose(temp_data_final));
            temp_data_table.Properties.VariableNames(1:9) = {'x', 'y', 'x_filt', 'y_filt', 'max_temp', 'avg_temp', 'cold_plate_temp', 'intensity', 'movement'};
            writetable(temp_data_table, outpath); 

            display(outpath)           
            
        end
        
    end
    
end 