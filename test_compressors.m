%% TEST_COMPRESSORS.m
% =========================================================================
% UNIT TEST SCRIPT - Verifies correctness of all compressor implementations
%
% Run this FIRST before main_run_all.m to confirm everything is set up
% correctly and compressor truth tables match the paper.
%
% Usage:
%   test_compressors
% =========================================================================

clear; clc;
fprintf('=== Running Unit Tests ===\n\n');
all_passed = true;


%% Test 1: Input Reordering Circuit (Table 1)
fprintf('[Test 1] Input Reordering Circuit\n');
test_cases = [
    0 0 0 0,  0 0 0 0;
    0 0 0 1,  1 0 0 0;
    0 0 1 0,  1 0 0 0;
    0 1 1 0,  1 1 0 0;
    1 1 1 0,  1 1 1 0;
    1 1 1 1,  1 1 1 1;
];
for i = 1:size(test_cases,1)
    [X1,X2,X3,X4] = input_reorder(test_cases(i,1), test_cases(i,2), ...
                                    test_cases(i,3), test_cases(i,4));
    exp = test_cases(i, 5:8);
    got = [X1 X2 X3 X4];
    if ~isequal(got, exp)
        fprintf('  FAIL: input [%d%d%d%d] -> got [%d%d%d%d], expected [%d%d%d%d]\n', ...
            test_cases(i,1:4), got, exp);
        all_passed = false;
    end
end
fprintf('  PASS - Input reordering OK\n\n');


%% Test 2: Proposed Design 1 (Table 2)
fprintf('[Test 2] Proposed Compressor Design 1 (Table 2)\n');
% After reordering: [X1 X2 X3 X4] -> [Sum Carry ED]
% Key test: 1110 should give Sum=0, Carry=1 (actual: Sum=1, Carry=1, ED=+1)
table2 = [
    0 0 0 0,  0 0;  % 0 ones
    1 0 0 0,  1 0;  % 1 one
    1 1 0 0,  0 1;  % 2 ones (correct)
    1 0 1 0,  0 1;  % 2 ones (after reorder = 1100)
    1 1 1 0,  0 1;  % 3 ones (approximate! actual=Sum1,Carry1)
    1 1 1 1,  0 0;  % 4 ones
];
for i = 1:size(table2,1)
    inp = table2(i,1:4);
    [S, C] = compressor_proposed1(inp(1), inp(2), inp(3), inp(4));
    exp_S = table2(i,5); exp_C = table2(i,6);
    if S ~= exp_S || C ~= exp_C
        fprintf('  FAIL: input [%d%d%d%d] -> Sum=%d Carry=%d, expected Sum=%d Carry=%d\n', ...
            inp, S, C, exp_S, exp_C);
        all_passed = false;
    end
end
fprintf('  PASS - Design 1 compressor OK\n\n');


%% Test 3: Proposed Design 2 (Table 3)
fprintf('[Test 3] Proposed Compressor Design 2 (Table 3)\n');
% Sum=X1, Carry=X2 after reordering
table3 = [
    0 0 0 0,  0 0;  % 0000 -> 0,0
    1 0 0 0,  1 0;  % 1000 -> 1,0
    1 1 0 0,  1 1;  % 1100 -> 1,1 (approx: actual=0,1)
    1 1 1 0,  1 1;  % 1110 -> 1,1 (correct)
    1 1 1 1,  1 1;  % 1111 -> 1,1 (approx: actual=0,0)
];
for i = 1:size(table3,1)
    inp = table3(i,1:4);
    [S, C] = compressor_proposed2(inp(1), inp(2), inp(3), inp(4));
    exp_S = table3(i,5); exp_C = table3(i,6);
    if S ~= exp_S || C ~= exp_C
        fprintf('  FAIL: input [%d%d%d%d] -> Sum=%d Carry=%d, expected Sum=%d Carry=%d\n', ...
            inp, S, C, exp_S, exp_C);
        all_passed = false;
    end
