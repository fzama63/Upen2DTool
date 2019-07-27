%#################################################################################################################
%PURPOSE :Extracts data and times from data files.
%VERSION: 1.0 [10/04/2017]
%DATE    :10/04/2017
%CHANGES :1.0 [] 
%AUTHOR  :VB.
%##################################################################################################################
function [CommentTS, N_T1, N_T2, t_T1, t_T2, S] = LoadData(DataFileName, TimeRowFileName, TimeColumnFileName)
 fid = fopen(TimeRowFileName);  %
  t_T1 = fscanf(fid,'%f');
 fclose(fid);
 N_T1=size(t_T1);
 %
 fid = fopen(TimeColumnFileName);  %
  t_T2 = fscanf(fid,'%f');
 fclose(fid);
 N_T2=size(t_T2);
 %
 S = dlmread(DataFileName);
 %
 CommentTS='';
 %
 return;
%
end

