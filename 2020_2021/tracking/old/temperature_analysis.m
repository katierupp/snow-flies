%% script for analyzing temperature of snow flies 
close all; clear all; clc;
cl
%% specify video

prefix = 'C:\Users\sydne\Documents\thermal_experiments\data\12.29.20\SF0049\trial1\';
prefix = 'C:\Users\sydne\Documents\thermal_experiments\data\1.3.21\SF0075\trial1\';
prefix = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies\3.9.21\SF0111\trial2';
data_path = fullfile(prefix, 'temp_data.csv');
data = readtable(data_path);

%% compute video duration

fps = 30; 
nframes = length(data.x_filt);
frames = 1:nframes;
time_s = frames / fps; % duration of video (seconds)
time_m = frames / (fps*60); % duration of video (minutes)

t = time_m;

%% plot x position across time
figure();
xlim([0 30]);
xlabel('time (minutes)');
ylabel('x position (pixels)');
hold on;
plot(t, data.x_filt, 'k');
hold off;


%% plot y position across time
figure();
xlim([0 30]);
xlabel('time (minutes)');
ylabel('y position (pixels)');
hold on;
plot(t, data.y_filt, 'k');
hold off;

%% plot the average temperature across time 

order = 7;
max_temp = data.max_temp;
avg_temp = data.avg_temp; % medfilt1(data.avg_temp, order);
cold_plate_temp = medfilt1(data.cold_plate_temp, order);

figure();
% xlim([0 20]);
xlabel('time (minutes)');
ylabel('temperature (\circ C)');
hold on;
plot(t, max_temp, 'r');
plot(t(avg_temp ~= 0), avg_temp(avg_temp ~= 0), 'k');
plot(t, cold_plate_temp, 'b');
legend('max fly temperature', 'average fly temperature', 'cold plate temperature');
hold off;

% saveas(gcf, [prefix 'fig1.png']);


%% plot the average movement across frames 

figure(); 
xlabel('time (minutes)');
ylabel('average movement');
% ylim([0, 1]);
% xlim([0.5, 20]);
hold on;
plot(t, data.movement, 'k');
% plot(t, data.intensity);
% legend('movement', 'intensity')
hold off; 

% saveas(gcf, fullfile(prefix, 'fig2.png'));

%% plot the average movement as a function of temperature 

figure();
xlabel('cold plate temperature (\circ C)');
ylabel('average movement');
hold on; 
scatter(data.cold_plate_temp, data.movement);
hold off;

% saveas(gcf, fullfile(prefix, 'fig3.png'));

%% plot average movement with the cold plate and fly temperature 

figure(); 
hold on;
xlabel('time (minutes)');
xlim([0 max(t)]);

yyaxis left 
ylabel('temperature (\circ C)');
plot(t, data.max_temp, 'r');
plot(t, data.avg_temp, 'k');
plot(t, data.cold_plate_temp, 'b');

yyaxis right 
ylabel('movement');
ylim([0, 1]);
plot(t, data.movement);

ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';

legend('max fly temperature', 'average fly temperature', 'cold plate temperature', 'movement');
% saveas(gcf, fullfile(prefix 'fig4.png'));