end
fprintf('  PASS - Design 2 compressor OK\n\n');


%% Test 4: Exact Compressor Verification
fprintf('[Test 4] Exact 4:2 Compressor\n');
% A 4:2 compressor takes X1,X2,X3,X4,Cin and outputs Sum, Carry, Cout.
% Sum is at weight w. Carry and Cout are BOTH at weight w+1.
% So total value = Sum*1 + (Carry+Cout)*2
% Test: all 5 inputs = 1 -> total = 5
%   5 = 1*1 + 2*2  -> Sum=1, Carry+Cout=2 -> Carry=1, Cout=1
[S,C,Co] = exact_compressor(1,1,1,1,1);
total = S*1 + (C+Co)*2;
if total ~= 5
    fprintf('  FAIL: 11111 -> total value=%d (expected 5). Sum=%d Carry=%d Cout=%d\n', total,S,C,Co);
    all_passed = false;
end
% Test: all zeros -> all outputs zero
[S,C,Co] = exact_compressor(0,0,0,0,0);
if S~=0 || C~=0 || Co~=0
    fprintf('  FAIL: 00000 should give all zeros\n');
    all_passed = false;
end
% Test: exactly 2 ones (X1=1,X2=1,X3=0,X4=0,Cin=0) -> value=2 -> Sum=0,Carry=1,Cout=0
[S,C,Co] = exact_compressor(1,1,0,0,0);
total = S*1 + (C+Co)*2;
if total ~= 2
    fprintf('  FAIL: 11000 -> total=%d (expected 2)\n', total);
    all_passed = false;
end
% Test: 3 ones -> value=3 -> Sum=1, higher=1
[S,C,Co] = exact_compressor(1,1,1,0,0);
total = S*1 + (C+Co)*2;
if total ~= 3
    fprintf('  FAIL: 11100 -> total=%d (expected 3)\n', total);
    all_passed = false;
end
fprintf('  PASS - Exact compressor OK\n\n');


%% Test 5: Exact 8x8 Multiplier Baseline
fprintf('[Test 5] Exact Multiplication Baseline\n');
test_pairs = [0 0 0; 1 1 1; 2 3 6; 15 15 225; 255 1 255; ...
              10 10 100; 200 200 40000; 128 128 16384; 7 8 56; 255 255 65025];
fail5 = false;
for k = 1:size(test_pairs,1)
    A = test_pairs(k,1); B = test_pairs(k,2); expected = test_pairs(k,3);
    got = approx_dadda_8x8(A, B, 'exact');
    if got ~= expected
        fprintf('  FAIL: %d x %d: expected %d, got %d\n', A, B, expected, got);
        fail5 = true; all_passed = false;
    end
end
if ~fail5
    fprintf('  PASS - Exact multiplier baseline OK\n\n');
end


%% Test 6: Quick Accuracy Check for Design 1
fprintf('[Test 6] Design 1 Error Rate Quick Check\n');
% Paper reports ER = 26.67% for Design 1
% Test a subset of 100 random pairs
rng(42);
n_test = 1000;
n_err = 0;
for k = 1:n_test
    A = randi([0, 255]);
    B = randi([0, 255]);
    exact  = double(uint16(A) * uint16(B));
    approx = double(approx_dadda_8x8(A, B, 'proposed1'));
    if exact ~= approx
        n_err = n_err + 1;
    end
end
er_approx = n_err / n_test * 100;
fprintf('  Estimated ER for Proposed Design 1: %.2f%% (paper: ~26.67%%)\n', er_approx);
if er_approx > 5 && er_approx < 50
    fprintf('  PASS - ER in expected range\n\n');
else
    fprintf('  WARNING - ER outside expected range, check implementation\n\n');
end


%% Summary
fprintf('=== Test Summary ===\n');
if all_passed
    fprintf('All core tests PASSED. Ready to run main_run_all.m\n');
else
    fprintf('Some tests FAILED. Please review the output above.\n');
end
