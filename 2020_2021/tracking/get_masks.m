close all; clear all; clc;

%%
prefix = 'C:\Users\sydne\Documents\thermal_experiments\data\';
prefix  = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\snow_flies';

%% automate specifying the mask for the snow fly's range of motion

files = dir(prefix);
dates = files([files.isdir]);

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
            
            prefix4 = fullfile(prefix3, trials(k).name);
            if isfile(fullfile(prefix4, 'roi.png')) || ~isfile(fullfile(prefix4, 'mask.bmp'))
                continue
            end 

            prefix4
            e1 = fullfile(prefix4, 'mask - Ellipse 1.bmp');
            e2 = fullfile(prefix4, 'mask - Ellipse 2.bmp');
            if (~isfile(e1) || ~isfile(e2))
                continue
            end
            
            ellipse1 = imread(e1);
            roi1 = imbinarize(ellipse1);
            
            ellipse2 = imread(e2);
            roi2 = imbinarize(ellipse2);
            
            mask = roi1 + roi2;
            mask(mask == 2) = 0;
            mask = mask.*roi1;
            imwrite(mask, fullfile(prefix4, 'roi.png'));
            
        end
    end
end    


%%

