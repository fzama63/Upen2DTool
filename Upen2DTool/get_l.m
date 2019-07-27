%###################################################################################################
%NAME    :get_l.m
%PURPOSE :Discrete derivative operator.
%         Computes the discrete approximation L to the derivative operator
%         of order d on a regular grid with n points, i.e. L is (n-d)-by-n.
%         L is stored as a sparse matrix.
%DATE    :
%VERSION :1.1 [03/01/2016](vb) Minor changes.
%NOTES   :
%###################################################################################################
function [L] = get_l(n,d)
  % Initialization.
 if (d<0), error ('Order d must be nonnegative'), end
 % Zero'th derivative.
 if (d==0), L = speye(n); W = zeros(n,0); return, end
 % Compute L.
 c = [-1,1,zeros(1,d-1)];
 nd = n-d;
 for i=2:d, c = [0,c(1:d)] - [c(1:d),0]; end
 L = sparse(nd,n);
 for i=1:d+1
   L = L + sparse(1:nd,(1:nd)+i-1,c(i)*ones(1,nd),nd,n);
 end
 return;
end