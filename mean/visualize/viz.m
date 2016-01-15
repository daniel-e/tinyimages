1;

x = load('../outputs/mean.txt');
imshow(reshape(x / max(x), [32, 32, 3]));
disp('press enter to continue');
pause;
y = x - min(x);
y = y / max(y);
imshow(reshape(y, [32, 32, 3]));
disp('press enter to quit');
pause;
