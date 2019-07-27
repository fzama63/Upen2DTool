%#########################################################################
%   T1-T2 kernels, case IR-CPMG.
%#########################################################################
function [Kernel_1,Kernel_2] = T1_T2_Kernel
  Kernel_1 = inline('1-2*exp(- Tau * (1./ T1))','Tau','T1');
  Kernel_2 = inline('exp( - Tau * (1./ T2))','Tau','T2');
end

