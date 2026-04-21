function K = get_sharp_kernel()
% GET_SHARP_KERNEL - Returns sharpening kernel from Equation (14) of the paper
%
% 5x5 Gaussian sharpening kernel as specified in the paper.
%
% K = [ 1   4   7   4  1]
%     [ 4  16  26  16  4]
%     [ 7  26  41  26  7]
%     [ 4  16  26  16  4]
%     [ 1   4   7   4  1]

    K = [ 1   4   7   4  1;
          4  16  26  16  4;
          7  26  41  26  7;
          4  16  26  16  4;
          1   4   7   4  1];
end
