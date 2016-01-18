1;

a = argv();
x = load(a{1});
imshow(reshape(x / max(x), [32, 32, 3]));
print (a{2}, '-dpng')
disp('press enter to continue');
pause;
y = x - min(x);
y = y / max(y);
imshow(reshape(y, [32, 32, 3]));
print (a{3}, '-dpng')
disp('press enter to quit');
pause;
