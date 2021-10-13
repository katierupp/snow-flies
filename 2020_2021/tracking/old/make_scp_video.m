%%
clc; close all; clear all;

%%

prefix = 'C:\Users\sydne\Downloads';
file = 'cold_tolerance_summary - snow flies.csv';
path = fullfile(prefix, file);
data = readtable(path, 'PreserveVariableNames', true, 'format', 'auto');

%%

% root = 'C:\Users\sydne\Documents\thermal_experiments\data\3.9.21\SF0111\trial2';
root = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies\3.9.21\SF0111\trial2';
root = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies\3.9.21\SF0111\trial2';
file = 'FLIR0311.csq';
path = fullfile(root, file);


vidname = {'FLIR0311.csq'};
row_data = data(strcmp(data.video, vidname), :);

if isempty(row_data.scp_frame)
    display('no scp');
end 


scp_frame = str2num(row_data.scp_frame{1});
t = 1;
t_start = scp_frame - 500;
t_end = scp_frame + 500;
ix = 1;

% mask_path = fullfile(outroot, 'roi.png');
% if isfile(mask_path) 
%     mask = imbinarize(imread(mask_path));
%     imagesc(mask);
% end 
    
v = FlirMovieReader(path);
v.unit = 'temperatureFactory';
[I_0, metadata] = step(v);

outpath = fullfile(root, 'FLIR0242_scp_new.avi');
v_new = VideoWriter(outpath);
open(v_new);

nframes = t_end - t_start;
max_temps = zeros(1, nframes);
min_temps = zeros(1, nframes);

% while ~isDone(v)
while (t < t_end) || ~isDone(v)
    
    [im, metadata] = step(v);
    
    if (t >= t_start) && (t < t_end)
        im_norm = mat2gray(im);
        writeVideo(v_new, im_norm);
        max_temps(ix) = max(im(:));
        min_temps(ix) = min(im(:));
        ix = ix + 1;
    end 
    
    t = t + 1;
end 

close(v_new)

%%

% root = 'C:\Users\sydne\Documents\thermal_experiments\data\3.9.21\SF0111\trial2';
root = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies\3.9.21\SF0111\trial2';
file = 'FLIR0311.csq';
path = fullfile(root, file);


vidname = {'FLIR0311.csq'};
row_data = data(strcmp(data.video, vidname), :);

if isempty(row_data.scp_frame)
    display('no scp');
end 


scp_frame = str2num(row_data.scp_frame{1});
t = 1;
t_start = scp_frame - 1000;
t_end = scp_frame + 1000;
ix = 1;

% mask_path = fullfile(outroot, 'roi.png');
% if isfile(mask_path) 
%     mask = imbinarize(imread(mask_path));
%     imagesc(mask);
% end 
    
v = FlirMovieReader(path);
v.unit = 'temperatureFactory';
nframes = t_end - t_start;
max_temps = zeros(1, nframes);
min_temps = zeros(1, nframes);

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

amax = max(max_temps);
amin = min(min_temps);

t = 1;
v = FlirMovieReader(path);
v.unit = 'temperatureFactory';
outpath = fullfile(root, 'FLIR0242_scp.avi');
v_new = VideoWriter(outpath);
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
