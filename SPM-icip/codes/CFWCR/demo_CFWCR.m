
% This demo script runs the ECO tracker with deep features on the
% included "Crossing" video.

% Add paths
setup_paths();

% Load video information
%=======================SPM INTEGRATION=======================%
%Note: please change the video_path to the directory where you put our dataset in.
video_path = '../../dataset';
%=======================SPM INTEGRATION=======================%
[seq, ground_truth] = load_video_info(video_path);

% Run ECO
results = testing_CFWCR(seq);

fw = fopen('/media/wangxiao/ZR/S-CFWCR_7_people6.txt','w');
rows = size(results.res, 1);
cols = size(results.res, 2);
for i = 1:rows
    for j=1:cols - 1
        fprintf(fw, '%f ', results.res(i,j));
    end    
    fprintf(fw, '%f\n', results.res(i, cols));  % for Linux
     %fprintf(fw, '%d\r\n', result(i, cols));   %for Windows
end
fclose(fw);

