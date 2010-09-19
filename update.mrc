
alias Update {

  var %directory $mircdir $+ Temp\

  if (!$isdir(%directory)) {
    mkdir $qt(%directory)
  }

  ;var %url http://beardbot.net84.net/update.text 
  ;var %downloadPath %directory $+ Hermes.txt

  ;var %url2 http://runescape.com
  ;var %downloadPath2 %directory $+ Rs.txt

  ;noop $Download(UpdateCallback, %url, %downloadPath)
  ;noop $Download(UpdateCallback, %url2, %downloadPath2)


  noop $MultiDownload(UpdateCallback, $&
    www.runescape.com, temp\rs.txt, $&
    http://beardbot.net84.net/update.text, Temp\hermes.txt, $&
    www.google.com, temp\google.txt, $&
    http://hermes.beard-bot.co.uk/, temp\hermessite.txt, $&
    hacker.org, temp\hacker.txt $&
    )
}

alias UpdateCallback {
  echo -s updatecallbcak: $1-

  var %status $2
  var %params $3-
  if (%status == Error) {
    echo -a An error occured while downloading.
  }
  elseif (%status == Complete) {
    echo -a woo complete
  }
  elseif (%status == Success) {
    echo -a woo finished downloading $ord(%params) file.
  }
}

alias MultiDownload {
  ;parameters: <callback> <url> <download path> [<url> <download path> [...]]

  var -s %callback $1
  echo -s $0

  if ($0 < 3) {
    error Not enough parameters.
  }

  if (2 // $0) {
    error You must specify a download path for each url
  }

  var %id MultiDownload.0
  while ($sock(%id)) || ($hget(%id)) {
    var %id HermesUpdate. $+ $rand(1,999999999)
  }

  hmake %id 5

  var %count 0
  var %i 3
  while (%i <= $0) {
    var %url $ [ $+ [ $calc(%i - 1) ] ]
    var %path $ [ $+ [ %i ] ]

    inc %count
    hadd %id Url. $+ %count %url
    hadd %id DownloadPath. $+ %count %path
    echo -s added %url and %path
    inc %i 2
  }

  hadd %id FileCount %count
  hadd %id CurrentFile 0
  hadd %id Callback %callback

  DownloadNext %id
}

alias DownloadNext {
  ;parameters: <id>

  var %id $1

  hinc %id CurrentFile
  var %current $hget(%id, CurrentFile)

  if (%current > $hget(%id, FileCount)) {
    var %callback $hget(%id, Callback)
    if ($isalias(%callback)) {
      %callback Complete
    }
    return
  }

  var %url $hget(%id, Url. $+ %current)
  var %path $hget(%id, DownloadPath. $+ %current)

  var %dl $Download(MultiDownloadCallback, %url, %path)

  hadd %dl MultiDownloadID %id
}

alias MultiDownloadCallback {
  ;parameters: <id> <status> <params>
  ;status can be either "Success" or "Error"

  var -s %id $1
  var -s %multiId $hget(%id, MultiDownloadID)
  var %status $2
  var %description $3

  if (%status == Success) {
    echo -a Download success!

    DownloadNext %multiId
  }
  elseif (%status == Error) {
    var %successCount $hget(%multiId, CurrentFile)
    dec %successCount
    MultiDownloadRunCallback %multiId Error %successCount
  }
  else {
    echo -a Eek.. this script is broken!
  }
}

alias MultiDownloadRunCallback {

  var %id $1
  var %status $2
  var %description $3-

  var %callback $hget(%id, Callback)
  if ($isalias(%callback)) {
    var %successCount $hget(%id, CurrentFile)
    dec %successCount
    %callback Error %successCount
  }
}

alias -l Error {
  ;parameters: <Message>
  ;Displays an error message then halts the scripting engine.

  var %message $1-

  echo $color(info) -as * /Update $+ : %message
  halt
}

