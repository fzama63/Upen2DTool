%###################################################################################################
%NAME    :get_dif.m
%PURPOSE : Compute Divergence and Laplacian Matrices
%DATE    :
%VERSION :1.1 [03/01/2016](vb) Cosmetic changes.                
%NOTES   :
%###################################################################################################
function [L1nx,L1ny,L2] = get_diff(nx,ny,hx,hy)
  if nargin == 2
    hx=1; hy=1;
  end
  % Divergence
  D1nx = get_l(nx+1,1)/hx; D1nx = D1nx(:,1:end-1); 
  D1ny = get_l(ny+1,1)/hy; D1ny = D1ny(:,1:end-1); 
  L1nx=kron(D1ny,speye(nx)); L1ny=kron(speye(ny),D1nx);
  % Laplacian 
  D2n = get_l(nx+2,2)/hx^2; D2n = D2n(:,2:end-1); D2n(1,1)=-1/hx^2;  D2n(nx,nx)=-1/hx^2;
  D2m = get_l(ny+2,2)/hy^2; D2m = D2m(:,2:end-1); D2m(1,1)=-1/hy^2;  D2m(ny,ny)=-1/hy^2;
  L2 = kron(D2m,speye(nx))+kron(speye(ny),D2n);
  return;
end