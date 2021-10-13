close all; clear all; clc;

%%
prefix = 'C:\Users\sydne\Documents\thermal_experiments\data\';
prefix  = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\';

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
            prefix4 
            = fullfile(prefix3, trials(k).name);
            if isfile(fullfile(prefix4, 'mask.png'))
                continue
            end 
            video = dir(fullfile(prefix4,'*.csq'));        
            v = FlirMovieReader(fullfile(prefix4, video(1).name));
            v.unit = 'temperatureFactory';
            for t = 1:2000
                [frame, metadata] = step(v);
            end
            
            figure();
            imagesc(frame);
            roi1 = drawcircle('Color','r');
            % roi = drawellipse('Color','r');
            input('');
                    
            figure();
            imagesc(frame);
            roi2 = drawcircle('Color','r');
            input('');
            
            mask = createMask(roi1) + createMask(roi2);
            mask(mask == 2) = 0;
            mask = mask.*createMask(roi1);
            imwrite(mask, fullfile(prefix4, 'mask.png'));
            
        end
    end
end    


%%

