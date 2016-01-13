1;

x=load("data.txt");
y=mean(x);
save("-ascii", "out_mean_octave.txt", "y");
