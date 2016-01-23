1;

disp('');
disp('TEST covariance matrix');
disp('     comparing the result computed in octave with the result in python');
disp('     this implies a test for "mean.py" and "std.py"');

a = argv();

f = fopen(a{1});
data = fread(f, Inf, 'uint8');
fclose(f);
x = zscore(reshape(data, 3072, size(data) / 3072)', 1);
c1 = cov(x, 1);

f = load(a{2});
c2 = f.c / double(f.n);

s = sum(sum(abs(c1 - c2) > 0.00000001));
assert(s == 0);
disp('     done. ok.');
