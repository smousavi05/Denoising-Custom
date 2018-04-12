% [x] = SoftThresh(y,t);
%
% Apply Soft Threshold 
% 
% [INPUTS]
%  y: Noisy Data 
%  t: Threshold
%
% [OUTPUTS]
%  x: sign(y)(|y|-t)_+. 
% -------------------------------------------------------------------------
% By Mostafa Mousavi, smousavi@memphis.edu 
% Last modify: Oct 2, 2016
% -------------------------------------------------------------------------

function [x] = SoftThresh(y,t)
	res = (abs(y) - t);
	res = (res + abs(res))/2;
	x   = sign(y).*res;
