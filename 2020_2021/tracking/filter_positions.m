% if the x position jumps a number of pixels above the threshold, assume
% there was a tracking error and the fly did not move from the previous
% position. fixes one frame jumps. 
function [xpos, ypos, max_temps, avg_temps, intensity, movement] = filter_positions(thresh, xpos, ypos, max_temps, avg_temps, intensity, movement)

    corr = [];
    dists = abs(diff(xpos));
    dists = [0, dists];
    for ix = 1:length(dists)-1
        if (dists(ix) > thresh)
            corr = [corr ix];
        end 
    end 
    
    err = corr + 1;
    xpos(corr) = xpos(err);
    ypos(corr) = ypos(err);
    max_temps(corr) = max_temps(err);
    avg_temps(corr) = avg_temps(err);
    movement(corr) = movement(err);
    intensity(corr) = intensity(err);
    
end

% function [xpos, ypos, max_temps, avg_temps, movement] = filter_positions(thresh, xpos, ypos, max_temps, avg_temps, movement)
% 
%     for ix = 2:length(xpos)
%         
%         if (xpos(ix-1) == 1 && ypos(ix-1) == 1)
%             continue
%         end 
%             
%         dist = abs(xpos(ix-1) - xpos(ix));
%         if (dist > thresh)
%             xpos(ix) = xpos(ix-1);
%             ypos(ix) = ypos(ix-1);
%             max_temps(ix) = max_temps(ix-1);
%             avg_temps(ix) = avg_temps(ix-1);
%             movement(ix) = movement(ix-1);
%         end 
%     end     
% end