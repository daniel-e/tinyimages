1;

a = argv();
x = load(a{1});
c = x.c;
n = double(x.n);
m = max(max(c));
imshow(c / m * 255.0);
pause;