alias Download {
  ;parameters: <callback> <url> <download path>

  var %callback $1
  var %url $2
  var %filepath $3

  if (%callback == $null) {
    Error Callback wasn't specified.
  }
  elseif (%url == $null) {
    Error Url wasn't specified.
  }
  elseif (%filepath == $null) {
    Error Download path wasn't specified.
  }
  elseif ($exists(%filepath)) {
    Error File already exists.
  }
  elseif ($remote !& 2) {
    Error Remote is off. Type: /remote on
  }

  if ($regex(%url,m!^([a-z+.-]+)(://)!i)) {

    if ($regml(1) != http) {
      var %error Invalid url.
    }

    var %url $mid(%url,$calc($regml(2).pos + $len($regml(2))))
  }

  var -s %host $gettok(%url,1,47)
  var -s %path $mid(%url,$calc($len(%host) + 1))
  var -s %port $iif(%ssl,443,80)

  if (%host == $null) {
    Error Invalid url.
  }

  if (%path == $null) {
    var %path /
  }

  var %id HermesUpdate.0
  while ($sock(%id)) || ($hget(%id)) {
    var %id HermesUpdate. $+ $rand(1,999999999)
  }

  hmake %id 5
  hadd %id Callback %callback
  hadd %id DownloadPath $qt(%filepath)
  hadd %id Host %host
  hadd %id Path %path
  hadd %id Port %port
  hadd %id ReceivedAllHeaders $false

  sockopen $iif(%ssl,-e) %id %host %port

  return %id
}
on *:SOCKOPEN:HermesUpdate.*: {
  if ($sockerr) {
    RunCallback $sockname Error SOCKOPEN Error: $sock($sockname).wsmsg
    return
  }
  sockwrite -nt $sockname GET $hget($sockname,Path) HTTP/1.1
  sockwrite -nt $sockname Host: $hget($sockname,Host)
  sockwrite -nt $sockname User-agent: Secret
  sockwrite -nt $sockname $crlf
}
on *:SOCKREAD:HermesUpdate.*: {
  if ($sockerr) {
    RunCallback $sockname Error SOCKREAD Error: $sock($sockname).wsmsg
    return
  }
  TryRead
  while ($sockbr) {
    TryRead
  }
}
alias TryRead {
  if ($hget($sockname,ReceivedAllHeaders)) {

    if ($hget($sockname, Chunked)) {
      var %bytesLeft $hget($sockname, BytesLeft)
      if (%bytesLeft == 0) {
        var %data
        sockread %data
        if (!$sockbr) {
          return
        }
        ;Reading the crlf after useful data
        if (%data == $null) {
          return
        }
        var %bytesLeft $base(%data, 16, 10)
        if (%bytesLeft == 0) {
          RunCallback $sockname Success
          return
        }

        hadd $sockname BytesLeft %bytesLeft

      }
      else {
        sockread %bytesLeft &data
        if (!$sockbr) {
          return
        }
        hdec $sockname BytesLeft $sockbr
        var %file $hget($sockname,DownloadPath)
        bwrite $qt(%file) -1 -1 &data
      }
    }
    else {
      sockread &data
      if (!$sockbr) {
        return
      }
      var %file $hget($sockname,DownloadPath)
      bwrite $qt(%file) -1 -1 &data
      hinc $sockname ContentReceivedLength $sockbr
      if ($hget($sockname,ContentLength) == $hget($sockname,ContentReceivedLength)) {
        RunCallback $sockname Success
      }
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
    elseif (%data == Transfer-Encoding: chunked) {
      echo 4 -s yeah chunked
      hadd $sockname Chunked 1
      hadd $sockname BytesLeft 0
    }
  }
}

on *:SOCKCLOSE:HermesUpdate.*: {
  RunCallback Error $sockname SOCKCLOSE Error: Connection unexpectedly closed
}

alias RunCallback {

  var %id $1
  var %status $2
  var %description $3-

  var %callback $hget(%id, Callback)

  if ($isalias(%callback)) {
    %callback %id %status %description  
  }

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
