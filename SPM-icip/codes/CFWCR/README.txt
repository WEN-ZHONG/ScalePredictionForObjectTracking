Following these steps to run the CFWCR-SP tracker on our dataset:
1.Download the CFWCR code from http://data.votchallenge.net/vot2017/trackers/14_CFWCR.zip 
2.Replate demo_CFWCR.m in iles in the root directory with demo_CFWCR.m in this directory.
3.Replace tracker.m, in the /implementation directory with the one in this directory.
4.Replace /utils/load_video_info.m with the one in this directory.
5.Copy the scale_estimation.m to the /implementation directory. 
6.In the demo_CFWCR.m, change the video_path (Line 12) to the directory where our dataset stored.
7.Replace /runfiles/testing_CFWCR.m the one in this directory;
8.run demo_CFWCR.m

 