%% parm init
kernel.type = 'gaussian';
features.type = 'hog';
show_visualization = true;
show_plots = true;
features.gray = false;
features.hog = true;
padding = 1.5;  %extra area surrounding the target
lambda = 1e-4;  %regularization
output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)
interp_factor = 0.02;
kernel.sigma = 0.5;
kernel.poly_a = 1;
kernel.poly_b = 9;
features.hog_orientations = 9;
cell_size = 4;

%% path init
%=======================SPM INTEGRATION=======================%
%Please change data_path to the directory where our dataset was stored.
data_path = '../../dataset/';
%=======================SPM INTEGRATION=======================%
seq_names = {'1_car5','1_nonm7','1_nonm12','2_car3','2_people9','5_nonm1','5_people2','6_people2','6_people4','6_people8','7_nonm2','7_nonm3','7_people6','8_people2','8_people4','seq1','seq2','seq3'};
%videos ={'8_people2','8_people4','seq1','seq2','seq3'};
%seq_names = {'seq2'};

%% Run
for i = 1:18
    seq_path =  [data_path, seq_names{i}, '/'];
    [img_path, img_files, init_box] = load_video_info(seq_path);
%=======================SPM INTEGRATION=======================%
    load([seq_path, 'theta.mat']);
%=======================SPM INTEGRATION=======================%
    t0 = cputime;
    [result, res] = run_tracker(img_path, img_files, init_box, padding, ...
                    kernel, lambda, output_sigma_factor, interp_factor, ... 
                    cell_size, features, show_visualization, theta);
    t1 = cputime - t0;
    disp(t1);
    save_name = ['KCF-SP_',seq_names{i},'.txt'];
    save_result(save_name,result);
end
