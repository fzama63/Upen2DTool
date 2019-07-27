%###################################################################################################
%PURPOSE :Loads flag parameters from file.
%DATE    :15/07/2017
%VERSION :1.1 [00/00/0000]
%         1.2 [19/10/2017] (vb) added FLNoContour flag to plot with or without contour.
%         1.3 [03/05/2019] (vb) added FL_Verbose flag.             
%NOTES   :
%
%###################################################################################################
%
function [CommentTS, FL_typeKernel, FL_InversionTimeLimits, ...
      FL_OutputData, FL_NoContour, FL_Verbose]= LoadFlags(InputFileName, UseDefault) 
 if(UseDefault)
     CommentTS='Default Flags';
     FL_typeKernel=4;          %1 IR-CPMG; 4 T2-T2
     FL_InversionTimeLimits=0; %1 automatic, 0 manually selection inversion times
     FL_OutputData=0;          %1 create output data file for ILT2D
     FL_NoContour=1;           %1 no image with contour
else
    fid = fopen(InputFileName);  %
    CommentTS = fgetl(fid);       % a row of comment
    %extract flags values
    while(1)
       stringa=fgetl(fid);
       stringa=strtrim(stringa);
       if(strfind(stringa, 'END')==1) break; end   %stops reading parameters.
       if(strfind(stringa, 'FL_typeKernel         =')==1) 
          FL_typeKernel=str2double(strrep(stringa,'FL_typeKernel         =',''));
       end
       if(strfind(stringa, 'FL_InversionTimeLimits=')==1) 
          FL_InversionTimeLimits=str2double(strrep(stringa,'FL_InversionTimeLimits=',''));
       end
       if(strfind(stringa, 'FL_OutputData         =')==1) 
          FL_OutputData=str2double(strrep(stringa,'FL_OutputData         =',''));
       end
       if(strfind(stringa, 'FL_NoContour          =')==1) 
          FL_NoContour=str2double(strrep(stringa,'FL_NoContour          =',''));
       end
       if(strfind(stringa, 'FL_Verbose            =')==1) 
          FL_Verbose=str2double(strrep(stringa,'FL_Verbose            =',''));
       end
    end
    fclose(fid);
 end
 return;
end

