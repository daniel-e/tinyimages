1;

% 400x400   -> 0.25s
% 800x800   -> 1.55s
% 1600x1600 -> 15.4s

a = argv();
load(a{1});
c = zscore(c / double(n));
[u,s,v] = svd(c);
% tic, [u,s,v] = svd(c); toc  -> 231.782 seconds

save('-6', a{2}, 'c');
