%#########################################################################
% T2-T2 kernels, Case CPMG-CPMG.  
%#########################################################################
function [Kernel_1,Kernel_2] = T2_T2_Kernel
  Kernel_1 = inline('exp(- Tau * (1./ T1))','Tau','T1');
  Kernel_2 = inline('exp( - Tau * (1./ T2))','Tau','T2');
end

