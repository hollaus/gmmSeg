# MultiSpectral Document Image Binarization using GMMs
This is the implementation of our paper in [1].


## Usage
The code is designed for the MS-TEx dataset [2]. The main file is gmmSeg.
Use it with: 

gmmSeg(inputFolder, outputName)

The method makes use of large median filters, which takes quite long. In case you want have already median filtered images you can provide them to the main file:

gmmSeg(inputFolder, outputName, filteredInputFolder)

The median filtering can be done before, by using the filterFolders script.

## References
[1] ``Fabian Hollaus, Markus Diem, Robert Sablatnig: MultiSpectral Image Binarization using GMMs. ICFHR 2018: 570-575``

[2] ``Rachid Hedjam, Hossein Ziaei Nafchi, Reza Farrahi Moghaddam, Margaret Kalacska, Mohamed Cheriet: ICDAR 2015 contest on MultiSpectral Text Extraction (MS-TEx 2015). ICDAR 2015: 1181-1185 ``
