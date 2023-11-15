# NOTFLIX

notflix a tool which search magnet links and stream it with [btplay](https://github.com/johang/btfs).

![Video Preview](./preview.gif)

## How does this work?

This is a shell script. It scrapes 1337x and gets the magnet link.
After this it uses [btplay](https://github.com/johang/btfs) to stream the video from magnet link.
For scraping, the script uses simple gnu utils like sed, awk, paste, cut.

## Requirements

- [btfs](https://github.com/johang/btfs) - A tool to access torrent files as a filesystem.
- My fork of [dmenu](https://github.com/Mathieu-COSYNS/dmenu)
- A video player [compatible with btplay](https://github.com/johang/btfs/blob/80ee126c934eb167f35d0029d6a7dcc287f64d87/scripts/btplay#L34) or you should specify your video play inside the notflix.sh script

## Install, Update or Remove

### Favorite Method

- To install, clone **notflix** repository then run `sudo ./install.sh`
- To update, just do `git pull` then run `sudo ./install.sh` again.
- To uninstall, run `sudo ./uninstall.sh` then remove your clone of the repo.

### Alternative Method

Download the file `notflix.sh` and do your thing. It's just a shell script written for linux.

## License

This project is licensed under [GPL-3.0](https://raw.githubusercontent.com/Illumina/licenses/master/gpl-3.0.txt).
