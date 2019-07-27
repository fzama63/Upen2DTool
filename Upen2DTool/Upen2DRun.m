%########################################################################################
%NAME    : Upen2DRun.m
%PURPOSE : The main script for running the Upen2D algorithm.
%VERSION : 1.0 [15/04/2019]
%INPUT   : Test_Folder : folder containing data and parameters files.           
%OUTPUT  :            
%NOTES   : 
%########################################################################################
function Upen2DRun(Test_Folder)
 Test_Folder=[Test_Folder '/'];
 Data_Folder=['./DATA/' Test_Folder];addpath(Data_Folder);
 Out_folder='./output_files/';addpath(Out_folder);
 %-------------------------------------------------------------------------
 NameFileFlags=[Data_Folder 'FileFlag.par'];
 NameFileSetInput=[Data_Folder 'FileSetInput.par'];
 NameFilePar=[Data_Folder 'FilePar.par'];
 %
 %########################## Declaration parameter strucuture ###########################
 % creates a 1-by-1 structure with no fields.
 par=struct;
 parFile=struct;
 %
 [parFile]=SetInputFile(NameFileSetInput, parFile, 0);
 %############################### FLag parameters #######################################
 % FL_typeKernel=1;          %1 IR-CPMG; 4 T2-T2
 % FL_InversionTimeLimits=0; %1 automatic, 0 manually selection inversion time ranges 
 % FL_OutputData=0;          %1 create output data file for ILT2D
 %
 % load flag fom file
 [CommentS, FL_typeKernel, FL_InversionTimeLimits, ...
      FL_OutputData, FL_NoContour, FL_Verbose]= LoadFlags(NameFileFlags,0);  
 %
 %#################################### Load Data Set ####################################
 %
 [CommentTS, N_T1, N_T2, Tau1, Tau2, s] = LoadData(parFile.filenamedata, parFile.filenameTimeY,parFile.filenameTimeX);
 %scale_fact=1E3;
 %Amp_scale=1E4;
 scale_fact=1.0E0;
 Amp_scale=1.0E0;
 B=eye(size(s,2)); %now not used, for future implementation   
 %###################################### Set problem dimension ############################
 nx=parFile.nx;
 ny=parFile.ny;
 N=nx*ny;
 %
 %######################## Set times of the inversion channels ############################
 %Set times of the inversion channels. Two modalities: automatic setting or fixed setting.
 %Times in milliseconds
 if(FL_InversionTimeLimits==1)
   Tau1=scale_fact*Tau1;
   Tau2=scale_fact*Tau2;
   q1 = exp((1/(nx-1))*log(4*Tau1(end)/(0.25*Tau1(1))));
   T1 = 0.25*Tau1(1)*q1.^(0:nx-1);
   q2 = exp((1/(ny-1))*log(4*Tau2(end)/(0.25*Tau2(1))));
   T2 = 0.25*Tau2(1)*q2.^(0:ny-1);
 else
   T1min=parFile.T1min;
   T1max=parFile.T1max;
   T2min=parFile.T2min;
   T2max=parFile.T2max;
   q1 = exp((1/(nx-1))*log(T1max/T1min));
   T1 = T1min*q1.^(0:nx-1);
   q2 = exp((1/(ny-1))*log(T2max/T2min));
   T2 = T2min*q2.^(0:ny-1);
 end
 %
 if FL_OutputData
  if(FL_typeKernel == 1)
    dlmwrite([Out_folder 't_1.txt'],Tau1,'delimiter','\t','precision',5, 'newline', 'pc');
    dlmwrite([Out_folder 't_2.txt'],Tau2,'delimiter','\t','precision',5, 'newline', 'pc');
    dlmwrite([Out_folder 'T1.txt'],T1','delimiter','\t','precision',5, 'newline', 'pc');
    dlmwrite([Out_folder 'T2.txt'],T2','delimiter','\t','precision',5, 'newline', 'pc');
  elseif(FL_typeKernel==4)
    dlmwrite([Out_folder 't_1.txt'],Tau1,'delimiter','\t','precision',5, 'newline', 'pc');
    dlmwrite([Out_folder 't_2.txt'],Tau2,'delimiter','\t','precision',5, 'newline', 'pc');
    dlmwrite([Out_folder 'T1.txt'],T1','delimiter','\t','precision',5, 'newline', 'pc');
    dlmwrite([Out_folder 'T2.txt'],T2','delimiter','\t','precision',5, 'newline', 'pc');
  end
 end
 %
 %
 %############################# Set the Kernel #######################################
 if (FL_typeKernel==1)
   [Kernel_1,Kernel_2] = T1_T2_Kernel;
 elseif(FL_typeKernel==4)
   [Kernel_1,Kernel_2] = T2_T2_Kernel;
 end
 Kc = Kernel_1 (Tau1,T1); 
 Kr = Kernel_2(Tau2,T2);
 %
 %############################# Set the Parameter structure ##########################
 [par]=SetPar(NameFilePar,s, B, par,0);
 par.VERBOSE=FL_Verbose;
 %
 % -------------------------------------------------------------------------
 % UPEN 2d
 % -------------------------------------------------------------------------
 %
 [x,ck,hist]=UPEN2D(Kc, Kr, s, T1, T2, par, FL_typeKernel);
 %
 Res_vec=Kc*x*Kr'-s;%
 Res_final = norm(Res_vec,'fro')/norm(s,'fro');
 %
 %[vb - 11/10/2017] export distribution computed and parameters
 map_file=[Out_folder '2D_Distribution.txt'];
 fprintf('\n Final map File: %s \n',map_file);
 dlmwrite(map_file,x,'delimiter','\t','precision','%0.13e', 'newline', 'pc');
 % 
 final_data=[Out_folder 'Parameters.txt'];
 fprintf('\n Final Parameters file: %s \n\n',final_data);
 fp=fopen(final_data,'w');
   fprintf(fp,'--------------------------------------------------------------------------------------------------------- \n');
   fprintf(fp,'UPen2D Input Parameters \n upen_tol=%e,\n Projected Gradient Tol =%e \n Projected Newton Tol=%e \n Conjugate Gradient Tol =%e\n',...
           par.upen.tol,par.gpnr.tol,par.nwtp.tolrho, par.cgn2d.tol);    
   fprintf(fp,'SVD Threshold =%0.0e \n   Data size= %d x %d  \n',par.svd.soglia,hist.ssize(1),hist.ssize(2));
   fprintf(fp,'---------------------------------------------------------------------------------------------------------');
   fprintf(fp,'\r\n');
   fprintf(fp,'Number of Inversion channels:  horizontal %d, vertical  %d \n', ny, nx);   
   fprintf(fp,'Final Relative Residual Norm =%0.4e \r\n', Res_final);
   fprintf(fp,'Total UPen2D Iterations = %d',hist.upen_iter);
   fprintf(fp,'\r\n');
   fprintf(fp,'Total CG Iterations = %d ', hist.kcg);
   fprintf(fp,'\r\n');
   fprintf(fp,'Total Projected Newton Iterations = %d ', hist.k_nwt);
   fprintf(fp,'\r\n');
   fprintf(fp,'Computation Time = %4.5f s.',hist.Tempo);
   fprintf(fp,'\r\n');
   fprintf(fp,'---------------------------------------------------------------------------------------------------------\n');
 fclose(fp);   
 %
 dlmwrite([Out_folder 'residual.txt'],Res_vec,'delimiter','\t','precision','%0.13e', 'newline', 'pc');
 %
 grafico_1D(x,T1,T2, '1D Distribution', FL_typeKernel);
 grafico_2D(x,T1,T2,FL_NoContour ,FL_typeKernel, '2D Map');
 grafico_3D(x,T1,T2,FL_typeKernel, '3D Distribution');
 %
 % peak
 [~,iy] = max(max(x)); [~,ix] = max(max(x')); picco = x(ix,iy);
 %(vb)[07/07/2017]
 if (ix<=1) ix=2; end; if (iy<=1) iy=2; end
 if (ix>=nx) ix=nx-1; end; if (iy>=ny) iy=ny-1; end
 M_picco=x(max(ix-5,1):min(ix+5,nx),max(iy-5,1):min(iy+5,ny)); Perc=100*sum(M_picco(:))/sum(x(:));
 if (FL_typeKernel==1)
   fprintf(fp,'UPen2D - T2=%0.2f T1=%0.2f peak=%0.2f  PercTot=%0.2f  \n',T2(iy),T1(ix),picco,Perc);
   fprintf(fp,'UPen2D - (T2= %0.2f %0.2f %0.2f, T1 = %0.2f %0.2f %0.2f) \n',T2(iy-1),T2(iy),T2(iy+1),T1(ix-1),T1(ix),T1(ix+1));
 elseif (FL_typeKernel==4)
   fprintf(fp,'UPen2D - T22=%0.2f T21=%0.2f peak=%0.2f  PercTot=%0.2f  \n',T2(iy),T1(ix),picco,Perc);
   fprintf(fp,'UPen2D - (T22= %0.2f %0.2f %0.2f, T21 = %0.2f %0.2f %0.2f) \n',T2(iy-1),T2(iy),T2(iy+1),T1(ix-1),T1(ix),T1(ix+1));
 end
 fclose(fp);
end
%################################## END MAIN #########################################################
