import os
import cv2
import glob
import pandas as pd
import numpy as np

from csq.csq import CSQReader
# from process_all import get_roi

prefix = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\2020-2021\data\snow_flies'
sessions = ['12.29.20', '12.28.20', '1.1.21', '1.2.21', '1.3.21', '1.11.21', '1.15.21', '1.16.21', '2.1.21', '2.5.21', '2.10.21', '3.1.21', '3.9.21', '3.18.21']

# for testing
prefix = '/Users/katierupp/Downloads'
sessions = ['3.1.21']
n = 1000

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

for session in sessions: 

    prefix2, snow_flies, _ = next(os.walk(os.path.join(prefix, session)))

    for fly in snow_flies:

        prefix3, trials, _ = next(os.walk(os.path.join(prefix2, fly)))

        for trial in trials:

            prefix4 = os.path.join(prefix3, trial)
            outdir = os.path.join(prefix4, 'snapshots2')
            mask = get_roi(prefix4)

            # skip video if the /snapshots directory exists and is 
            # already populated with images
            if os.path.isdir(outdir) and len(os.listdir(outdir)) > 10:
                continue
            else: 
                os.mkdir(outdir)

            # open video
            videos = glob.glob(os.path.join(prefix4, '*.csq'))
            vidpath = os.path.join(prefix4, videos[0])
            reader = CSQReader(vidpath)

            t = 0
            ix = 0

            while reader.skip_frame() is True:

                # save every nth frame
                if np.mod(t, n) == 0:
                    im = reader.next_frame()
                    #im = im / np.max(im)
                    #im_masked = np.multiply(im, mask)
                    #im_out = cv2.normalize(im_masked, None, alpha = 0, beta = 255, norm_type = cv2.NORM_MINMAX, dtype = cv2.CV_32F)
                    #im_out_norm = im_out.astype(np.uint8)
                    # cv2.imwrite(os.path.join(outdir, im_name), im_out_norm)
                    #im_out = cv2.normalize(im, None, alpha = 0, beta = 255, norm_type = cv2.NORM_MINMAX, dtype = cv2.CV_32F)
                    #im_out = im_out.astype(np.uint8)
                    #im_out_masked = np.multiply(im_out, mask)
                    #cv2.imwrite(os.path.join(outdir, im_name), im_out_masked)
                    #im_01 = cv2.normalize(im, None, alpha = 0, beta = 1, norm_type = cv2.NORM_MINMAX, dtype = cv2.CV_32F)
                    #im_masked = np.multiply(im_01, mask)
                    #im_out = im_masked * 255
                    im_norm = cv2.normalize(im, None, np.min(im), np.max(im), cv2.NORM_MINMAX)
                    im_norm = im_norm.astype(np.uint8)
                    im_norm_masked = np.multiply(im_norm, mask)
                    im_name = 'img' + str(ix).zfill(5)+ '.png'
                    cv2.imwrite(os.path.join(outdir, im_name), im_norm_masked)
                    ix = ix + 1

                t+=1

            print('saved ' + str(ix) + ' frames to ' + outdir)