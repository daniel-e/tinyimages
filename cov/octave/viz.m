1;

x = load('5000.txt.gz');
c = cov(x);
y = c / max(max(c));
imshow(y);
print -dpng -r200 'cov.png'
disp('press enter to quit');
pause;
