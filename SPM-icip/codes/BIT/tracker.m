function [positions, result, time] = tracker(video_path, img_files, pos, target_sz, show_visualization, theta)

    ns = 4; %the size of each cell grid on Eq(6)
    sigma_s = [0.1 0.09 0.08]; %scale paramenter on Eq (17) 
    rho = 0.02; %learning paramenter on Eq(20)
    padding = 1.5; %ROI padding surrounding the target
    epsilon = 1e-4; %epsilon

    ROI_sz = floor(target_sz * (1 + padding)); %ROI size
    sigma_s = sqrt(prod(target_sz)) * sigma_s / ns; %normalize sigma_s according to target size
    
    labels = C2_labels(sigma_s, floor(ROI_sz / ns)); %C2 labels on Eq(17)
    labels_fft = fft2(labels);
    hann_window = hann(size(labels_fft,1)) * hann(size(labels_fft,2))';%hann window
    scale = 1;
    
    task=2;
    pre_C2=labels(:,:,task);
    diff_C2s=[];
    
    time = 0;
    positions = zeros(numel(img_files), 2);
    result = zeros(numel(img_files), 4);
    
    %% visualization
    if show_visualization, 
        update_visualization = show_video(img_files, video_path, 0);
    end
    
%=======================SPM INTEGRATION=======================%
    x0 = pos(2);
    y0 = pos(1);
    w0 = target_sz(2);
    h0 = target_sz(1);
%=======================SPM INTEGRATION=======================%
    
    
    %% BIT: Biologically Inspired Tracker
    for frame = 1:numel(img_files),
        im = imread([video_path img_files{frame}]);
        tic()
        if frame > 1,
            ROI_patch = get_ROI(im, pos, ROI_sz, scale);
            C1 = get_bif(ROI_patch, ns);
            C1 = bsxfun(@times, C1, hann_window); %hann window is used to advoid spectrum energy leakage
            C1_fft = fft2(C1);
            S2_fft = sum(C1_fft .* conj(C1p_fft), 3) / numel(C1_fft); %S2 units on Eq(16)
            
            %C2 units on Eq(10)
            C2s = real(ifft2(bsxfun(@times, W_fft,S2_fft)));      
            C2 = C2s(:,:,task);
            
            [pos_y, pos_x] = find(C2 == max(C2(:)), 1); %the object location on Eq(19)
            pos = pos + ns * [pos_y-floor(size(C2,1)/2), pos_x-floor(size(C2,2)/2)];
            
%=======================SPM INTEGRATION=======================%
            % Scale Estimation 
            x1 = pos(2);
            y1 = pos(1);
            [h1, scale] = scale_estimation(theta, x1, y1, x0, y0, h0);
            w1 = w0*scale;
            target_sz(2) = w1; 
            target_sz(1) = h1;
%=======================SPM INTEGRATION=======================%
            
            % sigma_s  adaption
            %the scale parameter sigma_s of C2 is set to 0.1 or 0.08 according to the C2
            %response in the first five frames. (When the average trend is ascending, 
            %sigma_s is set to 0.1 or is set to 0.08 otherwise).
            if(frame<=5)
                diff_C2=sum(pre_C2-C2);
                diff_C2s=[diff_C2s diff_C2];
                if(frame==5)
                    if(mean(diff_C2s)>0)
                        task=1;
                    else
                        task=3;
                    end
                end
                pre_C2=C2;
            end
        end

        ROI_patch = get_ROI(im, pos, ROI_sz, scale); %obtain a ROI for training at estimated target position
        C1 = get_bif(ROI_patch, ns);
        C1 = bsxfun(@times, C1, hann_window); %hann window is used to advoid spectrum energy leakage
        C1_fft = fft2(C1);

        S2_fft = sum(C1_fft .* conj(C1_fft), 3) / numel(C1_fft); %S2 unit on Eq(16)
        %the neuron connection weights on Eq(18)
        newW_fft = bsxfun(@rdivide, labels_fft, (S2_fft + epsilon)); %epsilon advoids denominator equal to zero
        
        if frame == 1, %BIT init
            W_fft = newW_fft;
            C1p_fft = C1_fft;
        else %BIT update on Eq(20)
            W_fft = (1 - rho) * W_fft + rho * newW_fft; 
            C1p_fft = (1 - rho) * C1p_fft + rho * C1_fft; 
        end
        
        %save position and timing
        time = time + toc();
        positions(frame,:) = pos;
		
        box = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
        result(frame,:) = box;
        
        %% visualization
        if show_visualization,
            %box = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
            stop = update_visualization(frame, box);
            if stop, break, end  %user pressed Esc, stop early
            drawnow
        end    
    end

end

