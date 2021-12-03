import os
import cv2
import glob
import pandas as pd
import numpy as np

from csq.csq import CSQReader

# if the x or y position jumps a number of pixels above the threshold, assume
# there was a tracking error and the fly did not move from the previous
# position. fixes one frame jumps. 
def find_errors(xs, ys, thresh):

    corr = []
    dists_x = np.zeros(len(xs))
    dists_x[1:] = np.abs(np.diff(xs))
    dists_y = np.zeros(len(ys))
    dists_y[1:] = np.abs(np.diff(ys))
    for j in range(len(dists_x)-1):
        if (dists_x[j] > thresh) or (dists_y[j] > thresh):
            corr.append(j)

    return np.array(corr)

def get_roi(prefix):

    outpath = os.path.join(prefix, 'roi.png')
    if os.path.isfile(outpath):
        mask = cv2.imread(outpath, 0)
        _, mask = cv2.threshold(mask, 0, 1, cv2.THRESH_BINARY)
    else:
        e1 = os.path.join(prefix, 'mask - Ellipse 1.bmp')
        e2 = os.path.join(prefix, 'mask - Ellipse 2.bmp')

        ellipse1 = cv2.imread(e1, 0)           
        _, roi1 = cv2.threshold(ellipse1, 0, 1, cv2.THRESH_BINARY) 
        
        ellipse2 = cv2.imread(e2, 0)
        _, roi2 = cv2.threshold(ellipse2, 0, 1, cv2.THRESH_BINARY)

        mask = roi1 + roi2
        mask[mask == 2] = 0
        mask = np.multiply(mask, roi1)
        cv2.imwrite(outpath, mask)

    return mask

prefix = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\2020-2021\data\snow_flies'
sessions = ['12.29.20', '12.28.20', '1.1.21', '1.2.21', '1.3.21', '1.11.21', '1.15.21', '1.16.21', '2.1.21', '2.5.21', '2.10.21', '3.1.21', '3.9.21', '3.18.21']

# for testing
prefix = '/Users/katierupp/Downloads'
sessions = ['3.1.21']

for session in sessions: 

    prefix2, snow_flies, _ = next(os.walk(os.path.join(prefix, session)))

    for fly in snow_flies:

        prefix3, trials, _ = next(os.walk(os.path.join(prefix2, fly)))

        for trial in trials:

            prefix4 = os.path.join(prefix3, trial)
            outpath = os.path.join(prefix4, 'temp_data.csv')

            #if os.path.exists(outpath):
            #    continue

            videos = glob.glob(os.path.join(prefix4, '*.csq'))
            vidpath = os.path.join(prefix4, videos[0])
            # track_snow_fly(vidpath)

            # get mask
            # mask_path = os.path.join(prefix4, 'roi.png')
            # if os.path.isfile(mask_path):
            #     im = cv2.imread(mask_path, 0)
            #     _, mask = cv2.threshold(im, 0, 1, cv2.THRESH_BINARY)
            # else: 
            #     continue

            # get mask
            mask = get_roi(prefix4)

            # background subtraction
            reader = CSQReader(vidpath)

            I_0 = reader.next_frame() # initial image
            I_bar = np.mean(I_0)
            B_0 = I_0 # background
            J_0 = I_0 - I_bar - B_0 # background subtracted image

            alpha = 0.99 # can change this parameter, 0 <= alpha <= 1
            t = 0 # frame

            s = 70
            sd2 = int(np.floor(s/2))
            px_thresh = 0.7

            xpos = []
            ypos = []
            max_temps = []
            avg_temps = []
            cold_plate_temp = []
            # true_max = []
            # intensity = []
            # movement = []

            print('processing...')

            while reader.next_frame() is not None: 

                I_t = reader.next_frame()
                I_bar = np.mean(I_t)
                B_t = B_0 * alpha + (1 - alpha)*(I_t - I_bar) # update background image
                J_t = I_t - I_bar - B_t # background subtracted image

                # J_t(J_t < 0) = 0
                J_t = np.abs(J_t)
                J_t = np.multiply(J_t, mask) # apply mask

                # determine location of max pixel value
                max_val = np.max(J_t)
                max_idx = np.argmax(J_t)
                (row, col) = np.unravel_index(max_idx, J_t.shape)

                # extract max temperature
                xpos.append(col)
                ypos.append(row)
                max_temp =  I_t[row, col]
                max_temps.append(max_temp)
                J_tn = J_t / max_val; # normalize image

                x1 = max(1, col-sd2)
                y1 = max(1, row-sd2)
                x2 = min(col + sd2 - 1 , J_t.shape[1])
                y2 = min(row + sd2 - 1, J_t.shape[0])
                fly_roi = np.zeros([s, s])
                region = J_tn[y1:y2, x1:x2]
                region_norm = region / np.max(region)

                # quantify pixel intensity 
                sf_region = region[region > px_thresh]
                # px_intensity = np.sum(sf_region) / len(sf_region)
                # intensity.append(px_intensity)
                # movement.append(len(sf_region)

                # compute average cold plate temperature
                cold_plate = np.multiply(I_t, mask)
                cold_plate[y1:y2, x1:x2] = 0 
                cp_temp = np.sum(cold_plate) / np.count_nonzero(cold_plate)
                cold_plate_temp.append(cp_temp)

                _, bin_region = cv2.threshold(region_norm, 0.5, 1, cv2.THRESH_BINARY)
                if len(bin_region[bin_region == 1]) > len(bin_region[bin_region == 0]):
                    _, bin_region = cv2.threshold(bin_region, 0.5, 1, cv2.THRESH_BINARY_INV)
                _, bin_region_thresh = cv2.threshold(region_norm, px_thresh, 1, cv2.THRESH_BINARY)

                # compute average temperature
                I_t_masked = np.multiply(I_t, mask)
                region_temps = I_t_masked[y1:y2, x1:x2]
                region_temps = np.multiply(region_temps, bin_region)
                # tmax = max(region_temps(:));
                # true_max = [true_max tmax];
                if np.count_nonzero(region_temps) == 0:
                    avg_temp = np.nan
                else: 
                    avg_temp = np.sum(region_temps) / np.count_nonzero(region_temps)

                avg_temps.append(avg_temp)

                if t > 100:
                    break

                # update variables
                t+=1
                B_0 = B_t

            # detect tracking errors from positions 
            error_ixs = find_errors(xpos, ypos, thresh = 50)

            # save data to csv
            print('saving...')
            data = {'x': np.array(xpos),
                    'y': np.array(ypos), 
                    'x_filt': np.array(xpos),
                    'y_filt': np.array(ypos), 
                    'max_temp': np.array(max_temps),
                    'avg_temp': np.array(avg_temps),
                    'cold_plate_temp': np.array(cold_plate_temp)}
            temp_data = pd.DataFrame.from_dict(data)
            temp_data.loc[error_ixs + 1, 'x_filt':'cold_plate_temp'] = temp_data.loc[error_ixs, 'x_filt':'cold_plate_temp']
            temp_data.to_csv(outpath);   
            print(outpath) 

