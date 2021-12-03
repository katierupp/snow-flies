# import statements
import os
import cv2
import glob
import pandas as pd
import numpy as np

# need to download csq module to read .csq files
from csq.csq import CSQReader

### DEFINE THESE PARAMETERS

# path to folder with all session dates
prefix = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\2020-2021\data\snow_flies'

# how often to save frames (n = 1 saves every frame, n = 10 saves every 10th frame, etc)
n = 1 

# for testing
prefix = '/Users/katierupp/Downloads' 
sessions = ['3.1.21']
n = 1000

# given a path to a .csq file, extracts and saves all frames
# as .pngs to the given output directory
def save_all_frames(vidpath, outdir):

    # read the video
    reader = CSQReader(vidpath)
    fnum = 0

    # save every frame
    while reader.next_frame() is not None:

        im = reader.next_frame()
        im_name = 'img' + str(fnum).zfill(5)+ '.png'
        cv2.imwrite(os.path.join(outdir, im_name), im)
        fnum+=1

    # print number of saved frames (i.e. total frame count)
    print(f'saved {str(fnum)} frames to {outdir}')

# given a path to a .csq file, extracts and saves every nth
# frame as .pngs to the given output directory
def save_with_skipping(vidpath, outdir, n):

    # read the video
    reader = CSQReader(vidpath)
    fnum = 0
    ix = 0

    while reader.skip_frame() is True:

        # save every nth frame
        if np.mod(fnum, n) == 0:
            im = reader.next_frame()
            im_name = 'img' + str(ix).zfill(5)+ '.png'
            cv2.imwrite(os.path.join(outdir, im_name), im)
            ix+=1
        fnum+=1

    # print number of saved frames
    print(f'saved {str(ix)} frames to {outdir}')



# traverse over each date
for session in next(os.walk(prefix)): 

    prefix2, snow_flies, _ = next(os.walk(os.path.join(prefix, session)))

    # traverse over each snow fly
    for fly in snow_flies:

        # get path to folder with .csq files
        prefix3, _, _ = os.path.join(prefix2, fly)

        # find csq videos
        videos = glob.glob(os.path.join(prefix3, '*.csq'))

        # traverse over videos incase there are more than one
        # in the directory
        for video in videos: 

            # skip video if the output directory exists, 
            # create the output directory if it doesn't
            vidpath = os.path.join(prefix3, videos[0])
            outdir = os.path.join(prefix3, f'frames_{fly}_{video}') 
            if os.path.isdir(outdir):
                print(f'{outdir} already exists')
                continue
            else: 
                os.mkdir(outdir)

            # save every frame to video
            if n == 1: 
                save_all_frames(vidpath, outdir)
            # save every nth frame to video
            else: 
                save_with_skipping(vidpath, outdir, n)
