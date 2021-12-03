import os
import cv2
import glob
import pandas as pd
import numpy as np

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
            outpath = os.path.join(prefix4, 'roi_new.png')

            if os.path.isfile(outpath):
                continue 

            ellipses = glob.glob(os.path.join(prefix4, '*.bmp'))
            for e in ellipses: 

                e = cv2.imread(e, 0)
                _, roi = cv2.threshold(e, 0, 1, cv2.THRESH_BINARY)
                mask = mask + roi

            mask[mask >= 2] = 0
            #mask = np.multiply(mask, roi1)
            #cv2.imwrite(outpath, mask)
            