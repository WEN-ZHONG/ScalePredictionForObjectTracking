function out = get_subwindow(im, pos, sz, scale)
%GET_SUBWINDOW Obtain sub-window from image, with replication-padding.
%   Returns sub-window of image IM centered at POS ([y, x] coordinates),
%   with size SZ ([height, width]). If any pixels are outside of the image,
%   they will replicate the values at the borders.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

	if isscalar(sz)  %square sub-window
		sz = [sz, sz];
	end
	
	xs = floor(pos(2)) + (1:floor(sz(2)*scale)) - floor(sz(2)*scale/2);
	ys = floor(pos(1)) + (1:floor(sz(1)*scale)) - floor(sz(1)*scale/2);
	
	%check for out-of-bounds coordinates, and set them to the values at
	%the borders
	xs(xs < 1) = 1;
	ys(ys < 1) = 1;
	xs(xs > size(im,2)) = size(im,2);
	ys(ys > size(im,1)) = size(im,1);
	
	%extract image
	out = imresize(im(ys, xs, :),[sz(1) sz(2)]);

end

