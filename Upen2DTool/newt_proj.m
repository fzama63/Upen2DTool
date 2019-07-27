%##########################################################################
%
% NAME    : newt_proj.m
% PURPOSE : Projected Newton's Method  
% VERSION : 0.1  
% SYNTAX  :  [x, k, it_cg]=newt_proj(Kc,Kr,ck,b,L2,x0, par_nwt,par_cg)
%             
% INPUT   Kc  = Column Kernel
%         Kr  = Row Kernel
%         ck  = Upen Regularization Parameters   
%         b   = Data Matrix
%         L2  = Discrete Laplacian Matrix
%         par_nwt = Projected Newton's iteration parameters 
%                   par_nwt.maxiter : Maximum iterations number
%                   par_newt.tolrho : Relative Tolerance of Objective Function
%         par_cg  = Conjugate Gradients iterations parameter
%                   par_cg.pcg_max : Maximum iterations number
%                   par_cg.pcg_tol : Relative Residual Tolerance 
%             
% OUTPUT  x = Final Solution
%         k = Number of Newton's steps
%         it_cg = Number of Inner Conjugate Gradient steps
%
% DATE    : 17/7/2018 
% NOTES   : 
%##########################################################################
function [x, k, it_cg]=newt_proj(Kc,Kr,ck,b,L2,x0,par_nwt,par_cg)
 % set up tolerance values
 maxk = par_nwt.maxiter;
 tolrho = par_nwt.tolrho;
 % Active set parameter
 psi = 1E-10;
 % line search parameter
 maxarm = 40;
 eta=1.E-4;
 % Initialize
 x = max(x0,0);
 [nx,ny] = size(x0);
 % Compute objective and gradient
 temp = Kc*x*Kr'-b; 
 temp1 = L2*x(:).*ck(:); temp1 = L2'*temp1;
 grad = Kc'*temp*Kr+reshape(temp1,nx,ny);
 objf = 0.5*(norm(temp(:))^2+x(:)'*temp1);
 k=0; eflag = 1;  continua = 1;it_cg=0;
 while continua
    k=k+1;
    % Evaluate "active set"
    wk = norm( x-max(0,x-grad),'fro' ); epsilonk = min([psi; wk]);
    Ik = ( x<=epsilonk & grad>0 ); %''Active set''
    % Compute descent direction
    [d,iter] = cg2dn(Ik,Kc,Kr,L2,ck,-grad,par_cg,[]); 
    it_cg=it_cg+iter;
    % Constrained line search
    alpha = 1; iarm = 1; 
    xt = max(x + alpha*d,0);
    temp = Kc*xt*Kr'-b; 
    temp1 = L2*xt(:).*ck(:); temp1 = L2'*temp1;
    objft = 0.5*(norm(temp(:))^2+xt(:)'*temp1);
    stept = alpha * d;
    stept(Ik) = -( x(Ik) - xt(Ik) );
    while objft >= objf+eta*grad(:)'*stept(:) && iarm <= maxarm 
        alpha = alpha * 0.5;
        xt = max(x + alpha*d,0);
        temp = Kc*xt*Kr'-b; 
        temp1 = L2*xt(:).*ck(:); temp1 = L2'*temp1;
        objft = 0.5*(norm(temp(:))^2+xt(:)'*temp1);
        stept = alpha * d;
        stept(Ik) = -( x(Ik) - xt(Ik) );
        iarm = iarm+1;
        if iarm > maxarm
            eflag = 0; %% *** Armijo failure ***
        end
    end  % end line search
    % Update
    x = xt; 
    rho=(objf-objft)/objft; % relative increment in the objective
    objf = objft;
    grad = Kc'*temp*Kr+reshape(temp1,nx,ny);
    continua = k<maxk && eflag == 1 && rho>tolrho;
 end
end
   
