function [height, scale] = scale_estimation(theta, x, y, x0, y0, h0)
height =  h0 *((theta(1)*x + theta(2)*y + theta(3))/(theta(1)*x0 + theta(2)*y0 + theta(3)));
scale = height/h0;
end