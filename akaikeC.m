% [AICd] = akaikeC(col)
%
% this function calculates Akaike's information criteria
% 
% [INPUTS]
% col: stacked CWT coefficients along each scale. 
%
% [OUTPUTS]
% AICd: the Akaike's information criteria
% 
% [REFERENCE]
% Akaike, H., 1974, A new look at the statistical model identification: 
% IEEE Transactions on Automatic Control, 19, 716?723, doi:
% 10.1109/TAC.1974.
% -------------------------------------------------------------------------
% By Mostafa Mousavi, smousavi@memphis.edu 
% Last modify: Oct 2, 2016
% -------------------------------------------------------------------------

function [AICd] = akaikeC(col)
f1 = gmdistribution.fit(col,1);
f2 = gmdistribution.fit(col,2);
AICd = (f1.AIC-f2.AIC)/max([f1.AIC,f2.AIC]);