# How to run
first install MCRInstaller.exe
\
then run AD_F.exe

Because there needs one process to collect the real-time signal, one process to analysis the signal, we use the virtual memory swapping technology to avoid opening two physical pages of MatLab.

# Data storage path
x:\ad.i16

# Format of input figures
1. 16-bit integer,there are (4+FS) numbers

2. the order is: cnt，0，FS，LEN（the length of data）dat_0，dat_1,...,dat_(FS-1)
