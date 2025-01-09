# Introduction
Based on the **GUI** development platform of **MATLAB**, through the human-computer interaction design and algorithm design, a set of **real-time** detection software for the acoustic signals of rotor drones is designed by using the principles of signal sensing and sampling, the characteristic differences between the radiated noise signals of the rotor drones and the ambient noises as well as the signal adjudication methods.

There exist two parts:

The first is the **feature extraction** module. 

By reading the acoustic signals acquired in real time from the above virtual X-disk, converting them from the time domain to the time-frequency domain using STFT transform, and further extracting the frequency domain information using the addition of the window integration method, the frequency spectrum, power spectrum and feature points of the real-time acoustic signals are obtained.

The second is the **target detection** module.

The extracted potential feature points are used to determine whether there is a harmonic set of drone noise through the harmonic set detection and screening algorithm, which is used as a criterion to realize the detection system of drone acoustic signals. At the same time, when the system detects the existence of harmonic sets of drone noise signals, the corresponding waveforms and spectral feature points will be marked in red and accompanied by an alarm sound to remind the system, which is a more intuitive reflection of the role of the detection system.

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
