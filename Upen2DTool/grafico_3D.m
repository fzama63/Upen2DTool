%##########################################################################
%Name    : grafico_3D
%Changes : 1.1 [03/05/2019] (vb) Changed the name of the script.
%        : 1.2 [25/07/2019] (fz) increased font  and line size.
%        Trasparent mesh.
%Date    : 
%##########################################################################
function grafico_3D(X,tauv,tauh, FL_typeKernel,  Titolo)
    fig=figure;
    set(gcf,'Renderer','zbuffer');
    set(fig,'DoubleBuffer','on');
    set(gca,'NextPlot','replace','Visible','off')
    taulh = log10(tauh);
    sta = size(taulh);
    taulv = log10(tauv);
    stb = size(taulv);
    [XT1,XT2]=meshgrid(taulh,taulv);
    s=surf(XT1,XT2,X);alpha(s,'z');set(gca,'FontSize',12,'fontweight','bold')
    axis('tight')
    if (FL_typeKernel==1 || FL_typeKernel==2)
      xlabel('Log_{10}(T_2)  [T_2 in ms]'); 
      ylabel('Log_{10}(T_1)  [T_1 in ms]'); 
     elseif FL_typeKernel==3
      xlabel('Log_{10}(T_2)  [T_2 in ms]'); %
      ylabel('Log_{10} D (\mum^2/ms)'); %
     elseif FL_typeKernel==4
      xlabel('Log_{10}(T_{22})'); 
      ylabel('Log_{10}(T_{21})'); 
    end
    title(Titolo);
  return;
end   