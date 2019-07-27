%###################################################################################################
%NAME    : grad_proj_noreg.m
%PURPOSE : Projected Gradient Method.
%DATE    :
%VERSION : 1.1 [03/01/2016](vb) Minor changes.
%          1.2 [12/07/2017](vb) Changed use of parameter structure.   
%NOTES   :
%###################################################################################################
function [x, k, norma_grad]=grad_proj_noreg(Kc,Kr,s, lb, x0, par)
 % set up tolerances
 tol=par.gpnr.tol;
 maxk=par.gpnr.maxiter;
 %%STEP 1 (initialization)
 x = max(x0,lb);
 [nx,ny] = size(x0);
 alpha_min=1E-10; 
 alpha_max=1E10; 
 alpha=1;        
 % Gradient of the objective function
 temp = Kc*x*Kr'-s; 
 res = temp;
 grad=Kc'*temp*Kr;   %A'(Ax-b) 
 norma_res(1)=norm(res(:)); % gradient norm
 k=1; 
 continua = 1;
 while continua
    %STEP 2 
    d=max(x-alpha*grad,lb)-x;
    %STEP 3
    temp = Kc*d*Kr'; temp=Kc'*temp*Kr;
    Ad = temp;
    if norm(Ad(:))>eps*norm(d(:))
        lambda=min(-(grad(:)'*d(:))/(d(:)'*Ad(:)), 1);     
    else
        lambda=1;
    end
    x=x+lambda*d;
    grad=grad+lambda*Ad;
    res = Kc*x*Kr'-s;
    %STEP 4
    if norm(Ad(:))>eps*norm(d(:))
        if mod(k, 6)<3    
            alpha=(d(:)'*Ad(:))/(Ad(:)'*Ad(:));
        else
            alpha=(d(:)'*d(:))/(d(:)'*Ad(:));
        end
        alpha=max(alpha_min,min(alpha_max, alpha));
    else
        alpha=alpha_max;
    end
    k=k+1;
    norma_grad(k)=norm(grad(:));  
    norma_res(k)=norm(res(:)); 
    continua = k<maxk && abs(norma_res(k)-norma_res(k-1))>=tol;
 end  
 return;
end

