% Function that calculate the positive gradient cumulative of f
% if the gradient is positive we take the cumulative, if the gradient is
% negative then, as long as the gradient is negative, the value is the one of
% the last positive gradient. 
% 
% [INPUTS]
% f: matrix or array containing the data. 
%
% [OUTPUTS]
% g: cumulative output matrix. 
% -------------------------------------------------------------------------
% Mostafa Mousavi, smousavi@memphis.edu 
% Last modify: Oct 2, 2016
% -------------------------------------------------------------------------
function [g,p]=f_cumul(f)

m=size(f,1); 
n=size(f,2);
inp=f;
inp(isnan(f))=0;

grad_f=diff(inp,1,1);
grad_f=[zeros(1,n);grad_f]; % To homogeneise the size of grad_f and f
grad_f(grad_f<0)=0;         % We only cumulate the positive gradients

g=cumsum(grad_f,1);
p=g;
p(isnan(f))=NaN;

corr_mat=ones(1,n);
g(isnan(f))=NaN;

for i=1:n
    clear ind
    ind=find(~isnan(g(:,i)),1,'first');
    if isempty(ind)
        corr_mat(i)=1;
    else
        corr_mat(i)=g(ind,i);
    end
end

g=g-ones(m,1)*corr_mat;

end