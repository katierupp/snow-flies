# snow-flies
Tracking and analysis of snow flies: a study of insect cold tolerance

## experimental procedure (new)

1. Plug in all equipment 
   * Laptop always needs to be charging
   * Connect peltier to laptop (usb) and power supply (power cable)
   * Connect visible light camera to laptop (usb)
   * Connect arduino board to laptop (can disconnect after uploading if the arduino is plugged into power supply)
2. Open TecaLog software on laptop to control peltier
   * Create temperature ramp (only need to do once assuming the same ramp is used for all experiments)
   * Load in the temperature ramp and save it to the controller
3. Open FlyCap software on laptop to control visible light camera
   * Set up the camera to capture video (not images)
   * Specify the location and filename of the .avi file
   * Select 'Compressed AVI' for the video format and specify the quality (0-100)
4. Upload servo.ino to the arduino board (can disconnect the arduino from the computer after uploading if the arduino is plugged into power supply)
   * Specify the frequency of temporal alignment before uploading
5. Turn on thermal camera and switch the image mode to macro
6. Coat the metal ring with RainX, then position it on the peltier so the entire bottom of the ring can be seen in both the visible light and thermal camera
7. Place one snow fly in the metal ring 
8. Click 'start' in the TecaLog software to start the temperature ramp, then start recording from the visible light and thermal cameras
9. Monitor the snowfly occasionally to make sure it does not attempt to climb out of the metal ring (don't be fooled, they can be sneaky!)
10. After the cold plate reaches the lowest temperature, allow it to come back to room temperature (around 0C)
11. Stop recording from the visible light and thermal cameras
12. Carefully transfer the snow fly to a microcentrifuge tube. If the snow fly did not survive, fill the test tube with ethanol to preserve the specimen.
13. Dry off the cold plate with paper towels (ice crystals often form)
14. Enter data relating to the trial in a spreadsheet. Be sure to include: 
    * Snow fly ID
    * Filename of thermal video
    * Filename of visible light video
    * Collection location 
    * Any additional notes/observations
15. Repeat for remaining snow flies
16. Remove the microSD card from the thermal camera and upload the .csq files to Google Drive 
17. Place specimens in labeled tubes back in the snow fly lodge 

## tracking 

## analysis
