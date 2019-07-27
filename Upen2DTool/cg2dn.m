%##########################################################################
% NAME    :cg2dn.m
% PURPOSE : Conjugate Gradient Method for 2D data
% SYNTAX : [u_mat,pcgiter] = cg2dn(F,Kc,Kr,L2,ck,b_mat,par,u0)
%             
% INPUT   F   = Active set
%         Kc  = Column Kernel
%         Kr  = Row Kernel
%         ck  = Upen Regularisation Parameters   
%         L2  = Discrete Laplacian Matrix
%         b_mat = r.h.s.
%         par  = Conjugate Gradients iterations parameter
%                   par.pcg_max : Maximum iterations number
%                   par.pcg_tol : Relative Residual Tolerance 
%         u0 = Starting guess
%             
% OUTPUT  u_mat   = Final Solution 
%         pcgiter = Number of steps
%
%
% DATE    : 17/7/2018                
% VERSION : 0.1 
%
%##########################################################################
%  
function [u_mat,pcgiter] = cg2dn(F,Kc,Kr,L2,ck,b_mat,par,u0)
  [nx,ny]=size(b_mat); 
  pcg_max = par.maxiter;
  pcg_tol = par.tol;
  E=1-F;
  if isempty(u0)
      u_mat = zeros(size(b_mat));
      resid_mat = b_mat;
  else 
      u_mat=u0;
      temp = Kc*(E.*u_mat)*Kr'; 
      temp1 = L2*(E(:).*u_mat(:)).*ck(:); temp1 = L2'*temp1;
      resid_mat =E.*( Kc'*temp*Kr+reshape(temp1,nx,ny))+F.*u_mat;
  end
  pcgiter = 0;
  residrat = norm(resid_mat(:));
  pcg_tol = pcg_tol*norm(resid_mat(:));
  while (pcgiter < pcg_max && residrat > pcg_tol)
    pcgiter = pcgiter + 1;
    d_mat = resid_mat;
    rd = resid_mat(:)'*d_mat(:);
    if pcgiter == 1
       p_mat = d_mat; 
    else
       betak = rd / rdlast;
       p_mat = d_mat + betak * p_mat;
    end
    temp = Kc*(E.*p_mat)*Kr'; 
    temp1 = L2*(E(:).*p_mat(:)).*ck(:); temp1 = L2'*temp1;
    Ap_mat =E.*( Kc'*temp*Kr+reshape(temp1,nx,ny))+F.*p_mat;
    alphak = rd / (p_mat(:)'*Ap_mat(:));
    u_mat = u_mat + alphak*p_mat;
    resid_mat = resid_mat - alphak*Ap_mat;
    rdlast = rd;
    residrat = norm(resid_mat(:));
  end
end

