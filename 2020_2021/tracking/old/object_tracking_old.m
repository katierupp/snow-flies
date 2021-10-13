close all; clear all; clc;

%%
% root = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\12.11.20\SF0020\trial1\';
% root = 'C:\Users\sydne\Documents\thermal_experiments\data\12.11.20\SF0020\trial1\';
% file = 'FLIR0103.csq';
% root = 'C:\Users\sydne\Documents\thermal_experiments\data\12.29.20\SF0049\trial1\';
% file = 'FLIR0152.csq';

% root = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\1.3.21\SF0075\trial1';
% file = 'FLIR0192.csq';
root = 'C:\Users\sydne\Documents\thermal_experiments\data\3.1.21\SF0104\trial2';
file = 'FLIR0300.csq';
path = fullfile(root, file);

outfile = 'temp_data.csv';
% outroot = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\1.3.21\SF0075\trial1';
outroot = 'C:\Users\sydne\Documents\thermal_experiments\data\3.1.21\SF0104\trial2';
outpath = fullfile(outroot, outfile);

%% specify circular region of interest 

v = FlirMovieReader(path);
v.unit = 'temperatureFactory';
[frame, metadata] = step(v);
for t = 1:2000
    [frame, metadata] = step(v);
end
% frame1 = im2double(frame);
% frame2 = imadjust(frame1);

figure();
imagesc(frame);
roi1 = drawcircle('Color','r');
center = roi1.Center;
radius = roi1.Radius;

%% specify circular region of disinterest

figure();
imagesc(frame);
roi2 = drawcircle('Color','r');

%% get mask

figure();
mask = createMask(roi1) + createMask(roi2);
mask(mask == 2) = 0;
mask = mask.*createMask(roi1);
imagesc(frame.*mask);
mask_path = fullfile(outroot, 'mask.png');

if isfile(mask_path) 
    mask = imread(mask_path);
else 
    imwrite(mask, mask_path);
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
px_thresh = 0.2;

xpos = [];
ypos = [];
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
    [row,col] = ind2sub(size(J_t), idx);
    
    % extract temperature
    xpos = [xpos col];
    ypos = [ypos row];
    max_temp =  I_t(row, col);
    max_temps = [max_temps max_temp];
    
    % J_tn = J_t / max_val; % normalize image
    
    % if t > 27000
    % display
    % imshow(J_t);
    % hold on
    % viscircles(center, radius);
    % scatter(col, row, 'r'); 
    % rectangle('Position', [col-sd2 row-sd2 s s], 'EdgeColor', 'r');
    % colorbar;
    % caxis([min(J_t(:)) max(J_t(:))]);
    % drawnow;
    % hold off 
    % end 
    
    dim = size(J_t);
    x1 = max(1, col-sd2);
    y1 = max(1, row-sd2);
    x2 = min(col + sd2 - 1 , dim(2));
    y2 = min(row + sd2 - 1, dim(1));
    fly_roi = zeros(s);
    region = J_t(y1:y2, x1:x2);
    
    % quantify pixel intensity 
    sf_region = region(region > px_thresh);
    px_intensity = sum(sf_region) / length(sf_region);
    intensity = [intensity, px_intensity];
    movement = [movement length(sf_region)];
    
    bin_region = im2bw(region);
    bin_region_thresh = im2bw(region, px_thresh);
%     imshow(region);
    
    % compute average cold plate temperature
    cold_plate = I_t.*mask;
    cold_plate(y1:y2, x1:x2) = 0; 
    cp_temp = sum(cold_plate(:)) / nnz(cold_plate);
    cold_plate_temp = [cold_plate_temp cp_temp];
    
    % compute average temperature
    region_temps = I_t(y1:y2, x1:x2);
    region_temps = region_temps.*bin_region_thresh; 
    region_temps_alt = region_temps.*bin_region;
    avg_temp = sum(region_temps(:)) / nnz(region_temps);
    if nnz(region_temps) == 0 && nnz(region_temps_alt) ~= 0
        avg_temp = sum(region_temps_alt(:)) / nnz(region_temps_alt);
    end 
    if nnz(region_temps) == 0 && nnz(region_temps_alt) == 0
        avg_temp = 0;
    end 
    avg_temps = [avg_temps avg_temp];
    
    % update variables
    t = t + 1;
    B_0 = B_t;
    
end 

%% detect and filter tracking errors from positions 

thresh = 75; 
[xpos_filt, ypos_filt, max_temps, avg_temps, movement] = filter_positions(thresh, xpos, ypos, max_temps, avg_temps, movement);

%% reichardt detector: quantifying motion as a function of temperature 


%% save data to csv 
temp_data = [xpos; ypos; xpos_filt; ypos_filt; max_temps; avg_temps; cold_plate_temp; intensity; movement]; 
temp_data_table = array2table(transpose(temp_data));
temp_data_table.Properties.VariableNames(1:9) = {'x','y', 'x_filt', 'y_filt', 'max_temp', 'avg_temp', 'cold_plate_temp', 'intensity', 'movement'};
writetable(temp_data_table, outpath);
% csvwrite(outpath, temp_data);

