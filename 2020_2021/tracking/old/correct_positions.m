%% process corrections to snow fly position
clc; clear all; close all;

%% 
prefix = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies\12.29.20\SF0049\trial1';
path = fullfile(prefix, 'FLIR0152.csq');
corr_path = fullfile(prefix, 'temp_data_corrections.csv');
corr_data = readtable(corr_path);

%% get mask

mask_path = fullfile(prefix, 'roi.png');
if isfile(mask_path) 
    mask = imbinarize(imread(mask_path));
    imagesc(mask);
end 
    
%% background subtraction

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
% movement_thresh = 400;
% intensity_thresh = 0.4;

xpos = [];
ypos = [];
true_max = [];
max_temps = [];
avg_temps = [];
cold_plate_temp = [];
intensity = [];
movement = [];

figure; 
%imshow(J_0.*mask);

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
    row = corr_data.y_new(t+1);
    col = corr_data.x_new(t+1);
    
    % extract max temperature
    xpos = [xpos col];
    ypos = [ypos row];
    max_temp =  I_t(row, col);
    max_temps = [max_temps max_temp];
    
    J_tn = J_t / max_val; % normalize image
%     
%     if t > 35000
%     imshow(J_tn);
%     hold on
%     scatter(col, row, 'r'); 
%     rectangle('Position', [col-sd2 row-sd2 s s], 'EdgeColor', 'r');
%     colorbar;
%     caxis([min(J_tn(:)) max(J_tn(:))]);
%     drawnow;
%     hold off 
%     end 
    
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
    bin_region_thresh = imbinarize(region_norm, px_thresh);
    % imshow(bin_region_thresh);
    
    % compute average temperature
    I_t_masked = I_t.*mask;
    region_temps = I_t_masked(y1:y2, x1:x2);
    region_temps = region_temps.*bin_region;
    tmax = max(region_temps(:));
    true_max = [true_max tmax];
    region_temps_alt = region_temps.*bin_region;
    avg_temp = sum(region_temps(:)) / nnz(region_temps);
    if nnz(region_temps) == 0 && nnz(region_temps_alt) ~= 0
        avg_temp = sum(region_temps_alt(:)) / nnz(region_temps_alt);
    end 
    if nnz(region_temps) == 0 && nnz(region_temps_alt) == 0
        avg_temp = NaN;
    end 
    avg_temps = [avg_temps avg_temp];
    
    % update variables
    t = t + 1;
    B_0 = B_t;
    
end 

%% 
temp_data_final = [xpos; ypos; max_temps; avg_temps; cold_plate_temp; intensity; movement]; 
temp_data_table = array2table(transpose(temp_data_final));
temp_data_table.Properties.VariableNames(1:7) = {'x', 'y', 'max_temp', 'avg_temp', 'cold_plate_temp', 'intensity', 'movement'};
outpath = fullfile(prefix, 'temp_data_final.csv');
writetable(temp_data_table, outpath);
