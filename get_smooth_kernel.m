function K = get_smooth_kernel()
% GET_SMOOTH_KERNEL - Returns smoothing kernel from Equation (13) of the paper
%
% 5x5 Gaussian-like smoothing kernel as specified in the paper.
%
% K = [1  1  1  1  1]
%     [1  4  4  4  1]
%     [1  4 12  4  1]
%     [1  4  4  4  1]
%     [1  1  1  1  1]

    K = [1  1  1  1  1;
         1  4  4  4  1;
         1  4 12  4  1;
         1  4  4  4  1;
         1  1  1  1  1];
end
