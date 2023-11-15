#!/bin/sh

# Dependencies:
#   - btfs (btplay)
#   - https://github.com/Mathieu-COSYNS/dmenu

menu="dmenu -i -l 20"
baseurl="https://1337x.to"
BTPLAY_FLAGS=""

cachedir="$HOME/.cache/notflix"
searchhtmlfile="$cachedir/search.html"
titlefile="$cachedir/titles.txt"
seedleechfile="$cachedir/seedleech.txt"
sizesfile="$cachedir/sizes.txt"
linksfile="$cachedir/links.txt"

read_query() {
  QUERY=$($menu -p "Search Torrent: " -it "$QUERY" <&-)

  # Canceled
  test -z "$QUERY" && return 1

  echo "Searching for: $QUERY"

  return 0
}

get_torrents_list() {
  # Download search results
  curl -s "$baseurl/search/$(echo $QUERY | sed 's/ /+/g')/1/" >"$searchhtmlfile"

  # Get Titles
  grep -o '<a href="/torrent/.*</a>' "$searchhtmlfile" |
    sed 's/<[^>]*>//g' |
    sed 's/\./ /g; s/\-/ /g' |
    sed 's/[^A-Za-z0-9 ]//g' |
    tr -s " " >"$titlefile"

  result_count=$(wc -l "$titlefile" | awk '{print $1}')
  if [ "$result_count" -lt 1 ]; then
    notify-send "😔 No Result found. Try again 🔴"
    return 1
  fi

  # Seeders and Leechers
  grep -o '<td class="coll-2 seeds.*</td>\|<td class="coll-3 leeches.*</td>' "$searchhtmlfile" |
    sed 's/<[^>]*>//g' |
    sed 'N;s/\n/ /' |
    awk '{print "[S:"$1 ", L:"$2"]" }' >"$seedleechfile"

  # Size
  grep -o '<td class="coll-4 size.*</td>' "$searchhtmlfile" |
    sed 's/<span class="seeds">.*<\/span>//g' |
    sed -e 's/<[^>]*>//g' >"$sizesfile"

  # Links
  grep -Eo "/torrent\/[0-9]{7}\/[a-zA-Z0-9?%-]*/" "$searchhtmlfile" >"$linksfile"

  return 0
}

select_torrent_url() {
  # Getting the line number
  LINE="$(paste -d '@' "$sizesfile" "$seedleechfile" "$titlefile" | sed 's/@/ - /g' | $menu -r -ix)"

  if [ -z "$LINE" ]; then
    return 1
  fi

  LINE=$(echo "$LINE + 1" | bc)

  movieurl="${baseurl}$(head -n $LINE "$linksfile" | tail -n +$LINE)"

  return 0
}

get_magnet_from_movieurl() {
  echo "Reading $movieurl"
  magnet=$(curl -s "$movieurl" | grep -Po "magnet:\?xt=urn:btih:[a-zA-Z0-9]*" | head -n 1)
}

open_magnet_link() {
  if [ -z "$magnet" ]; then
    notify-send "🧲 Magnet not found!"
    return 1
  fi

  notify-send "🧲 Magnet found! Loading..."

  btplay $BTPLAY_FLAGS "$magnet"

  return 0
}

# Read args
QUERY=$*

mkdir -p "$cachedir"

while :; do
  read_query || exit 0
  get_torrents_list && select_torrent_url && get_magnet_from_movieurl && open_magnet_link && exit 0
done
