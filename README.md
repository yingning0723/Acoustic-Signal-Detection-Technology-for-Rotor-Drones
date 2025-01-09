# How to run
first install MCRInstaller.exe
\
then run AD_F.exe

Because there needs one process to collect the real-time signal, one process to analyze the signal, we use the virtual memory swapping technology to avoid opening two physical pages of MatLab.

# Data storage path
x:\ad.i16

# Format of input figures
1. 16-bit integer,there are (4+FS) numbers
2. the order is: cnt，0，FS，LEN（the length of data）dat_0，dat_1,...,dat_(FS-1)

# main function
The main function is Recoder.m, the APIS are:

1. first run AD_F, and it will analyze the whole codes in real time
2. save the real time recordings
3. analyze this certain recordings
