# random-scripts
Some various scripts I've written, mainly for music

CTIFT (Concert Tape Info File Trimmer): Takes in info files that are usually provided with concert tapes, and trims them down to just the tracklisting. These files then can be used to tag the files using something like MP3Tag.

AudioConverter (NOTE: Requires FFMPEG): Does a few things:
- Converts FLAC files down to MP3 (in either 320kbps or 192kbps)
  - Basically I wrote this to share audio files on Discord back when the file size limit was 8MB. It has since been increased to 25MB, which is fine for most standard res FLAC files. 
- Convert audio from 24bit/96khz down to 16bit/48khz or 16bit/44.1khz
  - Can take real hi-res files and downsample them. Primarily because I don't have a major need for super hi-res files.
- FLAC -> ALAC (Apple Lossless format)
  - For when you have a ton of FLAC files and want to import them into ITunes/Apple Music
- ALAC -> FLAC (Normal Lossless format)
  - Reverse of the above
 
All of the AudioConverter functions are non-destructive. They don't replace any files, but rather outputs to a new folder in the provided input path.

Also all AudioConverter functions generate MD5 and FFP (FLAC only) fingerprint files.
