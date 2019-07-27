%--------------------------------------------------------------------------
%
%     Copyright (C) <2019>  <V. Bortolotti,P. Fantazzini, G. Landi, F. Zama>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The only official release of Upen2DTool is by the authors. If you wish 
%     to contribute to the official release of Upen2DTool please contact the 
%     authors. The authors will decide which contributions would enter the 
%     official release of Upen2DTool. 
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>
%
%########################################################################################
%NAME    : main.m
%PURPOSE : Main program interface. 
%VERSION : 1.0 [15/01/2019]         
%NOTES   : for T1-T2 data it is used a IR-CPMG kernel, for T2-T2 data it is used a 
%          CPMG-CPMG kernel.
%########################################################################################
clear all;
close all; 
clc;
fprintf('Upen2DTool Starts \r\n');
%
selpath = uigetdir('.\DATA\','Open Data Directory');
endout=regexp(selpath,filesep,'split');
FolderName=endout{end};
h=msgbox('Please wait, computation can take a while ...','Upen2DTool is running','warn');
try 
 % computation here % 
  Upen2DRun(FolderName);
catch
  delete(h); 
end
delete(h);
return;
