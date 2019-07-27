%###############################################################################
%Name    : grafico_2D
%Changes : 1.1 [03/05/2019] (vb) Changed the name of the script.
%        : 1.2 [25/07/2019] (fz) increased font  and line size. Changes input
%        parameters for contour/2D map
%Date    : 
%###############################################################################
function grafico_2D(X,tauv,tauh,numline, FL_typeKernel, Titolo)
    fig=figure;
    %axes('FontSize',13,'fontweight','bold');
    set(gcf,'Renderer','zbuffer');
    set(fig,'DoubleBuffer','on');
    set(gca,'NextPlot','replace','Visible','off')
    taulh = log10(tauh);
    sta = max(size(taulh));
    taulv = log10(tauv);
    stb = max(size(taulv));
    if numline
       contour(taulh,taulv',X,numline,'LineWidth',1.5);grid on ;  
     else
      surf(taulh,taulv',X);grid on
    end
    caxis('auto');
    shading interp;set(gca,'FontSize',12,'fontweight','bold')
    axis([taulh(1),taulh(sta),taulv(1),taulv(stb)]);
    colorbar;
    if (FL_typeKernel==1 || FL_typeKernel==2)
      xlabel('Log_{10}(T_2)  [T_2 in ms]'); 
      ylabel('Log_{10}(T_1)  [T_1 in ms]');
     elseif FL_typeKernel==3
      xlabel('Log_{10}(T_2)  [T_2 in ms]'); %
      ylabel('Log_{10} D (\mum^2/ms)'); %
     elseif FL_typeKernel==4
      xlabel('Log_{10}(T_{22})  [T_{22} in ms]'); 
      ylabel('Log_{10}(T_{21})  [T_{21} in ms]'); 
    end
    title(Titolo);
  return;
end   