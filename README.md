# snow-flies
Tracking and analysis of snow flies: a study of insect cold tolerance

## summary of data 
### winter 2020-2021
spreadsheet: https://docs.google.com/spreadsheets/d/1LyIAfQo4p5vI4wIxJQ8HYh3IkgytjAzbROX8pHmPSaI/edit#gid=0

file structure: experiment date -> snow fly ID -> trial number -> thermal video

(e.g. 1.3.21 -> SF0081 -> trial1 -> FLIR0196.csq) 

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
13. Dry off the cold plate and metal ring with paper towels because ice crystals usually form during each trial. This step is more important than it may sound - if a snow fly comes in contact with a drop of water, it can hinder the snow fly's ability to move or drown the snow fly. 
14. Enter data relating to the trial in a spreadsheet (refer to the link at the top for an example). Be sure to immediately include: 
    * Experiment date
    * Snow fly ID
    * Filename of thermal video
    * Filename of visible light video
    * Any additional notes/observations
15. Repeat for remaining snow flies
16. Remove the microSD card from the thermal camera, return to lab, and upload the .csq files to Google Drive using a lab computer
17. Transfer all videos captured by the visible light camera to Google Drive
18. Place snow flies back in the snow fly lodge 
19. Thermal videos (.csq) can be opened and viewed with the FLIR ResearchIR software. Add additional information to the spreadsheet: 
    * Collection date
    * Collection location
    * Temperature at which snow fly entered chill coma (if at all)
    * Temperature at which supercooling occurred (if at all)

## tracking 

## analysis
