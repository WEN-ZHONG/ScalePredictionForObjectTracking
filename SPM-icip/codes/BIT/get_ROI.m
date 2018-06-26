function out = get_ROI(im, pos, sz, scale)

    if isscalar(sz)  %square sub-window
		sz = [sz, sz];
	end
  
    xs = floor(pos(2)) + (1:floor(sz(2)*scale)) - floor(sz(2)*scale/2);
	ys = floor(pos(1)) + (1:floor(sz(1)*scale)) - floor(sz(1)*scale/2);
	
    xs(xs < 1) = 1;
    ys(ys < 1) = 1;
    xs(xs > size(im,2)) = size(im,2);
    ys(ys > size(im,1)) = size(im,1);
	
    out = imresize(im(ys, xs, :),[sz(1) sz(2)]);
end

