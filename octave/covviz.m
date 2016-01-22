1;

a = argv();
load(a{1});
x = c / double(n);
imshow(x / max(max(x)) * 255.0);
pause(2);
disp('writing file ...');
print (a{2}, '-dpng')
pause(3);

% TODO is there a more elegant solution to wait until print is done?
