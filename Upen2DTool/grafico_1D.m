%#####################################################################################
%Name    : grafico_1D
%Changes : 1.1 [03/05/2019] (vb) Changed the name of the script.
%        : 1.2 [25/07/2019] (fz) increased font  and line size.
%NOTES   :[13/12/2017] (vb) Derived from grafico_1(x,T1,T2,method, FL_typeKernel)
%#####################################################################################
function grafico_1D(x,T1,T2,metodo, FL_typeKernel)
 [nx,ny]=size(x);
 % peak
 [~,iy] = max(max(x));
 [~,ix] = max(max(x'));
 picco = x(ix,iy);
 M_picco=x(max(ix-5,1):min(ix+5,nx),max(iy-5,1):min(iy+5,ny)); 
 Perc=100*sum(M_picco(:))/sum(x(:));
 analisi_T1=sum(x,2);
 analisi_T2=sum(x,1);
 figure;
 semilogx(T1,analisi_T1,'LineWidth',1.5);grid on
 set(gca,'FontSize',12,'fontweight','bold')
 axis([T1(1) T1(end) min(analisi_T1) max(analisi_T1)]);
 if (FL_typeKernel==1 || FL_typeKernel==2)
      xlabel('T_1  (ms)');
  elseif FL_typeKernel==3
      xlabel('D (\mum^2/ms)'); %
  elseif FL_typeKernel==4
      xlabel('T_{21}  (ms)'); 
 end
 ylabel('Intensity (a.u.)'); 
 title(metodo);
 figure; semilogx(T2,analisi_T2,'LineWidth',1.5); 
 set(gca,'FontSize',12,'fontweight','bold')
 axis([T2(1) T2(end) min(analisi_T2) max(analisi_T2)]);grid on
  if (FL_typeKernel==1 || FL_typeKernel==2)
      xlabel('T_2  (ms)'); 
  elseif FL_typeKernel==3
      xlabel('T_2  (ms)'); %
  elseif FL_typeKernel==4
      xlabel('T_{22}  (ms)'); 
 end
 ylabel('Intensity (a.u.)');
 title(metodo);
 return;
end
