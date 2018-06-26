Following these steps to run the ECO-SP tracker on our dataset:
1.Download the ECO code from http://data.votchallenge.net/vot2017/trackers/30_ECO.zip
2.Copy the demo_ECO.m to the ECO directory and replace the original ones. 
3.Replace /implementation/tracker.m with the one in this directory.
4.Copy scale_estimation.m into /implementation/.
5.Replate /utils/load_video_info.m with the one provied in this directory.
6.Replace /runfiles/testing_ECO.m with the one in this directory.
7.In the demo_ECO.m file,  change the video_path(Line 12) to the directory where you put our dataset in.
8..run demo_ECO.m 