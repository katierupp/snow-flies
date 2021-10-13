clc; clear all; close all; 

%% 
prefix_alt = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies\3.18.21\SF0114\trial1';
prefix4 = 'D:\sydne\Documents\snow_flies\3.18.21\SF0114\trial1'
video = 'FLIR0314.csq'
%prefix4 = fullfile(prefix3, trials(k).name)
%videos = dir(fullfile(prefix4, '*.csq'));
%video = videos(end).name

path = fullfile(prefix4, video);
mask_path = fullfile(prefix4, 'roi.png');
corr_path = fullfile(prefix4, 'temp_data_corrections_visible.csv')
outfile = fullfile(prefix_alt, 'sf_region_temps.mat');
corr_data = readtable(corr_path);

% get mask
if isfile(mask_path) 
    mask = imbinarize(imread(mask_path));
end 

% background subtraction
v = FlirMovieReader(path);
v.unit = 'temperatureFactory';
[I_0, metadata] = step(v); % initial image
t = 1; % frame
s = 80;
sd2 = floor(s/2);

x_filtered = medfilt1(corr_data.x_new, 60);
y_filtered = medfilt1(corr_data.y_new, 60);
regions = {};

disp('processing...');
figure;
while ~isDone(v)

    I_t = step(v); % next frame
    row = y_filtered(t);
    col = x_filtered(t);

    dim = size(J_t);
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

% save data to csv
disp('saving...');
save(outfile, 'regions');
display(outfile) 