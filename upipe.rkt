#lang rash

(require json)
(require racket/function)

(define (title) "(title)")
(define (ext) "(ext)")
(define (yt-video-summary index json-port)
  (let* ([jsexpr (read-json json-port)]
         [get (curry hash-ref jsexpr)])
    (printf "~a\t~a\t~a" index (get 'title) (get 'channel))))

(define url "https://youtube.com/watch?v=M6EOBjxXUEM")

youtube-dl --max-downloads 4 \
--download-archive ytdl-archive.txt \
--dump-json \
-o "Chorpsaway/%(title)s.%(ext)s" \
$url |> yt-video-summary 0

; Goals:
; Get today and yesterday's videos from channel
; Download files given indexes. Load indexes from file overwritten by previous check.
; Get today and yesterday's videos from channel-file (subscriptions).
; Write down latest "check date" when calling "upipe done". This will be the lowest date, with no upper-date.
; downloaded files are added to watchlist
; vlc playlist kept up-to-date with watchlist
; pop from watchlist
; clear watchlist
; sort watchlist
; Create a web server. Search for video id on home page and redirect to page with above information.

; Do the same, but for channel (channel:blabla).  

; Let us share the download archive between subscriptions.
; youtube-dl -s --max-downloads 2 https://www.youtube.com/channel/UCHu17oT5IL8uXt8WXQ2E-rQ
; youtube-dl --max-downloads 1 --download-archive ytdl-archive.txt -o "Chorpsaway/%(title)s.%(ext)s" $video_url
; 

;youtube-dl --newline -i --hls-prefer-native -o "Chorpsaway/%(title)s.%(ext)s" --write-description --write-info-json --write-annotations --cookies cookies.txt --write-thumbnail --dump-json --download-archive Chorpsaway/ytdl-archive.txt https://www.youtube.com/channel/UCHu17oT5IL8uXt8WXQ2E-rQ
