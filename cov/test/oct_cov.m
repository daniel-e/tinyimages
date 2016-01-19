1;

a = argv();
x = load(a{1});
c = cov(x);
y = load(a{2});
z = double(y.c) / double(y.n - 1);
r = abs(c - z);
assert(sum(sum(r > 1e-10)) == 0);
