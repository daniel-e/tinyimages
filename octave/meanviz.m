1;

% arg1 = mean data set
% arg2 = filename 
% arg3 = filename

a = argv();
x = load(a{1});
imshow(reshape(x / max(x), [32, 32, 3]));
pause(2);
print (a{2}, '-dpng')
pause(2);
y = x - min(x);
y = y / max(y);
imshow(reshape(y, [32, 32, 3]));
pause(2);
print (a{3}, '-dpng')
pause(2);
