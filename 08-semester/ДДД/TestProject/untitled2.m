noise = randn(44100*5,1);
sound(noise,44100)

recObj = audiorecorder(44100,16,1);
recordblocking(recObj,5)

y = getaudiodata(recObj);
plot(y)