
dialog CPanel {
  title "Hermes"
  size -1 -1 148 120
  option dbu
  box "Hermes Easy to use Runescape bot v0.3.9", 1, 3 3 143 115
  edit "#", 2, 55 22 44 12, autohs
  edit "#", 3, 55 38 44 12, autohs
  combo 4, 12 22 37 28, drop
  button "ok", 5, 12 38 37 12, ok
  text "Bot colours Channels", 6, 13 13 76 8
  text "Bot Channel", 7, 104 22 37 12
  text "Home Channel", 8, 104 38 37 12
  edit "", 9, 12 56 87 10, multi vsbar
  edit "", 10, 12 70 87 10, multi vsbar
  text "Noreply chans", 11, 104 55 37 12
  text "Invite message", 12, 104 70 37 12
  check "Auto Bot news", 13, 92 12 50 10
  edit "", 14, 12 83 20 12, autohs
  text "Public Prefix", 15, 35 85 37 12
  edit "", 16, 70 83 20 12, autohs
  text "Private Prefix", 17, 93 85 37 12
  button "Update", 18, 54 100 37 12
}

on *:DIALOG:CPanel:INIT:0: {
  didtok $dname 4 32 02 03 04 06 07 10 13
  didtok $dname 2 35 $remove($readini(Hermes.ini,settings,Botchan),$chr(126))
  didtok $dname 3 35 $remove($readini(Hermes.ini,settings,Homechan),$chr(126))
  didtok $dname 9 96 $remove($readini(Hermes.ini,settings,noreply),$chr(126))
  didtok $dname 10 96 $remove($readini(Hermes.ini,settings,invmsg),$chr(126))
  did $iif($readini(Hermes.ini,settings,Botnews) == 1,-c,-u) $dname 13
  didtok $dname 14 124 $iif($readini(Hermes.ini,settings,publictrig),$v1,@)
  didtok $dname 16 124 $PrivateTrigger
}

on *:DIALOG:CPanel:SCLICK:5: {
  writeini Hermes.ini Settings Colour $iif($did(4).seltext,$v1,13)
  writeini Hermes.ini Settings Botchan $did(2)
  writeini Hermes.ini Settings Homechan $did(3)
  writeini Hermes.ini Settings noreply $didtok(9,32)
  var %invMsg $didtok(10,32)
  if (%invMsg != $null) {
    writeini Hermes.ini Settings invmsg $didtok(10,32)
  }
  writeini Hermes.ini Settings Botnews $did(13).state
  writeini Hermes.ini Settings publictrig $left($didtok(14,32),1)
  writeini Hermes.ini Settings PrivateTrigger $did(16)

  if ($did(13).state == 1) {
    timerbotnews 0 $duration(1day) sockopen $+(botnews.,$right($ticks,5)) beardbot.netii.net 80
  }
  else {
    timerbotnews off
  }
}

on *:DIALOG:CPanel:SCLICK:18: {
  if ($isalias(Update)) {
    var %v $+(version.,$right($ticks,5))
    hadd -m %v update y
    sockopen %v beardbot.netii.net 80
  }
}

menu * {
  -
  Hermes: Hermes
  -
}
