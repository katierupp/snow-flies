close all; clear all; clc;

% loads in .csq files and saves them as .mp4 files for python analysis
% root = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\12.11.20\SF0020\trial1\';
root = 'C:\Users\sydne\Documents\thermal_experiments\12.11.20\SF0020\trial1\';
file = 'FLIR0103.csq';


v = FlirMovieReader([root file]);
v.unit = 'temperatureFactory';
[frame, metadata] = step(v);
frame1 = im2double(frame);
frame2 = imadjust(frame1);
figure, imagesc(frame1);

%% find min and max temperatures for entire video

v = FlirMovieReader([root file]);
v.unit = 'temperatureFactory';
min_temps = [];
max_temps = []; 
n_frames = 0;
writer = VideoWriter('newfile.avi');
open(writer);

while ~isDone(v)
    % Get the next frame.
    frame = step(v);
    videoFrame = mat2gray(frame);
    writeVideo(writer, videoFrame);
    % min_temps = [min_temps, min(frame(:))];
    % max_temps = [max_temps, max(frame(:))];
    %videoFrame = im2double(frame);
    %videoFrame = imadjust(videoFrame);
    n_frames = n_frames + 1
end 

close(writer);
    
min_temp = min(min_temps);
max_temp = max(max_temps);




