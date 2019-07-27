%########################################################################################
%   NAME    : UPen2D.m
%   PURPOSE : The Upen 2D algorithm.
%   DATE    :25/11/2015 
%   VERSION :1.1 [03/01/2016] (vb) Modified some figure title and labels,
%                                and cosmetic changes.  
%            1.2 [29/04/2016] (fg) Added weight B and SVD filter
%            1.3 [07/07/2017] (vb) Possibility to exclude the use of the matrix B.
%            1.4 [12/07/2017] (vb) Changed the use of parameter structure.
%            1.5 [15/07/2017] (vb) Changed plot svd.
%            1.6 [02/11/2017] (fz) Changed computation number iteration, Changed 
%                                  the Kronecker product.
%   NOTES   : 
%########################################################################################
function [x,ck,hist]=UPEN2D(Kc,Kr,s,T1,T2,par,FL_typeKernel)
 Tol = par.upen.tol;
 Kmax = par.upen.iter;
 beta_00 = par.upen.beta00;
 beta_p  = beta_00*par.upen.beta_p; 
 beta_c  = beta_00*par.upen.beta_c;
 beta_0  = par.upen.beta0;
 %-------------------------------------------------------------------------
 res=zeros(par.nwtp.maxiter,1);
 t_in=cputime;
 B=par.upen.B;
 Kr=B*Kr;
 s=eye(size(s,1))*s*B;
 if par.svd.svd
   %--------------------------------------------------------------------------
   soglia=par.svd.soglia;
   [Uc,Sc,Vc]=svd(Kc); Sc=diag(Sc);hist.Sc=Sc;
   [Ur,Sr,Vr]=svd(Kr); Sr=diag(Sr);hist.Sr=Sr;
   %
   if soglia < min(Sc)
     nc=length(Sc);
    else
     nc=find(Sc<=soglia,1);
   end
   if soglia < min(Sr)
     nr=length(Sr);
    else
     nr=find(Sr<=soglia,1);
   end
   if par.VERBOSE
      figure; 
      semilogy(1:numel(Sc),Sc,'or',1:numel(Sr),...
               Sr,'+b',1:max(numel(Sc),numel(Sr)),soglia*ones(max(numel(Sc),numel(Sr)),1),'-k');
      legend('\sigma_c','\sigma_r','Threshold');
      ylabel(' Singular Values of matrices Kc and Kr');
      xlabel(' Number of Singular Values');
   end
   %--------------------------------------------------------------------------
   Uc=Uc(:,1:nc); 
   Ur=Ur(:,1:nr); Sr=Sr(1:nr);
   s=Uc'*s*Ur;
   Kc=Uc'*Kc;
   Kr=Ur'*Kr;
 end
 nx = size(Kc,2);
 ny = size(Kr,2);
 [N_T1,N_T2]=size(s);
 [L1nx,L1ny,L2] = get_diff(nx,ny); 
 %
 IT_cg=0;IT_newt=0;
 [x0, iter]=grad_proj_noreg(Kc,Kr,s,0, zeros(nx,ny), par); 
 x=x0; IT_cg=IT_cg+iter;
 res(1) = norm(Kc*x*Kr'-s,'fro');
 Rsqrd = res(1)^2;
 %
 if par.VERBOSE
    % peak
    [~,iy] = max(max(x));
    [~,ix] = max(max(x'));
    picco = x(ix,iy);
    M_picco=x(max(ix-5,1):min(ix+5,nx),max(iy-5,1):min(iy+5,ny)); Perc=100*sum(M_picco(:))/sum(x(:));
    fprintf('UPEN GP Init. - T2=%0.2f T1=%0.2f peak=%0.2f  PercTot=%0.2f  (inner its= %d) \n',T2(iy),T1(ix),picco,Perc,iter);
    fprintf('UPEN GP Init. -    (T2= %0.2f %0.2f %0.2f, T1 = %0.2f %0.2f %0.2f) \n',T2(iy-1),T2(iy),T2(iy+1),T1(ix-1),T1(ix),T1(ix+1));
    Titolo=['UPEN GP Init. - iter= 0  T2(' num2str(iy) ')=' num2str(T2(iy),'%0.2f') ...
        ' T1(' num2str(ix) ')=' num2str(T1(ix),'%0.2f') ' peak=' num2str(picco,'%0.2f')];
    figure(1); flip_imagesc_new(x,T1,T2,Titolo,1,FL_typeKernel); %
    figure(2); surf(x); title('UPEN GP Init - iter=0'); 
    analisi_T1=sum(x,2);
    analisi_T2=sum(x,1);
    figure(3);
    subplot(211); semilogx(T1,analisi_T1); axis([T2(1) T1(end) min(analisi_T1) max(analisi_T1)]);
    xlabel('T1 (ms)'); ylabel('Probability Density (u.a.)') 
    Titolo='UPEN GP Init. - T1 and T2 results';
    title(Titolo);
    figure(3); subplot(212); semilogx(T2,analisi_T2); axis([T2(1) T2(end) min(analisi_T2) max(analisi_T2)]);
    xlabel('T2 (ms)'); ylabel('Probability Density (u.a.)')
 end
 % 
 c = reshape(L2*x(:),nx,ny); 
 c = ordfilt2(abs(c),9,ones(3));
 px = L1nx*x(:);
 % 
 py = L1ny*x(:); 
 v = sqrt(px.^2+py.^2);
 p = reshape(v,nx,ny);
 p = ordfilt2(p,9,ones(3));
 Rsqrd =Rsqrd/(N_T1*N_T2);
 beta_0 = beta_0*Rsqrd; 
 ck = (Rsqrd)./(beta_0+beta_p*p.^2+beta_c*c.^2); 
 %
 if par.VERBOSE
    figure;imagesc(c.^2); title('c');colorbar; 
    figure;imagesc(p.^2); title('p');colorbar; 
 end
 continua = 1; i=1;
 while continua
    xold = x;
    [x, iter,it_cg]=newt_proj(Kc,Kr,ck,s,L2,x, par.nwtp,par.cgn2d); 
    IT_newt=IT_newt+iter;
    IT_cg=IT_cg+it_cg;
    c = reshape(L2*x(:),nx,ny); 
    c = ordfilt2(abs(c),9,ones(3));
    px = L1nx*x(:); 
    py = L1ny*x(:); 
    v = sqrt(px.^2+py.^2);
    p = reshape(v,nx,ny);
    p = ordfilt2(p,9,ones(3));
    res(i) = norm(Kc*x*Kr'-s,'fro');
    Rsqrd = res(i)^2; 
    Rsqrd =Rsqrd/(N_T1*N_T2);
    ck = ((Rsqrd)./(beta_0+beta_p*p.^2+beta_c*c.^2));     
    if par.VERBOSE
        [~,iy] = max(max(x));[~,ix] = max(max(x'));picco = x(ix,iy);
        M_picco=x(max(ix-5,1):min(ix+5,nx),max(iy-5,1):min(iy+5,ny)); Perc=100*sum(M_picco(:))/sum(x(:));
        fprintf('UPEN - T2=%0.2f T1=%0.2f peak=%0.2f  PercTot=%0.2f  (inner its= %d) \n',T2(iy),T1(ix),picco,Perc,iter);
        fprintf('UPEN -    (T2= %0.2f %0.2f %0.2f, T1 = %0.2f %0.2f %0.2f) \n',T2(iy-1),T2(iy),T2(iy+1),T1(ix-1),T1(ix),T1(ix+1));
        Titolo=['UPEN - iter= ' num2str(i) ' T2(' num2str(iy) ')=' num2str(T2(iy),'%0.2f') ...
            ' T1(' num2str(ix) ')=' num2str(T1(ix),'%0.2f') ' peak=' num2str(picco,'%0.2f')];
        figure(4); flip_imagesc_new(x,T1,T2,Titolo,1,FL_typeKernel);
        figure(5); surf(x); title(['UPEN - iter= ' num2str(i)]); 
        analisi_T1=sum(x,2); analisi_T2=sum(x,1);
        figure(6)
        subplot(211); semilogx(T1,analisi_T1); axis([T2(1) T1(end) min(analisi_T1) max(analisi_T1)]);
        xlabel('T1 (ms)'); ylabel('Probability Density (u.a.)')
        Titolo=['iter= ' num2str(i) '  UPEN - T1 and T2 results'];
        title(Titolo);
        figure(6); subplot(212); semilogx(T2,analisi_T2); axis([T2(1) T2(end) min(analisi_T2) max(analisi_T2)]);
        xlabel('T2 (ms)'); ylabel('Probability Density (u.a.)')
    end
    i = i+1;
    X_rel= norm(x-xold,'fro')/norm(x,'fro');
    continua = X_rel> Tol && i<Kmax;
 end
 if X_rel > Tol
     fprintf('Warning! Maximum upen iteration number reached:\n relative solution distance = %e  iterations= %d \n',X_rel,i);
 end
 hist.ssize=[N_T1,N_T2];
 hist.upen_iter=i-1;
 hist.res = res(1:i-1);
 hist.kcg = IT_cg;
 hist.k_nwt=IT_newt;
 hist.Tempo=(cputime-t_in);
end
