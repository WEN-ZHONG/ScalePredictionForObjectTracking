function [result, res] = run_tracker(img_path, img_files, init_box, padding, ...
    kernel, lambda, output_sigma_factor, interp_factor, cell_size, features, show_visualization, theta)

result = zeros(numel(img_files), 4);  %to calculate precision

res=[];

if show_visualization  %create video interface
    update_visualization = show_video(img_files, img_path, false);
end

%=======================SPM INTEGRATION=======================%
x0 = init_box(1) + 0.5*init_box(3);
y0 = init_box(2) +  0.5*init_box(4);
w0 = init_box(3);
h0 = init_box(4);
pos =[y0, x0];
target_sz = [h0, w0];
%=======================SPM INTEGRATION=======================%


window_sz = floor(target_sz * (1 + padding));
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));
cos_window = hann(size(yf,1)) * hann(size(yf,2))';
scale = 1;

for frame = 1:numel(img_files)
    im = imread([img_path img_files{frame}]);
    if size(im,3) > 1
        im = rgb2gray(im);
    end
    if frame > 1
        patch = get_subwindow(im, pos, window_sz, scale);       
        zf = fft2(get_features(patch, features, cell_size, cos_window));
        %calculate response of the classifier at all shifts
        switch kernel.type
            case 'gaussian'
                kzf = gaussian_correlation(zf, model_xf, kernel.sigma);
            case 'polynomial'
                kzf = polynomial_correlation(zf, model_xf, kernel.poly_a, kernel.poly_b);
            case 'linear'
                kzf = linear_correlation(zf, model_xf);
        end
        response = real(ifft2(model_alphaf .* kzf));  %equation for fast detection
        res =  [res; response];  
        [vert_delta, horiz_delta] = find(response == max(response(:)), 1);
        if vert_delta > size(zf,1) / 2  %wrap around to negative half-space of vertical axis
            vert_delta = vert_delta - size(zf,1);
        end
        if horiz_delta > size(zf,2) / 2  %same for horizontal axis
            horiz_delta = horiz_delta - size(zf,2);
        end
        pos = pos + cell_size * [vert_delta - 1, horiz_delta - 1];
        
%=======================SPM INTEGRATION=======================%
        % Scale Estimation 
        x1 = pos(2);
        y1 = pos(1);
        [h1, scale] = scale_estimation(theta, x1, y1, x0, y0, h0);
        w1 = w0*scale;
        target_sz(2) = w1; 
        target_sz(1) = h1;
%=======================SPM INTEGRATION=======================%
        
    end
    
    %obtain a subwindow for training at newly estimated target position
    patch = get_subwindow(im, pos, window_sz, scale);
    xf = fft2(get_features(patch, features, cell_size, cos_window));
    %Kernel Ridge Regression, calculate alphas (in Fourier domain)
    switch kernel.type
        case 'gaussian'
            kf = gaussian_correlation(xf, xf, kernel.sigma);
        case 'polynomial'
            kf = polynomial_correlation(xf, xf, kernel.poly_a, kernel.poly_b);
        case 'linear'
            kf = linear_correlation(xf, xf);
    end
    alphaf = yf ./ (kf + lambda);   %equation for fast training
    
    if frame == 1  %first frame, train with a single image
        model_alphaf = alphaf;
        model_xf = xf;
    else
        %subsequent frames, interpolate model
        model_alphaf = (1 - interp_factor) * model_alphaf + interp_factor * alphaf;
        model_xf = (1 - interp_factor) * model_xf + interp_factor * xf;
        %model_alphaf = alphaf;
        %model_xf = xf;
    end
        
    box = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    result(frame,:) = box;
    
    % visualization
    if show_visualization        
        stop = update_visualization(frame, box);
        if stop, break, end  %user pressed Esc, stop early        
        drawnow
    end
end

end