
alias Update {
  var %filepath Hermes.txt
  if ($exists(%filepath)) {
    remove %filepath
  }
  elseif ($remote !& 2) {
    var %error Remote is off
  }
  if (%error) {
    echo $color(info) -as * /Update $+ : %error
    halt
  }
  var %id HermesUpdate.1
  if ($sock(%id)) {
    echo 4 -s Updater is already running!
    return
  }
  if ($hget(%id)) {
    hfree %id
  }
  var %host beardbot.net84.net,%path /update.text
  hmake %id 5
  hadd %id DownloadPath %filepath
  hadd %id Host %host
  hadd %id Path %path
  hadd %id ReceivedAllHeaders $false
  sockopen %id %host 80
}
on *:sockopen:HermesUpdate.*: {
  if ($sockerr) {
    echo 4 -s sockopen error: $sock($sockname).wsmsg
    return
  }
  sockwrite -nt $sockname GET $hget($sockname,Path) HTTP/1.1
  sockwrite -nt $sockname Host: $hget($sockname,Host)
  sockwrite -nt $sockname User-agent: Secret
  sockwrite -nt $sockname $crlf
}
on *:sockread:HermesUpdate.*: {
  if ($sockerr) {
    echo 4 -s sockread error: $sock($sockname).wsmsg
    HttpGetEvent $sockname ERROR SOCKREAD Error: $sock($sockname).wsmsg
    return
  }
  TryRead
  while ($sockbr) {
    TryRead
  }
}
alias TryRead {
  if ($hget($sockname,ReceivedAllHeaders)) {
    sockread &data
    var %file $hget($sockname,DownloadPath)
    bwrite $qt(%file) -1 -1 &data
    hinc $sockname ContentReceivedLength $sockbr
    if ($hget($sockname,ContentLength) == $hget($sockname,ContentReceivedLength)) {
      DownloadSuccess $sockname
      load -rs Hermes.txt
      DownloadCleanup $sockname
    }
  }
  else {
    var %data
    sockread %data
    if (%data == $null) {
      hadd $sockname ReceivedAllHeaders $true
    }
    elseif ($regex(%data,/^Content-Length: (\d+)$/i)) {
      hadd $sockname ContentLength $regml(1)
    }
  }
}
on *:sockclose:HermesUpdate.*: {
  DownloadFailed $sockname
  DownloadCleanup $sockname
}
alias DownloadCleanup {
  if ($sock($1)) {
    sockclose $1
  }
  if ($hget($1)) {
    hfree $1
  }
}
alias DownloadSuccess {
  echo Download success!
}
alias DownloadFailed {
  echo Download failed
}
