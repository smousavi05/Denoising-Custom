% [x = HardThresh(y,t);
% Apply Hard Threshold  
% 
% [INPUTS]
%  y: Noisy Data 
%  t: Threshold
%
% [OUTPUTS]
%  x: y 1_{|y|>t} 
% -------------------------------------------------------------------------
% By Mostafa Mousavi, smousavi@memphis.edu 
% Last modify: Oct 2, 2016
% -------------------------------------------------------------------------

function x = HardThresh(y,t)
	x   = y .* (abs(y) > t);


