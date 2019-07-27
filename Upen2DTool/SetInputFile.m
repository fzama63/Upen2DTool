%###################################################################################################
%NAME    :SetInputFile.m
%PURPOSE :Set/load file name and other Data.
%DATE    :17/07/2017
%VERSION :1.0
%IMPUT   :InputFileName = name of the file with parameters.
%###################################################################################################
function [parfile]= SetInputFile(InputFileName, parfile, UseDefault)
  if UseDefault
    %Set Defaulf
    % [File Data]
    parfile.filenamedata          ='T2T2data2D.dat';
    parfile.filenameTimeX         ='T2T2AxisA.dat';
    parfile.filenameTimeY         ='T2T2AxisB.dat'; 
    %
    % [Inversion Points]
    parfile.nx=80;
    parfile.ny=80;
    % [Inversione Time limit]
    parfile.T1min                 =1;
    parfile.T1max                 =1000;
    parfile.T2min                 =1;
    parfile.T2max                 =1000;
    %
  else 
    fid = fopen(InputFileName);  %
    %
    CommentTS = fgetl(fid);       % a row of comment
    % %extract parameters
    while(1)
      stringa=fgetl(fid);
      stringa=strtrim(stringa);
      if(strfind(stringa, 'END')==1) break; end   %stops reading parameters.
      %
      if(strfind(stringa, 'filenamedata          =')==1) 
         parfile.filenamedata=strrep(stringa,'filenamedata          =','');
      end
      if(strfind(stringa, 'filenameTimeX         =')==1) 
          parfile.filenameTimeX=strrep(stringa,'filenameTimeX         =','');
      end
      %
      if(strfind(stringa, 'filenameTimeY         =')==1) 
          parfile.filenameTimeY=strrep(stringa,'filenameTimeY         =','');
      end
      %
      if(strfind(stringa, 'nx                    =')==1) 
          parfile.nx=str2double(strrep(stringa,'nx                    =',''));
      end
      if(strfind(stringa, 'ny                    =')==1) 
          parfile.ny=str2double(strrep(stringa,'ny                    =',''));
      end
      %
      if(strfind(stringa, 'T1min                 =')==1) 
          parfile.T1min=str2double(strrep(stringa,'T1min                 =',''));
      end
      %
      if(strfind(stringa, 'T1max                 =')==1) 
          parfile.T1max=str2double(strrep(stringa,'T1max                 =',''));
      end
      if(strfind(stringa, 'T2min                 =')==1)
          parfile.T2min=str2double(strrep(stringa,'T2min                 =',''));
      end
      if(strfind(stringa, 'T2max                 =')==1) 
          parfile.T2max=str2double(strrep(stringa, 'T2max                 =',''));
      end
    end
    fclose(fid);
  end
  %
  return;
%
end

