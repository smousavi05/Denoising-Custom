% [g Dvec up nd] =  vertSec(row,data);
%
% this function finds an estimate of arrival times associated with highy energy 
% arrivals (onset time). 
% 
% [INPUTS]
% row: is the characterisics function DF (eq. 15).
% data: a structuer containing waveform's info.
%
% [OUTPUTS]
% g: a structure containing segmented CWT coefficients of main features.
% Dev: a structure containing ifo about strong energy arrivals
% up:
% nd:
% -------------------------------------------------------------------------
% By Mostafa Mousavi, smousavi@memphis.edu 
% Last modify: Oct 2, 2016
% -------------------------------------------------------------------------

function [g Dvec up nd] =  vertSec(row,data)

   xr = smooth(row,0.01,'loess');
   g=f_cumul(xr);
   
   Dvec = movingslope(g,2,1,data.dt);
   Dvec = Dvec - 0.1*max(Dvec); 
%       Dvec = Dvec - mean(Dvec); 
   Dvec(Dvec < 0 )= 0;
   [up nd] = araivEst(Dvec);
