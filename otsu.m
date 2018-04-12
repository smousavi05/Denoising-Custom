%  [idx] = otsu(na,col);
%
% this function find an optimal scale value to separate long period features 
% from high-frequency features.
%
% [INPUTS]
% na: number of scales in the CWT picture.
% col: stacked CWT coefficients along each scale. 
%
% [OUTPUTS]
% idx: optimal scale for segmentation. 
%
% [Reference]
% N. Otsu, "A Threshold Selection Method from Gray-Level Histograms,"
% IEEE Transactions on Systems, Man, and Cybernetics, vol. 9, no. 1,
% pp. 62-66, 1979.
%
% -------------------------------------------------------------------------
% Mostafa Mousavi, smousavi@memphis.edu 
% Last modify: Oct 2, 2016
% -------------------------------------------------------------------------

function  [idx] = otsu(na,col)

x = na; 
counts = col(:);
 
% Variables names are chosen to be similar to the formulas in
% the Otsu paper.
p = counts / sum(counts);
omega = cumsum(p);
mu = cumsum(p .* (1:x)');
mu_t = mu(end);
 
sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));
 
% Find the location of the maximum value of sigma_b_squared.
  % The maximum may extend over several bins, so average together the
  % locations.  If maxval is NaN, meaning that sigma_b_squared is all NaN,
  % then return 0.
  maxval = max(sigma_b_squared);
  isfinite_maxval = isfinite(maxval);

    idx = mean(find(sigma_b_squared == maxval));




