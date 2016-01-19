1;

a = argv();
x=load(a{1});
y=mean(x);
save("-ascii", a{2}, "y");
