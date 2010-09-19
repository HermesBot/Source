alias -l locktime return 10
alias -l spmparam return 10:5 
alias -l release return 0.4
alias -l exploitcheckup return $regex($1-,/[%$]/)
alias -l rini return $readini(Default.ini,n,$1,$2)
alias -l nohtml return $regsubex($1-,/(<[^>]+>)/g,)
alias -l urlencode return $regsubex($1-,/(\W)/g,$+(%,$base($asc(\1),10,16,2)))
alias -l logo return $+($c2($1,**),$c1($1,[),$c2($1,$2),$c1($1,]))
alias requiredfiles return Hermes.txt Params.ini defparams.ini 
alias -l privatetrigger return $iif($read(settings.txt),$v1,!.~`)
alias -l publictrigger return $iif($readini(Hermes.ini,settings,publictrig),$v1,@)
alias Botchan return $remove($readini(Hermes.ini,settings,Botchan),$chr(126))
alias -l hlink return $regsubex($1-,/((?:http\Q://\E|www\.)\S+)/gi,$+($chr(31),$chr(3),07,\1,$chr(15))) 
alias -l fname return $replace($regsubex($1-,/^(.)/S,$upper(\t)),$chr(32),$iif($prop,+,$chr(95)))
alias -l c1 {
  return $+($chr(3),$iif($readini(Hermes.ini,Colour1,$address($1,3)),$v1,14),$2-) 
}
alias -l c2 {
  ;parameters: <nick>
  var %address $address($1, 3)
  var %colour $GetColour(%address, 2)
  return $chr(3) $+ %colour $+ $2-
}
alias GetColour {
  ;parameters: <address mask 3> <number>

  var %address $1
  var %number $2

  var %colour $readini(Hermes.ini, Colour $+ %number, %address)

  if (%colour == $null) {
    var %colour $readini(Hermes.ini,n,settings,Colour)
  }

  if (%colour == $null) {
    var %colour 10
  }

  return %colour
}
alias Hermes {
  var %n cpanel
  Dialog $iif($dialog(%n),-ve,-md %n) %n
}
alias -l chstop {
  var %y $iif($remove($readini(Hermes.ini,settings,noreply),$chr(126)),$v1,#bots)
  return $iif($istok(%y,$1,32),$true)
}
alias -l botexempt {
  var %bots Banhammer Captain_falcon Clanwars Client Coder Machine $& 
    Milk Minibar mIRC Noobs Pancake Spam Q W X Y Snoozles Runescape Unknown $&
    Onzichtbaar* Babylon* Vectra* *Runescript *Grandexchange,%n $numtok(%bots,32) 
  while (%n) {
    var %a $calc($wildtok($1,$gettok(%bots,%n,32),0,32) + %a)
    dec %n
  }
  return %a
}
alias output { 
  tokenize 32 $1-
  var %method $iif($prop,.describe,.msg)
  ;(trigger $1) (chan $2) (nick $3) (modes $4) (string $5)  
  $iif($2 == NA,%method $3,$iif($wildtok($1,$publictrigger $+ *,1,32) && !$readini(Hermes.ini,public,$2),%method $2,.notice $3)) $iif(c isincs $4,$strip($5-),$5-)
}
on *:text:*:*: { 
  var %trigger $+($privatetrigger,$publictrigger)
  var %mcheck $wildtok($1,$publictrigger $+ *,1,32),%ch $chan,$&
    %1 $1,%2 $iif(%mcheck && $chan,$chan,$iif(!%mcheck && $chan,NO,$iif(!$chan,NA,$v1))),$&
    %3 $nick,%4 $iif(%mcheck && !$chan,NA,$iif(!%mcheck,NA,$regsubex($chan(#).mode,/[0-9]/g,)))
  ;output parameters
  var %o %1 %2 %3 %4
  if ($query($nick)) {
    close -m 
  }
  if (!$chstop(#)) && ($regex($1-,/^[!@~.`].+/i)) || ($regex($1-,/http://www.youtube.com/Si)) && (!$chstop(#)) {

    var %stripcom $regsubex($1,/^[!@~.`]/Sgi,),%command $onoff($pcheck(%stripcom))
    hinc $+(-mu,$token($spmparam,1,58)) aflood $wildsite 1

    if ($hget(aflood,$wildsite) < $token($spmparam,2,58)) && (!$hget(lockout,$wildsite)) {
      if ($readini(Hermes.ini,%command,$chan)) { 
        if ($hget(oneresponse,$nick) != %command) {
          .notice $nick $logo(%3,On/off) Command currently disabled in $c2(%3,$chan) $c1(%3,type !set %command on)
          hadd -m oneresponse $nick %command
        }
        halt
      }
      if ($exploitcheckup($2-)) && ($botexempt($nick) == 0) {
        var %cn $nick
        .ignore -u60 $wildsite 
        .msg $Botchan $logo(%cn,Exploit) Detected potential exploit by: $c2(%cn,%cn) $+($c1(%cn,[),$c2(%cn,$address(%cn,2)),$c1(%cn,])) $c1(%cn,on) $c2(%cn,$chan) $c1(%cn,Ignored for) $c2(%cn,60) $c1(%cn,seconds) $c2(%cn,$1-) 
        halt 
      }
      if ($regex($1,/^[ $+ %trigger $+ ](rsp|rsplayers)$/Si)) {
        var %r $+(rsp.,$right($ticks,5))
        hadd -m %r output %o
        hadd %r colour %3
        sockopen %r runescape.com 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]l(oot)?s(hare)?$/Si)) {
        var %l $+(ls.,$right($ticks,5))
        hadd -m %l output %o
        hadd %l colour %3
        sockopen %l runescape.com 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](rs|runescape)news$/Si)) {
        var %rn $+(rsnews.,$right($ticks,5))
        hadd -m %rn output %o
        hadd %rn colour %3
        sockopen %rn beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]name(check)?/Si)) {
        if ($len($2-) >= 12) || (!$2) {
          .notice $nick $logo(%3,Name) You must specify a Runescape username, this must be below 12 characters
          halt
        }
        var %n $+(ncheck.,$right($ticks,5))
        hadd -m %n output %o
        hadd %n colour %3
        hadd %n name $fname($2-)
        sockopen %n rscript.org 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]stats/Si)) { 
        var %st $+(st.,$right($ticks,5)),%address $address($nick,3),%elg $remove($regsubex($2-,/[a-zA-Z0-9_]/gi,),$chr(32)),$&
          %num $wildtok($2-,$+(*,%elg,*),1,32),%nick $iif($rini(Defname,%address),$v1,$nick)
        hadd -m %st output %o
        hadd %st colour %3
        hadd %st rsn $iif(!$2,%nick,$iif(!%elg,$fname($2-),$iif($rini(Defname,%address) && !%elg,$v1,$iif($3,$token($2-,1,$asc(%elg)),%nick))))
        hadd %st prsn $iif($rini(Privacy,%address) && !$2,Hidden,$hget(%st,rsn))
        hadd %st errorout .notice $nick 
        hadd %st elg $iif(%num && %elg,$+(%elg,.,$remove(%num,=,>,<)))
        sockopen %st hiscore.runescape.com 80
      }
      elseif ($skill($mid($1-,2))) && ($regex($1,/^[ $+ %trigger $+ ]/Si)) && (!$regex($1,/^[ $+ %trigger $+ ](def?name|define|fml)/Si)) { 
        var %st $+(st.,$right($ticks,5)),%address $address($nick,3)
        hadd -m %st output %o
        hadd %st colour %3
        hadd %st rsn $fname($iif(!$wildtok($2-,#*,1,32),$iif(!$2,$iif($rini(Defname,%address),$v1,$nick),$2-), $&
          $iif(!$3,$iif($rini(Defname,%address),$v1,$nick),$iif(#* iswm $3,$2,$3-))))
        hadd %st prsn $iif($rini(Privacy,%address) && !$2,Hidden,$hget(%st,rsn))
        hadd %st goal $iif(!$wildtok($2-,#*,1,32),no,$iif($remove($wildtok($2-,#*,1,32),$chr(35)) && $v1 isnum 4-99,$v1,99))
        hadd %st skill $skill($mid($1-,2))   
        hadd %st errorout .notice $nick 
        sockopen %st hiscore.runescape.com 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]cmb-est$/Si)) { 
        if (!$2 || !$8 || $regex($2-,/[a-zA-Z_]/i)) {
          .notice $nick $logo(%3,Cmb-est) Please specify the combat stats in this order: A S D H R P M (SU)
        }
        else {
          var %cmbstats $2-9
          $output(%o $logo(%3,Cmb-est) Level: $c2(%3,$cmb(%cmbstats)) $c1(%3,F2P:) $c2(%3,$token($cmb($token(%cmbstats,1-7,32)),1,32)) $c1(%3,ASDCRPM(SU)) $c2(%3,$remove(%cmbstats,$chr(45)))))
          if ($($+($,nextlevel,$chr(40),%cmbstats,$chr(41),.,$nick),2)) { 
            var %v1 $v1
            $output(%o $logo(%3,Cmb-est) Next level in: %v1))
          }
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]co?mba?t?%?/Si)) { 
        var %st $+(st.,$right($ticks,5)),%address $address($nick,3)
        hadd -m %st output %o
        hadd %st colour %3
        hadd %st rsn $iif(!$2,$iif($rini(Defname,%address),$v1,$nick),$fname($2-))
        hadd %st prsn $iif($rini(Privacy,%address) && !$2,Hidden,$hget(%st,rsn))
        hadd %st errorout .notice $nick 
        hadd %st cmb $iif(*% iswm $1,cmbperc,yes)
        sockopen %st hiscore.runescape.com 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](high|low)/Si)) { 
        var %h $mid($1,2),%st $+(st.,$right($ticks,5)),%address $address($nick,3)
        hadd -m %st rsn $iif(!$2,$iif($rini(Defname,%address),$v1,$nick),$fname($2-))
        hadd %st prsn $iif($rini(Privacy,%address) && !$2,Hidden,$hget(%st,rsn))
        hadd %st output %o
        hadd %st colour %3
        hadd %st hl $iif(%h == highlow,$v2,$iif(%h == high,$v2,low))  
        hadd %st errorout .notice $nick 
        sockopen %st hiscore.runescape.com 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](le?ve?l|exp)( |$)/Si)) {
        if (!$2) {
          $output(%o $logo(%3,xp) $c1(%3,Syntax: !exp lvl))
        }
        else {
          var %n $rp($2)
          $output(%o $logo(%3,Exp) $c1(%3,Exp: %n =) $c2(%3,$lvl(%n)) $iif(%n < 126,$c1(%3,|) $c1(%3,Lvl: %n =) $c2(%3,$bytes($exp(%n),db)))))  
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]mylist/Si)) {
        if (!$3) {
          remini Mylist.ini $address(%3,2) $skill($2)
          $output(%o $logo(%3,Mylist) paramaters for $c2(%3,$address($nick,2)) $c1(%3,reset))
        } 
        elseif ($count($3-,$chr(44)) <= 7) && ($skill($2)) {
          var %i $numtok($3-,44)
          var %n 1,%s $skill($2),%skill $iif($regex($skill($2),/(attack|strength|defence)/Si),combat,$skill($2))
          while (%n <= %i) { 
            var %item $regsubex($token($3-,%n,44),/^(.)/S,$upper(\t)),%itemlist %itemlist %item $+ $iif(%n < %i,$chr(44))
            var %str $replace($3-,$chr(44),$chr(64))        
            if ($regex(%str,/ $+ $token(%str,%n,64) $+ $/gSi) > 1) {
              var %err repeat
              break
            }
            var %x $+(%item,:,$readini(Params.ini,n,%skill,$replace(%item,$chr(32),_)),`)
            var %errlist %errlist $iif(!$readini(Params.ini,n,%skill,$replace(%item,$chr(32),_)),$c2(%3,%item) $+ $chr(44))
            var %err %err $iif(!$readini(Params.ini,n,%skill,$replace(%item,$chr(32),_)),n/a)
            var %a %a %x
            inc %n
          }
          if (%err == repeat) {
            $output(%o $logo(%3,Mylist) Do not repeat items $c2(%3,Please try setting your list again))
          }
          elseif (*n/a* iswm %err) {
            $output(%o $logo(%3,Mylist) %errlist $c1(%3,not found) $c2(%3,Please try setting your list again))
          }
          elseif (*n/a* !iswm %err) { 
            writeini Mylist.ini $address(%3,2) %s %a
            $output(%o $logo(%3,Mylist) set to: $c2(%3,%itemlist) $c1(%3,for) $c2(%3,$address(%3,2)))
          }
        }
        else {
          $output(%o $logo(%3,Mylist) You must specify 7 items or less $chr(124) $c2(%3,Syntax:) $c1(%3,!mylist skill $str(item $+ $chr(44),6) $+ item) $&
            $chr(124) $c2(%3,or you can reset skill parameters with:) $c1(%3,!mylist skill default))
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]rsn/Si)) { 
        var %address $address($iif($2,$2,$nick),3)
        if ($rini(Privacy,%address)) {
          $output(%o $logo(%3,Rsn) The Runescape name associated with the address $c2(%3,$rini(Defname,%address)) $c1(%3,is) $c2(%3,Hidden))
        }
        else {
          if ($rini(Defname,%address)) { 
            $output(%o $logo(%3,Rsn) The Runescape name associated with the address $c2(%3,%address) $c1(%3,is) $c2(%3,$rini(Defname,%address))) 
          }
          elseif (!%address) || ($2 !ison #) { 
            $output(%o $logo(%3,Rsn) The person must be in the channel for you too lookup their Runescape name!)
          }
          else { 
            $output(%o $logo(%3,Rsn) No Default Rsn set for $c2(%3,%address)) 
          }
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](set|def(ault|ine)?)name/Si)) {
        if ($len($2-) <= 12) && ($2) {
          var %n $fname($remove($2-,$,#,%,^,&,*,.))
          writeini default.ini Defname $address($nick,3) %n
          .notice $nick $logo(%3,Defname) $c2(%3,Default username is now $c1(%3,$+(%n,.)) $c2(%3,Username associated with address:) $c1(%3,$address($nick,3)))
        }
        else {
          .notice $nick $logo(%3,Error) $c2(%3,Syntax: !defname <rsusername>)
          halt
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]privacy/Si)) { 
        if ($2 == on) && (!$rini(Privacy,$address($nick,3))) { 
          writeini default.ini Privacy $address($nick,3) on
          .notice $nick $logo(%3,Privacy) Privacy now on for $c2(%3,$address($nick,3))
        }
        elseif (!$2) || ($2 == off) && ($rini(Privacy,$address($nick,3))) {
          remini default.ini Privacy $address($nick,3)
          .notice $nick $logo(%3,Privacy) Privacy now off for $c2(%3,$address($nick,3))
        }
        else { 
          .notice $nick $logo(%3,Privacy) Privacy settings currently already $c2(%3,$rini(Privacy,$address($nick,3)))
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]rank/Si)) {
        if (!$skill($3)) || ($rp($2) <= 0) {
          .notice $nick $logo(%3,Rank) $c1(%3,you must specify a skill and a number greater than 0 |) $c2(%3,Syntax: !rank position skill) $c1(%3,e.g. !rank 1 attack)
          halt 
        } 
        var %r $+(rank.,$right($ticks,5))
        hadd -m %r table $iif($skill($3) == overall,0,$s2($v1))
        hadd %r position $rp($2)
        hadd %r output %o
        hadd %r colour %3
        sockopen %r beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]compare/Si)) {
        if (!$skill($2)) || (!$3) || (!$4 && !$readini(Default.ini,n,Defname,$address($nick,3))) {
          .notice $nick $logo(%3,Compare) $c1(%3,Syntax:) $c2(%3,!compare <skill> <user1> <user2>) $c1(%3,with defname set:) $c2(%3,!compare <skill> <user2>)
          halt 
        } 
        var %c $+(compare.,$right($ticks,5))
        hadd -m %c skill $skill($2)
        hadd %c user1 $fname($iif(!$4,$rini(Defname,$address($nick,3)),$3))   
        hadd %c user2 $fname($iif(!$4,$3,$4))
        hadd %c output %o
        hadd %c colour %3
        sockopen %c beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]Charm(s)?/Si)) {
        var %seperate $c1(%3,|)
        if ($2) {
          if (!$5) || ($2 >= 99) { 
            .notice $nick $logo(%3,Charms) You must specify a starting level 
            halt
          }
          if ($3 > 0) || ($4 > 0) {
            $output(%o $logo(%3,Charms) $iif($3 > 0,$charmdisplay(%3,$2,$3,Gold).Charms) $iif($4 > 0,%seperate $charmdisplay(%3,$2,$v1,Green).Charms)) 
          }
          if ($5 > 0) || ($6 > 0) {
            $output(%o $logo(%3,Charms) $iif($5 > 0,$charmdisplay(%3,$2,$v1,Crimson).Charms) $iif($6 > 0,%seperate $charmdisplay(%3,$2,$v1,Blue).Charms)) 
          }
        }
        else {
          $output(%o $logo(%3,Charms) $c1(%3,Syntax) $c1(%3,!charms Level) 7Number-Of-Gold 3Number-Of-Green 4Number-Of-Crimson 12Number-Of-Blue)
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](familiar|pouch)/Si)) {
        if ($2) {
          var %f $+(familiar.,$right($ticks,5))
          hadd -m %f familiar $fname($2-).plus
          hadd %f output %o
          hadd %f colour %3
          sockopen %f beardbot.netii.net 80 
        }
        else {
          .notice $nick $logo(%3,$regml(1)) Syntax: !pouch <familiar name>
        }    
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]pot?(ion)?$/Si)) {
        if ($2) {
          var %p $+(potion.,$right($ticks,5))
          hadd -m %p pot $fname($2-).plus
          hadd %p output %o
          hadd %p colour %3
          sockopen %p beardbot.netii.net 80 
        }
        else {
          .notice $nick $logo(%3,Potion) Syntax: !potion <potion name>
        }    
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]wave$/Si)) {
        if ($2 isnum 1-63) {
          var %w $+(fcaves.,$right($ticks,5))
          hadd -m %w wave $2-
          hadd %w output %o
          hadd %w colour %3
          sockopen %w beardbot.netii.net 80 
        }
        else {
          .notice $nick $logo(%3,Fight Caves) Syntax: !wave <number between 1 & 63>
        }    
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](con)?grat[sz]\b/Si)) {
        if ($skill($2) && $skill($3)) || ($2 isnum && $3 isnum) {
          .notice $nick $logo(%3,Gratz) $c2(%3,Correct syntax is:) $c1(%3,[ $+ %trigger $+ ]gratz <level> <skill>)
          halt
        }
        var %m $+(G.,$right($ticks,6)),%lvl $regsubex($2-,/[A-Za-z]/g,),%t $publictrigger $chan $nick $regsubex($chan(#).mode,/[0-9]/g,),$&
          %skill $remove($regsubex($2-,/[0-9]/g,),$chr(32)),%upto $iif($skill(%skill) == Dungeoneering,119,98),$&
          %capelvl $iif($skill($iif($2 isnum,$3,$2)) == Dungeoneering,120,99)
        hadd -m %m lvl $iif($2 isnum,$v1,$3) 
        hadd %m skill $iif($skill($2),$v1,$skill($3))
        if ($skill(%skill)) && (%lvl <= %upto) {
          $output(%t $logo(%3,4G14r10a7t14z7) $c2(%3,*\@/*\@/*\@/*) $c1(%3,Congratulations for achieving $&
            $iif($istok(attack agility overall,$regml(1),32),an,a)) $c2(%3,$skill($hget(%m,skill))) $c1(%3,level of) $&
            $c2(%3,$hget(%m,lvl)) $c1(%3,$+($nick,!)) $c2(%3,*\@/*\@/*\@/*))
          hfree %m
        }  
        elseif (%lvl isnum 34-2496) && ($regex(%skill,/(overall|total)$/)) {
          $output(%t $logo(%3,4G14r10a7t14z7) $c2(%3,*\@/*\@/*\@/*) $c1(%3,Congratulations for achieving $&
            $iif($istok(attack agility overall,$regml(1),32),an,a)) $c2(%3,$regml(1)) $c1(%3,level of) $c2(%3,$hget(%m,lvl)) $&
            $c1(%3,$+($nick,!)) $c2(%3,*\@/*\@/*\@/*))
          hfree %m
        }
        elseif (%lvl isnum 4-138) && ($regex(%skill,/(combat|cmb)$/)) {
          $output(%t $logo(%3,4G14r10a7t14z7) $c2(%3,*\@/*\@/*\@/*) $c1(%3,Congratulations for achieving a) $&
            $c2(%3,Combat) $c1(%3,level of) $c2(%3,$hget(%m,lvl)) $c1(%3,$+($nick,!)) $c2(%3,*\@/*\@/*\@/*)) 
          hfree %m
        }
        elseif (%lvl isnum %capelvl) && ($skill(%skill)) {
          $output(%t $logo(%3,4G14r10a7t14z7) $c2(%3,*\@/*\@/*\@/*) $c1(%3,Congratulations for achieving $&
            $iif($istok(attack agility overall,$hget(%m,skill),32),an,a)) $c2(%3,$skill($hget(%m,skill))) $c1(%3,level of) $&
            $c2(%3,$hget(%m,lvl)) $c1(%3,$+($nick,!)) $c2(%3,Enjoy that sexy cape and emote!))
          hfree %m
        }
        else {
          .notice $nick $logo(%3,Gratz) $c2(%3,Correct syntax is:) $c1(%3,[ $+ %trigger $+ ]gratz <level> <skill>)
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]F(airy(Ring)?|R)( |$)/Si)) {
        if (!$2) { 
          .notice $nick $logo(%3,Fairy) Please state a location or ring name
          halt
        }
        var %Ring $rings($2-)
        if ($regex($2,/(^(S|C)ent(re|er)|West|East|slay(er)?|Farm(ing|er)?)$/Si)) {
          var %Codes $gettok(%Ring,0,64)
          while (%Codes) {
            tokenize 64 $gettok(%Ring,%Codes,45)
            var %display $c1(%3,$1) $c2(%3,$2) @ %display 
            dec %Codes
          }
          tokenize 64 %Display 
          $output(%o $logo(%3,Fairy) $$1-8)
          $output(%o $$9-)
        }
        else {
          if (%Ring == Error) {
            if ($len($2-) == 3) && (!$regex($2-,/^[a-d][i-l][p-s]$/i)) {
              $output(%o $logo(%3,Fairy) $c2(%3,Invalid code. Valid Codes are) $c1(%3,ABCD) $c2(%3,followed by) $c1(%3,IJKL) $c2(%3,followed by) $c1(%3,PQRS))
            }
            else {
              $output(%o $logo(%3,Fairy) $c2(%3,I was unable to find a code for the location) $c1(%3,$qt($2-)) $c2(%3,in my database.))
            }
          }
          else {
          $output(%o $logo(%3,Fairy) $c1(%3,$gettok(%Ring,1,64)) $c2(%3,$gettok(%Ring,2,64))) }
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](gu|geupdate)$/Si)) {
        var %gu $+(geup.,$right($ticks,5))
        hadd -m %gu output %o
        hadd %gu colour %3
        sockopen %gu rscript.org 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]ge/Si)) && (!$regex($1,/geup/Si)) {
        if (!$2) {
          .notice $nick $logo(%3,GE) $c1(%3,Please specify an item to lookup) 
          halt 
        }
        var %g $+(ge.,$right($ticks,5)),%e $iif($istok($2,-e,32),&E=y)
        hadd -m %g item $iif($remove($iif(%e,$3,$2),k,m) isnum,$fname($iif(%e,$4-,$3-)).plus,$fname($iif(%e,$3-,$2-)).plus)
        hadd %g quan $iif($iif(%e,$4,$3) && $rp($iif(%e,$3,$2)) isnum,$rp($v1))
        hadd %g exact %e
        hadd %g output %o
        hadd %g colour %3
        sockopen %g beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]cs/Si)) {
        if (!$2 || !$3 || $regex($2,/[a-zA-Z]/i)) {
          .notice $nick $logo(%3,CS) Syntax: $c2(%3,[ $+ %trigger $+ ]cs number item) $c1(%3,e.g. !cs 5 bgs)
          halt 
        }
        var %cs $+(cs.,$right($ticks,5))
        hadd -m %cs split $2
        hadd -m %cs search $3
        hadd %cs output %o
        hadd %cs colour %3
        sockopen %cs beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]spell/Si)) {
        if ($2) {
          var %s $+(spell.,$right($ticks,5)),%n $remove($2,k,m,b,t)
          hadd -m %s spell $fname($iif(%n isnum,$3-,$2-)).plus
          hadd %s casts $iif(%n isnum,$rp($2),1)
          hadd %s output %o
          hadd %s colour %3
          sockopen %s beardbot.netii.net 80 
        }
        else { 
          .notice $nick $logo(%3,Error) Syntax: !spell <casts> <name> $c2(%3,||) $c1(%3,!spell 150 wind strike)
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]drops/Si)) {
        if ($2) {
          var %d $+(drops.,$right($ticks,5))
          hadd -m %d npc $fname($2-).plus
          hadd %d output %o
          hadd %d colour %3
          sockopen %d beardbot.netii.net 80 
        }
        else { 
          .notice $nick $logo(%3,Error) Syntax: !drops <npc name>
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]world/Si)) {
        if ($2 isnum 1-171) {
          var %w $+(world.,$right($ticks,5))
          hadd -m %w world $2
          hadd %w output %o
          hadd %w colour %3
          sockopen %w beardbot.netii.net 80
        }
        else {
          .notice $nick $logo(%3,Error) You must provide a valid world to lookup 
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]clan/Si)) {
        var %cl $+(clan.,$right($ticks,5))
        hadd -m %cl user $fname($iif(!$2,$iif($rini(Defname,$address($nick,3)),$v1,$nick),$2-))
        hadd %cl output %o
        hadd %cl colour %3
        sockopen %cl runehead.com 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]ml$/Si)) {
        if (!$2) {
          .notice $nick $logo(%3,Memberlist) $c1(%3,Please specify a clan to lookup) 
          halt 
        }
        var %ml $+(ml.,$right($ticks,5))
        hadd -m %ml clan $replace($2-,$chr(32),$chr(95)))
        hadd %ml output %o
        hadd %ml colour %3
        sockopen %ml runehead.com 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]alog/Si)) {
        var %al $+(alog.,$right($ticks,5))
        hadd -m %al rsn $iif(!$2,$iif($rini(Defname,$address($nick,3)),$v1,$nick),$fname($2-))
        hadd %al output %o
        hadd %al colour %3
        sockopen %al beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](npc|monster)/Si)) {
        if (!$2) {
          .notice $nick $logo(%3,Npc) $c1(%3,Correct syntax is:) $c2(%3,!npc <monster name>) 
          halt 
        }
        var %m $+(npcid.,$right($ticks,5))
        hadd -m %m output %o
        hadd %m colour %3
        hadd %m search $replace($2-,$chr(32),+)
        sockopen %m www.tip.it 80 
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]quest/Si)) {
        if (!$2) {
          .notice $nick $logo(%3,Quest) $c1(%3,Correct syntax is) $c2(%3,!quest <quest>) 
          halt 
        }
        var %q $+(quest.,$right($ticks,5))
        hadd -m %q output %o
        hadd %q colour %3
        hadd %q search $replace($2-,$chr(32),+)
        sockopen %q beardbot.netii.net 80  
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](item|istats)/Si)) {
        if (!$2) {
          .notice $nick $logo(%3,Item) $c1(%3,Correct syntax is:) $c2(%3,!item <item>) 
          halt 
        }
        var %i $+(item.,$right($ticks,5))
        hadd -m %i output %o
        hadd %i colour %3
        hadd %i item $replace($2-,$chr(32),+)
        sockopen %i beardbot.netii.net 80  
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]alch/Si)) {
        if (!$2) {
          .notice $nick $logo(%3,Alch) $c1(%3,Correct syntax is:) $c2(%3,!alch <item>) 
          halt 
        }
        var %a $+(alch.,$right($ticks,5))
        hadd -m %a output %o
        hadd %a colour %3
        hadd %a item $replace($2-,$chr(32),+)
        sockopen %a beardbot.netii.net 80  
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]track/Si)) {
        if (!$skill($2-)) {
          var %trn $+(tracker.,$right($ticks,5)),%defname $iif($rini(Defname,$address($nick,3)),$v1,$nick)
          var %time $mid($wildtok($2-,@*,1,32),2)
          hadd -m %trn nick $fname($iif(!$2,%defname,$iif(!$3 && %time,%defname,$remove($regsubex($2-,/(.+)@\b/Si,\1),%time))))
          hadd %trn pnick $iif($rini(Privacy,$address($nick,3)) && !$2,Hidden,$hget(%trn,nick))
          hadd %trn time $duration($iif(!$2 || !%time,1w,%time)) 
          hadd %trn t $duration($hget(%trn,time))
          hadd %trn output %o
          hadd %trn colour %3
          sockopen %trn rscript.org 80
        }
        elseif ($skill($2-)) { 
          var %sn $+(track.,$right($ticks,5)),%dfn $rini(Defname,$address($nick,3)),%n $nick,%a $iif($wildtok($2-,@*,1,32),$remove($v1,@),1wk)
          if (*secs* iswm $duration(%a)) || ($left(%a,1) !isnum) {
            .notice $nick $logo(%3,Track) $c2(%3,syntax: [!@.~]track <skill> <rsn> <period>) $c1(%3,e.g. !track magic Riffpilgrim @4w) 
            halt 
          }
          hadd -m %sn nick $fname($iif(!$3 && %dfn,%dfn,$iif(!$3 && !%dfn,%n,$iif(!$4,$iif(@ isin $3,$iif(%dfn,$v1,%n),$3),$3))))
          hadd %sn pnick $iif($rini(Privacy,$address($nick,3)) && !$2,Hidden,$hget(%sn,nick))     
          hadd -m %sn time $duration($iif(!%a,1d,%a))
          hadd -m %sn t $iif(!%a,1wk,%a) 
          hadd %sn skill $skill($2) 
          hadd %sn output %o
          hadd %sn colour %3
          sockopen %sn rscript.org 80
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]rswiki/Si)) {
        if (!$2) {
          .notice $nick $logo(%3,Rswiki) $hlink(http://runescape.wikia.com)
          halt
        }
        var %r $+(rswiki.,$right($ticks,5))
        hadd -m %r output %o
        hadd %r colour %3
        hadd %r query $2-
        sockopen %r beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]fml$/Si)) {
        var %f $+(fml.,$right($ticks,5))
        hadd -m %f output %o
        hadd %f colour %3
        sockopen %f beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]tfln$/Si)) {
        var %tf $+(tfln.,$right($ticks,5))
        hadd -m %tf output %o
        hadd %tf colour %3
        sockopen %tf beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]bash/Si)) {
        var %b $+(bash.,$right($ticks,5))
        hadd -m %b output %o
        hadd %b colour %3
        $iif($2,hadd %b id $remove($2,$chr(35)))
        sockopen %b beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](urban|ud)/Si)) {
        if (!$2) {
          .notice $nick $logo(%3,Urban) $c1(%3,Please specify a term to lookup) 
          halt 
        }
        var %u $+(urban.,$right($ticks,5))
        hadd -m %u output %o
        hadd %u colour %3
        hadd %u word $replace($regsubex($2-,/^(.)/S,$upper(\t)),$chr(32),+)
        sockopen %u beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]weather/Si)) {
        if ($2) {
          var %w $+(weather.,$right($ticks,5))
          hadd -m %w output %o
          hadd %w colour %3
          hadd %w location $fname($2-)
          sockopen %w beardbot.netii.net 80
        }
        else {
          .notice $nick $logo(%3,Weather) $c1(%3,Please specify a location to lookup) 
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](halo|h3)/Si)) {
        if (!$2) && (!$readini(hermes.ini,ConsoleDefname,$address($nick,3))) {
          .notice $nick $logo(%3,Halo3) $c1(%3,Please specify a gamertag to lookup) 
          halt 
        }
        var %h $+(halo.,$right($ticks,5)),%cdn $readini(hermes.ini,ConsoleDefname,$address($nick,3))
        hadd -m %h output %o
        hadd %h colour %3
        hadd %h user $iif(!$2 && %cdn,%cdn,$replace($regsubex($2-,/^(.)/S,$upper(\t)),$chr(32),+)))
        sockopen %h beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](xbl|gc)/Si)) {
        if (*-d* iswm $2) {
          if (!$3) {
            remini Hermes.ini ConsoleDefname $address($nick,3)
            $output($logo(%3,ConsoleDefname) $c1(%3,Default console name unset))
            halt
          }
          var %d on
          writeini Hermes.ini ConsoleDefname $address($nick,3) $&
            $remove($fname($3-).plus,$,#,%,^,&,*)
          $output($logo(%3,ConsoleDefname) $c2(%3,$qt($3-)) $c1(%3,set as default console name))
        }
        if (!$2) && (!$readini(hermes.ini,ConsoleDefname,$address($nick,3))) {
          .notice $nick $logo(%3,Xbl) $c1(%3,Please specify a gamertag to lookup) 
          halt 
        }
        var %x $+(xbl.,$right($ticks,5)),%cdn $readini(hermes.ini,ConsoleDefname,$address($nick,3)) 
        hadd -m %x output %o
        hadd %x colour %3
        hadd %x user $iif(!$2 && %cdn,%cdn,$fname($iif(%d,$3-,$2-)).plus)
        sockopen %x beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](gf|googlefight)/Si)) {
        if (!$2) || (!$3) {
          .notice $nick $logo(%3,Googlefight) $c1(%3,You have to state two words to lookup) 
          halt 
        }
        var %gf $+(gf.,$right($ticks,5))
        hadd -m %gf output %o
        hadd %gf colour %3
        hadd %gf word1 $2
        hadd %gf word2 $3
        sockopen %gf beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]cyborg/Si)) {
        if ($len($2-) <= 10) { 
          var %c $+(cyborg.,$right($ticks,5))
          hadd -m %c output %o
          hadd %c colour %3
          hadd %c word $fname($2-)
          sockopen %c beardbot.netii.net 80
        }
        else {
          .notice $nick $logo(%3,Cyborg) Names can't have more than 10 letters. 
        }
      }
      elseif ($regex($1,/http://www.youtube.com/Si)) {
        var %yt $+(ytinfo.,$right($ticks,5))
        hadd -m %yt output $publictrigger $chan $nick $regsubex($chan(#).mode,/[0-9]/g,\1)
        hadd %yt colour %3
        hadd %yt id $gettok($1,2,61)
        sockopen %yt beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](yt|youtube)/Si)) {
        if (!$2) {
          $output(%o $logo(%3,Youtube) Please state something to search for)
        }
        var %yt $+(yt.,$right($ticks,5))
        hadd -m %yt output %o
        hadd %yt colour %3
        hadd %yt search $fname($2-)
        sockopen %yt beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]google/Si)) {
        if (!$2) {
          $output(%o $logo(%3,Google) Please state something to search for)
          halt
        }   
        var %g $+(google.,$right($ticks,5))
        hadd -m %g output %o
        hadd %g colour %3
        hadd %g search $fname($2-).plus
        sockopen %g beardbot.netii.net 80
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](version|update)$/Si)) {
        var %v $+(version.,$right($ticks,5))
        if ($regml(1) == update) && ($chan == $botchan) && ($isalias(update)) {
          hadd -m %v update y
          .msg $chan $logo(%3,Update) Checking for updates
        }
        hadd -m %v output %o
        hadd %v colour %3
        sockopen %v beardbot.netii.net 80  
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]define/Si)) {
        if ($2) {
          var %d $+(define.,$right($ticks,5))
          hadd -m %d output %o
          hadd %d colour %3
          hadd %d search $fname($2-).plus
          sockopen %d www.thefreedictionary.com 80
        }
        else { 
          .notice $nick $logo(define) Please provide something to lookup!
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](site|setsite|delsite)/Si)) {
        var %ini $readini(Hermes.ini,n,chanSite,$chan)
        if ($regml(1) == setsite) {
          writeini Hermes.ini chanSite $chan $2-
          $output(%o,$logo(%3,Site) Site for $c2(%3,$chan) $c1(%3,set to) $hlink($2-))
        }
        elseif ($regml(1) == delsite) && (%ini) {
          remini Hermes.ini chanSite $chan
          $output(%o,$logo(%3,Site) Site for $c2(%3,$chan) $c1(%3,removed))
        }
        elseif ($regml(1) == site) {
          if (%ini) {  
            $output(%o,$logo(%3,Site) Site for $c2(%3,$chan) $+ $c1(%3,:) $hlink(%ini))
          }
          else {
            $output(%o,$logo(%3,Site) No Site set for $c2(%3,$chan))
          }
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]ascii/Si)) {
        var %chr $+($,+,$chr(40),$mid($regsubex($2-,/(.)/g,$!chr( $+ $asc(\t) $+ ) $+ $chr(44)),1,-1),$chr(41))
        $output(%o $logo(%3,Ascii) $c1(%3,$2-) $c2(%3,converts to) $c1(%3,%chr))
      }
      elseif ($regex($1-,/^[ $+ %trigger $+ ]calc(ulator)?|`[()0-9]|`(sin|cos|tan|sqrt|log|lvl|pi)/Si)) {
        var %e $iif(` == $left($1,1),$mid($1-,2),$2-)
        if (!%e) {
          $output(%o $logo(%3,Calc) $c1(%3,Please state an equation to calculate))
        }
        else { 
          var %rep $replace(%e,x,*,pi,$pi,lvl,exp)
          var %pt1 $regsubex(%rep,/(sin|cos|tan|sqrt|log|exp)[\[\(](\d+)[\)\]](.*)/Sgi,$($+($,\1,$chr(40),$iif(exp isin \1 && \2 > 126,$v2,\2),$chr(41)),2))   
          var %pt2 $regsubex($regml(3),/(?<![\(\)\])([^-+/*](.*))/g,$+($chr(40),\1,$chr(41)))
          var %x $rp(%pt1 $+ %pt2)
          $output(%o $logo(%3,Calc) $+($c2(%3,%e),=,$c1(%3,$bytes(%x,bd)),$chr(32)) $c2(%3,$sn(%x)))
        }
      }
      elseif ($food($1)) && ($chan) {
        var %target $iif($2 && $2 ison $chan,$2,$nick),%i $publictrigger $chan $nick $regsubex($chan(#).mode,/[0-9]/g,)
        $output(%i gives %target $food($1)).desc
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]8ball/Si)) {
        if ($2) {
          var %i $publictrigger $chan $nick $regsubex($chan(#).mode,/[0-9]/g,)
          var %string No!`yes maybe...`of course!`Are you crazy?!`How should I know?`I don't care`undoubtedly so` $+ $&
            it seems possible`Hell no`anything could happen`probably`definately`There is a good chance`Of course not`Yeah!`Try Again Later
          $output(%i $logo(%3,8ball) $qt($2-) $chr(124) The magic 8ball answers:  $c2(%3,$token(%string,$r(1,$numtok(%string,96)),96)))
        }
        else { 
          .notice $nick $logo(%3,8ball) A question needs to be provided for me to give an answer!
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]onceaminute/Si)) {
        if ($hget(timeleft,$nick)) {
          .notice $nick $c1(%3,Sorry, you need to wait) $c2(%3,$duration($hget(timeleft,$nick))) $c1(%3,before you can do that.)
          return
        }
        $output(%o $c1(%3,Yay you did something that you can only do once a minute!) $c2(%3,YOU ROCK!))
        hadd -mz timeleft $nick 60
      }
      elseif ($regex($1,/^[~]go/Si)) && ($chan == $botchan) {
        if ($2 == join) {
          .join $3
          $iif(!$chstop($3),.msg $3 $iif($readini(Hermes.ini,settings,invmsg),$c2(%3,$remove($v1,$chr(96),$chr(126))),$c1(%3,Easy to use Runescape bot "Hermes") $c2(%3,Hello world!)))
          .msg $botchan $logo(%3,Join) Sent by $nick $address($nick,2) to channel $3
        }
        elseif ($2 == part) {
          .part $3
          .msg $botchan $logo(%3,part) $me has left $3 $c2(%3,forced by $nick)
        }
      }
      elseif ($regex($1,/^[~](blacklist|bl)/Si)) && ($chan == $botchan) {
        if ($2 == add) {
          writeini Hermes.ini Blacklist $3 $4-
          .notice $nick $logo(%3,Hermes) Blacklisted $c2(%3,$3) $c1(%3,Reason:) $c2(%3,$iif($4,$4-,no reason)) 
        }
        elseif ($2 == del) {
          remini Hermes.ini Blacklist $3 
          .notice $nick $logo(%3,Hermes) Removed $c2(%3,$3) $c1(%3,from blacklist)
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](part|gtfo)/Si)) {
        hadd -mu30 itimer $chan on
        if ($nick isop #) || ($nick ishop #) && ($2 == $me) {
          .part $chan $c1(%3,Requested by) $c2(%3,$nick)
          .msg $botchan $logo(%3,Part) $c1(%3,I have parted:) $c2(%3,$chan) $c1(%3,Requested by:) $c2(%3,$nick) $+($c2(%3,[),$c1(%3,$address($nick,2)),$c2(%3,]))
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](command(s)?|control)$/Si)) {
        $output(%o $logo(%3,Commands) $c1(%3,http://hermes.beard-bot.co.uk))
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ]set/Si)) && ($onoff($2)) { 
        if ($nick isop $chan) { 
          if ($istok($3-,off,32)) && (!$readini(Hermes.ini,$onoff($2),$chan)) {
            writeini Hermes.ini $onoff($2) $chan off
            .notice $nick $logo(%3,On/off) The feature: $c2(%3,$onoff($2)) $c1(%3,has been disabled in) $c2(%3,$chan)
          }
          elseif ($istok($3-,on,32)) && ($readini(Hermes.ini,$onoff($2),$chan)) { 
            remini Hermes.ini $onoff($2) $chan
            .notice $nick $logo(%3,On/off) The feature: $c2(%3,$onoff($2)) $c1(%3,has been enabled in) $c2(%3,$chan)
          }
        }
        else { 
          .notice $nick $logo(%3,On/off) Only ops can change channel settings
        }
      }
      elseif ($regex($1,/^[ $+ %trigger $+ ](set|my)colou?r/Si)) {
        var %n $nick
        if ($2 && $3 isnum 1-15) {
          writeini Hermes.ini colour1 $address(%n,3) $right($+(0,$2),2)
          writeini Hermes.ini colour2 $address(%n,3) $right($+(0,$3),2)
          .notice %n $logo(%n,Mycolour) 14Your default colours have been set to $c1(%n,Example) 14and $c2(%n,Example)
        }
        else { 
          var %x 1
          while (%x <= 15) {
            var %a %a  $+ $iif(%x == 1,14,1) $+ , $+ %x %x
            inc %x
          }
          .notice %n $logo(%n,Mycolour) Please choose two colours from 1 to 15: %a
        }
      }
    }
  }
  else {
    hinc $+(-mz,$locktime) lockout $wildsite
  }
}
on *:sockopen:*: {
  if ($sockerr) {
    var %cn $hget($sockname,colour)
    .msg $botchan $logo(%cn,SocketError) $c2(%cn,$sockname) $c1(%cn,$sock($sockname).wsmsg) 
    hfree $sockname 
    sockclose $sockname
    halt
  }
  var %path,%host beardbot.netii.net,%type $gettok($sockname,1,46),%% sockwrite -nt $sockname
  if (%type == rsnews) {
    var %path /parsers/rsnews.php
  }
  elseif (%type == rank) {
    var %path $+(/parsers/rank.php?&table=,$hget($sockname,table),&rank=,$hget($sockname,position))
  }
  elseif (%type == compare) {
    var %path $+(/parsers/compare.php?user1=,$hget($sockname,user1),&user2=,$hget($sockname,user2))
  }
  elseif (%type == alog) {
    var %path $+(/private%20parsers/alogtest.php?user=,$hget($sockname,rsn))
  }
  elseif (%type == familiar) {
    var %path $+(/parsers/familiars.php?pouch=,$hget($sockname,familiar))
  }
  elseif (%type == potion) {
    var %path $+(/parsers/potions.php?pot=,$hget($sockname,pot))
  }
  elseif (%type == fcaves) {
    var %path $+(/parsers/fcaves.php?wave=,$hget($sockname,wave))
  }
  elseif (%type == quest) {
    var %path $+(/parsers/quest.php?s=,$hget($sockname,search))
  }
  elseif (%type == item) {
    var %path $+(/parsers/item.php?i=,$hget($sockname,item))
  }
  elseif (%type == alch) {
    var %path $+(/parsers/alch.php?item=,$hget($sockname,item))
  }
  elseif (%type == cs) {
    var %path $+(/parsers/cs.php?i=,$hget($sockname,search),&split=,$hget($sockname,split))
  }
  elseif (%type == drops) {
    var %path $+(/parsers/drops.php?npc=,$hget($sockname,npc))
  }
  elseif (%type == ge) {
    var %path $+(/parsers/ge.php?item=,$hget($sockname,item),$iif($hget($sockname,exact),$v1))
  }
  elseif (%type == spell) {
    var %path $+(/parsers/spells.php?spell=,$hget($sockname,spell))
  }
  elseif (%type == world) {
    var %path $+(/parsers/world.php?w=,$hget($sockname,world))
  }
  elseif (%type == rswiki) {
    var %path $+(/parsers/rswiki.php?query=,$hget($sockname,query))
  }
  elseif (%type == fml) {
    var %path /parsers/fml.php
  }
  elseif (%type == tfln) {
    var %path /parsers/tfln.php?
  }
  elseif (%type == bash) {
    var %path $+(/parsers/bash.php?id=,$hget($sockname,id))
  }
  elseif (%type == urban) {
    var %path $+(/parsers/urban.php?term=,$hget($sockname,word))
  }
  elseif (%type == weather) {
    var %path $+(/parsers/weather.php?location=,$hget($sockname,location))
  }
  elseif (%type == halo) {
    var %path $+(/parsers/Halo3.php?player=,$hget($sockname,user))
  }
  elseif (%type == xbl) {
    var %path $+(/parsers/xbl.php?tag=,$hget($sockname,user))
  }
  elseif (%type == gf) {
    var %path $+(/parsers/gf.php?&w1=,$hget($sockname,word1),&w2=,$hget($sockname,word2))
  }
  elseif (%type == cyborg) {
    var %path $+(/parsers/cyborg.php?acronym=,$hget($sockname,word))
  }
  elseif (%type == ytinfo) {
    var %path $+(/parsers/ytinfo.php?search=,$hget($sockname,id))
  }
  elseif (%type == yt) {
    var %path $+(/parsers/youtube.php?search=,$hget($sockname,search))
  }
  elseif (%type == google) {
    var %path $+(/parsers/google.php?search=,$hget($sockname,search))
  }
  elseif (%type == botnews) {
    var %path /parsers/twitter.php?page=hermesbot
  }
  elseif (%type == version) {
    var %path /parsers/version.php
  }
  elseif (%type == define) {
    var %path $+(/,$hget($sockname,search)),%host www.thefreedictionary.com
  }
  elseif (%type == rsp) {
    var %path /title.ws,%host runescape.com
  }
  elseif (%type == ls) {
    var %path /slu.ws?j=1&m=1 
  }
  elseif (%type == st) {
    var %path $+(/index_lite.ws?player=,$hget($sockname,rsn)),%host hiscore.runescape.com
  }
  elseif (%type == ncheck) {
    var %path $+(/flookup.php?type=namecheck&name=,$hget($Sockname,name)),%host rscript.org
  }
  elseif (%type == geup) {
    var %path /lookup.php?type=geupdate
  }
  elseif (%type == tracker) {
    var %path $+(/flookup.php?type=track&user=,$hget($sockname,nick),&time=,$hget($sockname,time),&skill=all)
  }
  elseif (%type == track) {
    var %path $+(/flookup.php?type=track&user=,$hget($sockname,nick),&time=,$hget($sockname,time),$chr(44),$duration(4w), $&
      &skill=,$iif($hget($sockname,skill) == overall,0,$s2($hget($sockname,skill))))
  }
  elseif (%type == clan) {
    var %path $+(/feeds/lowtech/searchuser.php?user=,$hget($sockname,user),&type=2),%host runehead.com
  }
  elseif (%type == ml) { 
    var %path $+(/feeds/lowtech/searchclan.php?search=,$hget($sockname,clan)),%host runehead.com
  }
  elseif (%type == npcid) { 
    var %path $+(/runescape/index.php?rs2monster=&orderby=&keywords=,$hget($sockname,search),&levels=All&race=0),%host www.tip.it
  }
  elseif (%type == npc) {
    var %path $+(/runescape/index.php?rs2monster_id=,$hget($sockname,id))
  }
  if ((%host && %path)) {
    %% GET %path HTTP/1.1
    %% Host: %host
    %% $crlf
  }
}
on *:sockread:*: {
  var %cn $hget($sockname,colour)
  if ($sockerr) {
    .msg $botchan $logo(%cn,SocketError) $c2(%cn,$sockname) $c1(%cn,$sock($sockname).wsmsg) 
    hfree $sockname
    sockclose $sockname
    halt
  }
  if (rsp.* iswm $sockname) {
    var %r
    sockread %r
    if ($regex(%r,/<div id="players"><b>(.*)people/i)) {
      $output($hget($sockname,output) $logo(%cn,Rsplayers) There are currently $c2(%cn,$regml(1)) $c1(%cn,players online)) 
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (ls.* iswm $sockname) {
    var %l,%sn $sockname
    sockread %l
    if (*<td class="m">Members</td>* iswm %l) {
      hadd -m $sockname mf M
    }
    if (*<td class="f">Free</td>* iswm %l) {
      hadd -m $sockname mf F
    }
    if (*World*</a>* iswm %l) {
      hadd -m $sockname world $remove($token(%l,3,32),</a>)
      sockread %l 
    }
    if (title="Y" isin %l) { 
      var %mf $hget($sockname,mf)
      hadd -m $sockname ls $hget($sockname,ls) $+($iif(M isin %mf,`),$c1(%cn,$hget($sockname,world)))
    }
    if (*<br class="clear"/>* iswm %l) {
      tokenize 96 $hget($sockname,ls)
      $output($hget($sockname,output) $logo(%cn,Lootshare worlds) $c2(%cn,F2P:) $c2(%cn,$1 |) $c2(%cn,P2P:) $2-) 
      hfree $sockname
      sockclose $sockname
    }
  }   
  elseif (ncheck.* iswm $sockname) {
    var %n
    sockread %n
    if (*NAMECHECK:* iswm %n) {
      $output($hget($Sockname,output) $logo(%cn,Name check) $c2(%cn,$hget($sockname,name)) $c1(%cn,is) $iif(*NOT* iswm %n,$c2(%cn,unavailable),$c2(%cn,available)))
    }
    if (*SUGGESTIONS:* iswm %n) {
      var %b $pos($gettok(%n,2,58),$chr(44),0),%y $replace($gettok(%n,2,58),$chr(44),$chr(124))
      if (%b != 0) {
        $output($hget($Sockname,output) $logo(%cn,Name suggestions) $replace($remtok(%y,$chr(124),%b,124),$chr(124),$chr(44)))
        hfree $sockname
        sockclose $sockname
      }
      else {
        sockclose $sockname
      }
    }
  }
  elseif (ge.* iswm $sockname) {
    var %a
    sockread %a
    if (*No results* iswm %a) {
      $output($hget($sockname,output) $logo(%cn,GE) $c1(%cn,Your Search For) $c2(%cn,$qt($hget($sockname,item))) $c1(%cn,Was Not Found On The Runescape Grand Exchange Database))
      hfree $sockname
      sockclose $sockname
    }
    elseif (*Single-item:* iswm %a) {
      tokenize 124 $gettok(%a,2-,58)
      var %quan $hget($sockname,quan)
      if (%quan) {
        var %min $calc($rp($4)*$v1),%mid $calc($rp($5)*$v1),%max $calc($rp($6)*$v1)),$&
          %minstring $+(12,$bytes(%min,bd)) $c1(%cn,$sn(%min)),$&
          %midstring $+(03,$bytes(%mid,bd)) $c1(%cn,$sn(%mid)),$&
          %maxstring $+(04,$bytes(%max,bd)) $c1(%cn,$sn(%max))
      }   
      $output($hget($sockname,output) $logo(%cn,GE) $c2(%cn,$2) $iif(%quan,$c1(%cn,$+($v1,x))) $c1(%cn,$3) $&
        $iif(%quan,%minstring,$+(12,$4)) $iif(%quan,%midstring,$+(03,$5)) $iif(%quan,%maxstring,$+(04,$6)) $c1(%cn,Today:) $+($iif(*-* iswm $7,04,03),$iif(%quan && $7 != N/A,$+($7 [,$bytes($calc($rp($7) * %quan),bd),]),$7) $& 
        $iif(!%quan,$+($c2(%cn,[),$c1(%cn,30 Days:)) $+($iif(*-* iswm $8,4,3),$8) $c1(%cn,90 Days:) $+($iif(*-* iswm $9,4,3),$9) $c1(%cn,180 Days:) $+($iif(*-* iswm $10,4,3),$10,$c2(%cn,])))))
      $output($hget($sockname,output) $logo(%cn,GE) $c1(%cn,Link:) $hlink($+(http://services.runescape.com/m=itemdb_rs/viewitem.ws?obj=,$1)))
      hfree $sockname
      sockclose $sockname 
    }
    elseif (*@@Multiple Results Displayed:* iswm %a) { 
      var %b $c1(%cn,$chr(124)),%quan $hget($sockname,quan)
      while (*:End* !iswm %a) {
        tokenize 124 $iif(*@@Multiple Results Displayed:* !iswm %a,%a)
        hadd $sockname info $hget($sockname,info) $iif($1,$c2(%cn,$1) $c1(%cn,$2) $c2(%cn,$iif(%quan,$bytes($calc($rp($3) * %quan),bd),$3)) $&
          $+($c2(%cn,$chr(40)),$c1(%cn,Today:) $iif(*-* iswm $4,04,03),$4 $iif(%quan && $4 != N/A,$+([,$bytes($calc($rp($4) * %quan),bd),])),$c2(%cn,$chr(41))) %b) 
        sockread %a
      }
      if (*:End* iswm %a) && ($hget($sockname,info)) {
        var %end $pos($hget($sockname,info),$chr(124),0)
        $output($hget($sockname,output) $logo(%cn,GE) $c2(%cn,Top Results:) $remtok($hget($sockname,info),$chr(124),%end,124))
        hfree $sockname
        sockclose $sockname 
      } 
    }
  }
  elseif (cs.* iswm $sockname) {
    var %c
    sockread %c
    if (*CS:* iswm %c) {
      tokenize 124 $token(%c,2-,58)
      var %b $c1(%cn,|)
      $output($hget($sockname,output) $logo(%cn,Coinshare) Item: $c2(%cn,$replace($2,+,$chr(32))) %b People: $c2(%cn,$1) %b Approximate share per person: $c2(%cn,$3))
      hfree $sockname
      sockclose $sockname
    }
    elseif (*@@ERROR:* iswm %c) {
      $output($hget($sockname,output) $logo(%cn,Coinshare) Item not found)
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (drops.* iswm $sockname) {
    var %d
    sockread %d
    if (*NPC:* iswm %d) {
      $output($hget($sockname,output) $logo(%cn,Drops) for $+($c2(%cn,$token(%d,2,58)),$c1(%cn,:)))
    }
    if (*P2P Only* iswm %d) {
      tokenize 124 %d
      $output($hget($sockname,output) $c2(%cn,P2P Only:) $c1(%cn,$token($2-,1-15,44)))
      $iif($token($2-,16,44),$output($hget($sockname,output) $c1(%cn,$token($2-,16-31,44))))
      $iif($token($2-,32,44),$output($hget($sockname,output) $c1(%cn,$token($2-,32-,44))))
    }
    if (*F2P/P2P* iswm %d) {
      tokenize 124 %d
      $output($hget($sockname,output) $c2(%cn,F2P/P2P:) $c1(%cn,$token($2-,1-20,44)))
      $iif($token($2-,21,44),$output($hget($sockname,output) $c1(%cn,$token($2-,21-,44))))
      hfree $sockname
      sockclose $sockname
    } 
    elseif (*Npc not found* iswm %d) {
      $output($hget($sockname,output) $logo(%cn,Drops) $c2(%cn,$qt($hget($sockname,npc))) $c1(%cn, Not found))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (spell.* iswm $sockname) {
    var %s
    sockread %s
    if (*Spell:* iswm %s) {
      tokenize 124 $token(%s,2-,58)
      var %b $c1(%cn,|),%casts $hget($sockname,casts),%f.or.m $+([,$iif(F2P isin $8,F,M),]),$&
        %min $calc(%casts * $token($3,1,44)),%mid $calc(%casts * $token($3,2,44)),%max $calc(%casts * $token($3,3,44))
      $output($hget($sockname,output) $logo(%cn,Spell) $c1(%cn,%f.or.m) $c2(%cn,$1) %b $4 %b $c2(%cn,Cost:) $&
        $c1(%cn,$+(12,$bytes(%min,bd) $sn(%min) 03,$bytes(%mid,bd) $sn(%mid) 04,$bytes(%max,bd) $sn(%max))) $&
        %b $c2(%cn,Exp:) $c1(%cn,$5) %b $c2(%cn,Max Hit:) $c1(%cn,$7) %b $c2(%cn,Level:) $c1(%cn,$6)) 
      hfree $sockname       
      sockclose $sockname
    }
    elseif (*No spell found* iswm %s) {
      $output($hget($sockname,output) $logo(%cn,Spell) Spell not found in database)
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (world.* iswm $sockname) {
    var %w
    sockread %w
    if (*World:* iswm %w) {
      tokenize 124 %w
      var %status $+(,$iif(online isin $2,3,4),$2),%b $c1(%cn,|)
      $output($hget($sockname,output) $logo(%cn,$1) $4 $c2(%cn,$3) %b Status: %status %b Players: $c2(%cn,$5) %b Lootshare: $c2(%cn,$6))  
      sockclose $sockname
    }
  }
  elseif (rsnews.* iswm $sockname) {
    var %r
    sockread %r
    if (*Title:* iswm %r) {
      tokenize 124 %r
      $output($hget($sockname,output) $logo(%cn,RsNews) $c2(%cn,$qt($remove($1,Title:))) $c1(%cn,$2) $c2(%cn,$3) $c1(%cn,$4))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (st.* iswm $sockname) {
    var %s
    sockread %s
    if (Page isin %s) {
      $output($hget($sockname,output) $logo(%cn,Stats) $c2(%cn,The username) $c1(%cn,$hget($sockname,rsn)) $c2(%cn,was not found in the RuneScape Hiscores.))
      hfree $sockname
      sockclose $sockname
      halt 
    }
    if (*unexpected condition* iswm %s) {
      $output($hget($sockname,output) $logo(%cn,Stats) Due to a technical issue Jagex have caused we are currently unable to process your request)
      hfree $sockname
      sockclose $sockname
      halt 
    }
    if (*,*,* iswm %s) {
      hinc $sockname snum 1 
      tokenize 44 %s
      $iif($hget($sockname,hl),hadd $sockname $+($gettok($s1($hget($sockname,snum)),1,32),Rank) $1)
      $iif($hget($sockname,skill) == $s1($hget($sockname,snum)),hadd $sockname skline %s)
      $iif($hget($sockname,cmb) == cmbperc,hadd $sockname expline $hget($sockname,expline) $3)
      hadd $sockname $gettok($s1($hget($sockname,snum)),1,32) $iif($hget($sockname,hl),$3,$2)
    }
    elseif ($hget($sockname,snum) >= 23) {
      hlist $sockname
      var %b $iif($hget($sockname,hl),2,1)
      while (%b <= 26) {
        var %stat $hget($sockname,$gettok($s1(%b),1,32)),%c $token($hget($sockname,elg),2,46),%t $token($hget($sockname,elg),1,46)
        hadd $sockname statsline $hget($sockname,statsline) $iif(-1 !isin %stat,$+($c1(%cn,$gettok($s3(%b),1,32)),$chr(58),$chr(32),$c2(%cn,%stat),$chr(44),$iif(%b <= 25,$c1(%cn,$chr(124))))))
        $iif($hget($sockname,cmb),hadd $sockname cmbline $hget($sockname,cmbline) %stat)
        $iif($hget($sockname,hl),hadd $sockname hline $hget($sockname,hline) $iif(-1 !isin %stat,$+($v2,$chr(96),$gettok($s1(%b),1,32))))
        $iif($hget($sockname,elg),hadd $sockname elgline $hget($sockname,elgline) $iif(%stat %t %c && -1 !isin %stat,$+($c1(%cn,$gettok($s3(%b),1,32)),$chr(58),$chr(32),$c2(%cn,%stat),$chr(44),$iif(%b <= 25,$c1(%cn,$chr(124)))))) 
        inc %b
      }
      if ($hget($sockname,skill)) {
        if (-1 isin $hget($sockname,skline)) {
          $output($hget($sockname,output) $logo(%cn,Stats) Username $c2(%cn,$qt($hget($sockname,rsn))) $c1(%cn,unranked)) 
          hfree $sockname         
          sockclose $sockname
          halt 
        }
        var %skill $hget($sockname,skill),%dlv $iif(%skill == Dungeoneering,120,99),%rank $gettok($hget($sockname,skline),1,44),%lvl $lvl($gettok($hget($sockname,skline),3,44)),%xp $gettok($hget($sockname,skline),3,44),%next $iif($hget($sockname,goal) != no,$iif($v1 > %lvl,$v1,$calc(%lvl + 1)),$calc(%lvl + 1)),%exptogoal $calc($exp(%lvl)-%xp),%xp2nxt $calc($exp(%next)-%xp)
        $output($hget($sockname,output) $logo(%cn,%skill) $+($c1(%cn,[),$c2(%cn,$hget($sockname,prsn)),$c1(%cn,])) $c1(%cn,Level:) $c2(%cn,$gettok($hget($sockname,skline),2,44)) $iif(%lvl > 99 && !$otherstats(%skill),$c1(%cn,$+([,$v1,]))) $c1(%cn,Exp:) $c2(%cn,$bytes(%xp,bd)) $iif(%skill != overall,$+($c1(%cn,$chr(40)),$&
          $round($calc($iif(%xp == 0,1,$v1) / $iif(%next >= 99,$+(2,$str(0,8)),$exp(%dlv)) *100),2),$&
          % $c1(%cn,of $iif(%next >= %dlv,200m,%dlv)),$chr(41))) $c1(%cn,Rank:) $c2(%cn,$bytes(%rank,bd)) $iif(%skill != overall,$c1(%cn,Experience to %next) $c2(%cn,$bytes(%xp2nxt,bd)) $+($c1(%cn,$chr(40)),$round($calc(%exptogoal / ($exp(%lvl) - $exp(%next))*100),2),% $c1(%cn,of %next),$chr(41))) $&
          $iif($s2(%skill) isnum 1-7,$c1(%cn,| Pc points:) $c2(%cn,$pcpoints(%skill,100,%lvl,%xp2nxt)) $c1(%cn,| Zeal:) $c2(%cn,$soulwars(%skill,%lvl,%xp2nxt))) $iif(!$otherstats(%skill),$c1(%cn,| Penguin points:) $c2(%cn,$ceil($calc(%xp2nxt / (%lvl * 25)))) $c1(%cn,| TOG:) $c2(%cn,$tog(%lvl,%xp2nxt))))
        $iif(%dlv == 99 && !$otherstats(%skill),$output($hget($sockname,output) $logo(%cn,%skill) $c1(%cn,Required for Level:) $c2(%cn,%next) $+($c1(%cn,$chr(40)),$c2(%cn,$bytes(%xp2nxt,bd)) $c1(%cn,$+(exp,$chr(41)))) $skillparams(%cn,%skill,%xp2nxt,%lvl)))))
        hfree $sockname       
        sockclose $sockname
        halt
      }
      elseif ($hget($sockname,cmb) == yes) {
        tokenize 32 $hget($sockname,cmbline)
        var %cmbstats $2 $4 $3 $5-8 $25
        if (-1 -1 -1 -1 -1 -1 -1 -1 !isin %cmbstats) {
          $output($hget($sockname,output) $logo(%cn,Combat) $c2(%cn,$hget($sockname,prsn)) $c1(%cn,is level) $c2(%cn,$cmb(%cmbstats)) $c1(%cn,F2P:) $c2(%cn,$gettok($cmb($gettok(%cmbstats,1-7,32)),1,32)) $c1(%cn,ASDCRPM(SU)) $c2(%cn,$remove(%cmbstats,$chr(45))))
          if ($($+($,nextlevel,$chr(40),%cmbstats,$chr(41),.,%cn),2)) {
            var %v1 $v1
            $output($hget($sockname,output) $logo(%cn,Combat) Next level in: %v1)
          }
        }
        else { 
          $output($hget($sockname,output) $logo(%cn,Combat) Combat stats of $c2(%cn,$hget($sockname,rsn)) $c1(%cn,are unranked))
        }
        hfree $sockname
        sockclose $sockname 
      }
      elseif ($hget($sockname,cmb) == cmbperc) {
        tokenize 32 $hget($sockname,expline)
        var %cmbxp $calc($replace($2-8,$chr(32),+) + $25) 
        $output($hget($sockname,output) $logo(%cn,Cmb%) $c2(%cn,$hget($sockname,prsn)) $c1(%cn,has) $c2(%cn,$bytes(%cmbxp,bd)) $c1(%cn,combat exp and) $c2(%cn,$bytes($calc($1 - %cmbxp),bd)) $c1(%cn,skill exp, resulting in a combat percent of) $c2(%cn,$+($round($calc((%cmbxp / $1) *100),2),%)))
        hfree $sockname
        sockclose $sockname 
      }
      elseif ($hget($sockname,hl)) {
        var %type $v1,%slvl $sorttok($hget($sockname,hline),32,n),%low $gettok(%slvl,1,32),%high $gettok(%slvl,-1,32)
        var %lowline $+($c1(%cn,[),$c2(%cn,Low),$c1(%cn,])) $c2(%cn,$gettok(%low,2,96)) $c1(%cn,- Lvl:) $c2(%cn,$lvl($gettok(%low,1,96))) $c1(%cn,|) Rank: $&
          $c2(%cn,$bytes($hget($sockname,$+($gettok(%low,2,96),rank)),db))) $c1(%cn,|) Exp: $c2(%cn,$bytes($gettok(%low,1,96),bd)))
        $output($hget($sockname,output) $logo(%cn,$hget($sockname,prsn)) $iif($istok(highlow high,%type,32),$+($c1(%cn,[),$c2(%cn,High),$c1(%cn,])) $c2(%cn,$gettok(%high,2,96)) $&
          $c1(%cn,- Lvl:) $c2(%cn,$lvl($gettok(%high,1,96))) $c1(%cn,|) Rank: $c2(%cn,$bytes($hget($sockname,$+($gettok(%high,2,96),rank)),db)) $c1(%cn,|) Exp: $c2(%cn,$bytes($gettok(%high,1,96),bd)),%lowline))
        $iif(%type == highlow,$output($hget($sockname,output) $logo(%cn,$hget($sockname,prsn)) %lowline))
        hfree $sockname
        sockclose $sockname 
      }
      elseif ($hget($sockname,statsline)) {
        if ($hget($sockname,elg) && !$hget($sockname,elgline)) {
          tokenize 46 $hget($sockname,elg)
          $output($hget($sockname,output) $logo(%cn,Stats) No stats $elg($1) $2)
          hfree $sockname
          sockclose $sockname
        }
        else {
          var %line $hget($sockname,$iif($hget($sockname,elgline),elgline,statsline)),$&
            %line $remtok(%line,$numtok(%line,124),124),%elg $elg($token($hget($sockname,elg),1,46)),$&
            %logo $logo(%cn,$+(Stats,$iif(%elg,: %elg $token($hget($sockname,elg),2,46))))
          tokenize 44 %line
          $output($hget($sockname,output) %logo $+($c1(%cn,[),$c2(%cn,$hget($sockname,prsn)),$c1(%cn,])) $1-13)
          $iif($14,$output($hget($sockname,output) $logo(%cn,Stats) $remove($14,$chr(124)) $15-26))  
          hfree $sockname
          sockclose $sockname
        }
      }
    }
  }
  elseif (rank.* iswm $sockname) {
    var %r,%b $c1(%cn,|)
    sockread %r
    if (*does not exist* iswm %r) {
      $output($hget($sockname,output) $logo(%cn,Rank) $c1(%cn,specified Rank:) $c2(%cn,$bytes($hget($sockname,position),bd)) $c1(%cn,does not exist.)) 
      hfree $sockname
      sockclose $sockname 
    }
    if (*RANK:* iswm %r) {
      tokenize 124 %r
      $output($hget($sockname,output) $logo(%cn,$gettok($1,2,32)) Rank: $c2(%cn,$2) %b Name: $c2(%cn,$3) %b Exp: $c2(%cn,$5) $+($c1(%cn,[),$c2(%cn,$4),$c1(%cn,])))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (compare.* iswm $sockname) {
    var %c
    sockread %c
    if (*Invalid Username* iswm %c) {
      tokenize 58 %c
      $output($hget($sockname,output) $logo(%cn,Compare) Invalid username: $c2(%cn,$gettok($2,1,32)) $iif($gettok($3,1,32),$c1(%cn,Invalid username:) $c2(%cn,$v1)))
      hfree $sockname
      sockclose $sockname
    }
    elseif ($+(*,$hget($sockname,skill),*) iswm %c) {
      tokenize 58 %c
      var %levels $gettok($3,1,124),%exp $gettok($4,1,124),%rank $gettok($5,1-2,44),$&
        %user1 $hget($sockname,user1),%user2 $hget($sockname,user2),%luser1 $gettok(%levels,1,44),%luser2 $gettok(%levels,2,44),$&
        %euser1 $gettok(%exp,1,44),%euser2 $gettok(%exp,2,44),%ruser1 $gettok(%rank,1,44),%ruser2 $gettok(%rank,2,44),$&
        %complvl $c2(%cn,$calc($iif(%luser1 > %luser2,$v1 - $v2,$v2 - $v1))) $c1(%cn,lvls) $iif(%luser1 > %luser2,3higher,4lower),$&
        %compexp $c2(%cn,$bytes($calc($iif(%euser1 > %euser2,$v1 - $v2,$v2 - $v1)),bd)) $c1(%cn,exp) $iif(%euser1 > %euser2,3higher,4lower),$&
        %comprank $c2(%cn,$bytes($calc($iif(%ruser1 > %ruser2,$v1 - $v2,$v2 - $v1)),bd)) $c1(%cn,ranks) $iif(%ruser1 > %ruser2,4lower,3higher)
      $output($hget($sockname,output) $logo(%cn,Compare) $+([,$c2(%cn,$hget($sockname,skill)),$c1(%cn,])) $+(%user1,:) lvl $+($c2(%cn,%luser1),$c1(%cn,$chr(44))) exp $c2(%cn,$bytes(%euser1,bd)) $c1(%cn,$chr(124) $+(%user2,:) lvl) $+($c2(%cn,%luser2),$c1(%cn,$chr(44))) exp $c2(%cn,$bytes(%euser2,bd)))
      $output($hget($sockname,output) $logo(%cn,Compare) $c2(%cn,%user1) $c1(%cn,is) %complvl %compexp %comprank $c1(%cn,than) $c2(%cn,%user2))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (geup.* iswm $sockname) {
    var %ge
    sockread %ge
    if (Update isin %ge) {
      $output($hget($sockname,output) $logo(%cn,Geupdate) $c1(%cn,The Grand Exchange was last updated:) $c2(%cn,$duration($calc($ctime - $gettok(%ge,2,58)))) $c1(%cn,ago.))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (clan.* iswm $sockname) {
    var %c
    sockread %c
    if (*@@Not Found* iswm %c) {
      $output($hget($sockname,output) $logo(%cn,Clan) Your search for $c2(%cn,$hget($Sockname,user)) $c1(%cn,was not found))
      hfree $sockname
      sockclose $sockname
      halt
    } 
    if (*http://* iswm %c) {
      while ($sock($sockname).rq) {
        if (*@@end* iswm %c) {
          break 
        }
        hadd $sockname info $remove($hget($sockname,info),@@start) $+($gettok($v2,1,124),$chr(44))
        var %a %a $v2  
        sockread %c
      }
    }
    if (*@@end* iswm %c) {
      var %n $pos($hget($sockname,info),$chr(44),0),%clanstring $remtok($hget($sockname,info),$chr(44),%n,44)
      $output($hget($sockname,output) $logo(%cn,Clan) $c2(%cn,$hget($sockname,user)) $c1(%cn,is in) $c2(%cn,%n) $c1(%cn,clans) $c2(%cn,%clanstring) $&
        $c1(%cn,$chr(124) Link:) $hlink($+(http://runehead.com/clans/search.php?search=,$replace($hget($sockname,user),_,$+($chr(37),$chr(65),$chr(48)))))))
      hfree $sockname
      sockclose $sockname 
    }
  }
  elseif (ml.* iswm $sockname) {
    var %m
    sockread %m
  }
  if (*@@start* iswm %m) {
    var %m,%br $c1(%cn,$chr(124)),%cn $hget($sockname,colour)
    sockread %m
    tokenize 124 %m 
    if (*@@Not Found* iswm $1) {
      $output($hget($sockname,output) $logo(%cn,Clan Info) $c2(%cn,$hget($sockname,clan)) $c1(%cn,Does not appear to be a valid Runehead memberlist)) 
      hfree $sockname
      sockclose $sockname
      halt 
    }
    else {
      $output($hget($sockname,output) $logo(%cn,Clan Info) $+($c1(%cn,[),$c2(%cn,$5),$c1(%cn,])) $c2(%cn,$1) $+($c1(%cn,$chr(40)),$c2(%cn,$2),$c1(%cn,$chr(41))) %br $&
        Members: $c2(%cn,$6) %br Average: F2P: $c2(%cn,$16) $c1(%cn,P2P:) $c2(%cn,$7) $c1(%cn,HP:) $c2(%cn,$8) $c1(%cn,Mage:) $c2(%cn,$10) $c1(%cn,Range:) $c2(%cn,$11) $c1(%cn,Total:) $c2(%cn,$9) %br $&
        $c2(%cn,$12) $c1(%cn,based, Homeworld:) $c2(%cn,$15) %br Cape: $c2(%cn,$14) %br Category: $c2(%cn,$4) %br RHlink: $hlink($3))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (alog.* iswm $sockname) {
    var %a
    sockread %a
    if (*@@Not found* iswm %a) {
      $output($hget($sockname,output) $logo(%cn,Alog) $c2(%cn,$qt($hget($sockname,rsn))) $c1(%cn,Is either Hidden or does not exist))
      hfree $sockname
      sockclose $sockname
      halt 
    }
    elseif (*@@Non member* iswm %a) {
      $output($hget($sockname,output) $logo(%cn,Alog) $c2(%cn,$qt($hget($sockname,rsn))) $c1(%cn,Has settings set to private or is a non member))
      hfree $sockname
      sockclose $sockname
      halt 
    }
    if (*Start:* iswm %a) {
      $output($hget($sockname,output) $logo(%cn,Alog) Recent Activity for $c2(%cn,$hget($sockname,rsn)) $+ $c1(%cn,:))
    }
    elseif (*NPC Kills:* iswm %a) { 
      var %x $remove(%a,NPC Kills:),%n $numtok(%x,44)
      $output($hget($sockname,output) $logo(%cn,NPC Kills) $Colour.alog(%cn,$token(%x,1- $+ %n,44)))
    }
    elseif (*Player Kills:* iswm %a) {
      var %x $remove(%a,Player Kills:),%n $numtok(%x,44)
      $output($hget($sockname,output) $logo(%cn,Player Kills) $Colour.alog(%cn,$token(%x,1- $+ %n,44)))
    }      
    elseif (*Levels Gained:* iswm %a) {
      var %x $remove(%a,Levels Gained:),%n $numtok(%x,44)
      $output($hget($sockname,output) $logo(%cn,Levels Gained) $Colour.alog(%cn,$token(%x,1- $+ %n,44)))
    }
    elseif (*Quests Completed:* iswm %a) {
      var %x $remove(%a,Quests Completed:),%n $numtok(%x,44)
      $output($hget($sockname,output) $logo(%cn,Quests Completed:) $Colour.alog(%cn,$token(%x,1- $+ %n,44)))
    }
    elseif (*Items Found:* iswm %a) {
      var %x $remove(%a,Items Found:),%n $numtok(%x,44)
      $output($hget($sockname,output) $logo(%cn,Items Found:) $Colour.alog(%cn,$token(%x,1- $+ %n,44)))
    }
    elseif (*Other:* iswm %a) {
      var %x $remove(%a,Other:),%n $numtok(%x,44)
      $output($hget($sockname,output) $logo(%cn,Other) $Colour.alog(%cn,$token(%x,1- $+ %n,44)))
    }
    elseif (*:End* iswm %a) {
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (familiar.* iswm $sockname) {
    var %f,%b $c1(%cn,|)
    sockread %f
    if (*Familiar:* iswm %f) {
      tokenize 124 $token(%f,2-,58) 
      var %refund $+($chr(40),$c2(%cn,$ceil($calc($4 *70/100))),$c1(%cn,$chr(41)))
      $output($hget($sockname,output) $logo(%cn,Familiar) $c2(%cn,$1) %b $c2(%cn,Lvl:) $c1(%cn,$2) %b $c2(%cn,Requires:) $&
        $c1(%cn,$3) %b $c2(%cn,Shards:) $c1(%cn,$4) %refund %b $c2(%cn,Exp:) $c1(%cn,$5) %b $c2(%cn,Alch:) $c1(%cn,$6) %b $&
        $c2(%cn,Desc:) $c1(%cn,$7) %b $c2(%cn,Time:) $c1(%cn,$8 minutes))
      hfree $sockname
      sockclose $sockname
    }
    elseif (*not found* iswm %f) {
      $output($hget($sockname,output) $logo(%cn,Familiar) $qt($hget($sockname,familiar)) $c2(%cn,not found))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (potion.* iswm $sockname) {
    var %p,%b $c1(%cn,|)
    sockread %p
    if (*Potion:* iswm %p) {
      tokenize 124 $token(%p,2-,58) 
      $output($hget($sockname,output) $logo(%cn,Potion) $2 %b $c2(%cn,Lvl:) $&
        $c1(%cn,$1) %b $c2(%cn,Exp:) $c1(%cn,$4) %b $c2(%cn,Requires:) $c1(%cn,$3))
      hfree $sockname 
      sockclose $sockname
    }
    elseif (*not found* iswm %p) {
      $output($hget($sockname,output) $logo(%cn,Potion) $qt($hget($sockname,pot)) $c2(%cn,not found))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (fcaves.* iswm $sockname) {
    var %w
    sockread %w
    if (Wave: isin %w) {
      $output($hget($sockname,output) $logo(%cn,Wave: $+ $hget($sockname,wave)) $token(%w,2-,58))
      hfree $sockname
      sockclose $sockname
    } 
  }
  elseif (npcid.* iswm $sockname) {
    var %a
    sockread %a
    var %b $+(*,$replace($gettok($hget($sockname,search),2-3,43),+,$chr(32)),*),%m2 $+(npc.,$right($sockname,5))
    if ($+(*,<a href="?rs2monster_id=*">,%b,</a></td>,*) iswm %a) {
      hadd -m $sockname monster $remove($gettok(%a,3,62),</a)
      hadd -m %m2 id $gettok($replace($nohtml($gettok(%a,3,61)),",$chr(32),>,),1,32)
      sockread %a
      hadd $sockname Race $nohtml(%a)
      sockread %a
      hadd $sockname members $nohtml(%a)
      sockread %a
      hadd $sockname Quest $nohtml(%a)
      sockread %a
      hadd $sockname Ratio $nohtml(%a)
      sockread %a
      hadd $sockname HP $nohtml(%a)
      sockopen %m2 www.tip.it 80 
      sockclose $sockname   
    }
    if (*</body>* iswm %a) {
      $output($hget($sockname,output) $logo(%cn,Npc) $c1(%cn,Your search for) $c2(%cn,$replace($hget($sockname,search),+,$chr(32))) $c1(%cn,didn't return any results.))
      hfree $sockname
      sockclose $sockname
      halt 
    }
  }
  elseif (npc.* iswm $sockname) {
    var %c $+(npcid.,$right($sockname,5)),%a
    sockread %a
    if (*Level:* iswm %a) {
      var %a
      sockread %a
      hadd $sockname level $nohtml(%a)
    }
    elseif (*Aggressive?* iswm %a) {
      hadd $sockname Aggressive $nohtml(%a)
    }
    elseif (*Retreats?* iswm %a) {
      hadd $sockname Retreats $nohtml(%a)
    }
    elseif (*Poisonous?* iswm %a) {
      hadd $sockname poison $nohtml(%a)
    }
    elseif (*habitat:* iswm %a) {
      var %a
      sockread %a
      hadd $sockname habitat $nohtml(%a) 
      $output($hget(%c,output) $logo(%cn,Npc) $hget(%c,monster) $c2(%cn,Lvl:) $c1(%cn,$hget($sockname,level)) $c2(%cn,HP:) $c1(%cn,$hget(%c,hp)) $c2(%cn,Ratio:) $c1(%cn,$hget(%c,Ratio)) $c2(%cn,Race) $c1(%cn,$hget(%c,race)) $&
        $iif(*yes* iswm $hget($sockname,poison),3Poisonous) $iif(*yes* iswm $hget($sockname,aggressive),4+Aggressive,3Non Aggressive) $iif(*yes* iswm $hget(%c,members),10P2P,12F2P))
      $output($hget(%c,output) $logo(%cn,Npc) $c2(%cn,Location:) $c1(%cn,$hget($sockname,habitat)) $c2(%cn,Link:) $hlink($+(http://www.tip.it/runescape/index.php?rs2monster_id=,$hget($sockname,id))))
      hfree %c
      hfree $sockname
      sockclose $sockname 
    }
  }
  elseif (quest.* iswm $sockname) {
    var %q
    sockread %q
    if (*@@Error* iswm %q) {
      $output($hget($sockname,output) $logo(%cn,Quest) $c1(%cn,Quest not found in database))
      hfree $sockname
      sockclose $sockname
      halt
    }
    elseif (*ID:* iswm %q) { 
      hadd $sockname link $c1(%cn,Link:) $hlink($+(http://www.tip.it/runescape/index.php?rs2quest_id=,$gettok(%q,2,58)))
    }
    elseif (*NAME:* iswm %q) {
      hadd $sockname name $c2(%cn,$gettok(%q,2,58))
    }
    elseif (*DIFFICULTY:* iswm %q) {
      hadd $sockname difficulty $c1(%cn,Difficulty:) $c2(%cn,$gettok(%q,2,58))   
    }
    elseif (*QP:* iswm %q) {
      hadd $sockname qp $c1(%cn,QP:) $c2(%cn,$gettok(%q,2,58))   
    }
    elseif (*REWARD:* iswm %q) {
      $output($hget($sockname,output) $logo(%cn,Quest) $hget($sockname,name) $c1(%cn,|) $hget($sockname,difficulty) $c1(%cn,|) $hget($sockname,qp) $c1(%cn,|) $c2(%cn,$hget($sockname,link)))
      $output($hget($sockname,output) $logo(%cn,Quest Rewards) $replace($gettok(%q,2-,58),experience,XP))
      hfree $sockname
      sockclose $sockname
      halt
    }
  }
  elseif (item.* iswm $sockname) {
    var %i
    sockread %i
    if (*@@Error* iswm %i) {
      $output($hget($sockname,output) $logo(%cn,item) $c1(%cn,Item not found in database))
      hfree $sockname
      sockclose $sockname
      halt
    }
    elseif (*ID:* iswm %i) {
      hadd $sockname link $c1(%cn,Link:) $c2(%cn,$+(http://www.tip.it/runescape/index.php?rs2item_id=,$gettok(%i,2,58)))
    }
    elseif (*NAME:* iswm %i) {
      hadd $sockname name $c2(%cn,$gettok(%i,2,58))
    }
    elseif (*MEMBERS:* iswm %i) {
      hadd $sockname members $c2(%cn,$iif(*yes* iswm $gettok(%i,2,58),2[M],10[F]))
    }
    elseif (*QUEST:* iswm %i) {
      hadd $sockname quest $iif(*yes* iswm $gettok(%i,2,58),3Quest,4Non-Quest)
    }
    elseif (*TRADE:* iswm %i) {
      hadd $sockname trade $iif(*yes* iswm $gettok(%i,2,58),3Tradeable,4Non-Tradeable)
    }
    elseif (*STACK:* iswm %i) {
      hadd $sockname stack $iif(*yes* iswm $gettok(%i,2,58),3Stacks,4Non-Stackable)
    }
    elseif (*LOCATION:* iswm %i) {
      hadd $sockname location $gettok(%i,2,58)
    }
    elseif (*EQUIP:* iswm %i) {
      $output($hget($sockname,output) $logo(%cn,Item) $hget($sockname,members) $hget($sockname,name) $c1(%cn,|) $hget($sockname,quest) $c1(%cn,|) $&
        $hget($sockname,trade) $c1(%cn,|) $hget($sockname,stack) $c1(%cn,|) $c2(%cn,$iif(*Equipable* iswm $gettok(%i,2,58),Equipable,Non-Equipable)) $&
        $c1(%cn,|) $hget($sockname,location) $c1(%cn,||) $hget($Sockname,link))
    }
    if (*@@STATS* iswm %i) {
      if (*None* iswm %i) {
        hfree $sockname
        sockclose $sockname
        halt
      }
      elseif (*STAB:* iswm %i) {
        tokenize 32 %i  
        var %sta $c2(%cn,$gettok($gettok($2,2,58),1,124)),%std $c2(%cn,$gettok($gettok($2,2,58),2,124)),%sla $c2(%cn,$gettok($gettok($3,2,58),1,124)),%sld $c2(%cn,$gettok($gettok($3,2,58),2,124)), $&
          %cra $c2(%cn,$gettok($gettok($4,2,58),1,124)),%crd $c2(%cn,$gettok($gettok($4,2,58),2,124)),%ma $c2(%cn,$gettok($gettok($5,2,58),1,124)),%md $c2(%cn,$gettok($gettok($5,2,58),2,124)), $&
          %ra $c2(%cn,$gettok($gettok($6,2,58),1,124)),%rd $c2(%cn,$gettok($gettok($6,2,58),2,124))
        $output($hget($sockname,output) $logo(%cn,iStats) Stab: $c1(%cn,Att:) %sta $c1(%cn,Def:) %std $c1(%cn,|) Slash: Att: %sla $c1(%cn,Def:) %sld $c1(%cn,|) Crush: Att: %cra $c1(%cn,Def:) %crd $c1(%cn,|) $&
          Magic: Att: %ma $c1(%cn,Def:) %md $c1(%cn,|) Range: Att: %ra $c1(%cn,Def:) %rd $c1(%cn,|) Summoning: $c2(%cn,$gettok($7,2,58)) $c1(%cn,|) Strength: $&
          $c2(%cn,$iif(*shared* iswm $gettok($8,2,58),Shared,$v2)) $c1(%cn,|) Prayer: $c2(%cn,$gettok($9,2,58)) $c1(%cn,|) Ranged Strength: $c2(%cn,$gettok($10,2,58)))
        hfree $sockname
        sockclose $sockname
        halt
      }
    }
  }
  elseif (alch.* iswm $sockname) {
    var %a
    sockread %a
    if (*@@Error* iswm %a) {
      $output($hget($sockname,output) $logo(%cn,Alch) $c1(%cn,Item not found in database))
      hfree $sockname
      sockclose $sockname
      halt
    }
    if (*NAME:* iswm %a) {
      hadd $sockname name $c2(%cn,$gettok(%a,2,58))
    }
    elseif (*HIGH:* iswm %a) {
      hadd $sockname high $c2(%cn,$gettok(%a,2,58))
    }
    elseif (*LOW:* iswm %a) {
      $output($hget($sockname,output) $logo(%cn,Alch) $hget($sockname,name) $c1(%cn,High:) $hget($sockname,high) $c1(%cn,Low:) $c2(%cn,$gettok(%a,2,58)))
      hfree $sockname
      sockclose $sockname
      halt
    }
  }
  elseif (tracker.* iswm $sockname) {
    var %t
    sockread %t
    if (0:-1 == %t) {
      $output($hget($sockname,output) $logo(%cn,Track) $c1(%cn,$hget($sockname,nick)) $c2(%cn,Invalid username))
      hfree $sockname
      sockclose sockname
      halt 
    }
    elseif (start:* iswm %t) {
      var %v $replace($v2,:,$chr(32),start,)
      hadd $sockname $+(start.,$gettok(%v,1,32)) $hget($sockname,$+(start.,$gettok(%v,1,32))) $gettok($v2,3,58)
      hinc $sockname $+(start.,total) $iif(!$otherstats($v2),$iif($lvl($gettok(%v,2,32)) <= 99,$v1,99))
    }
    elseif (gain:* iswm %t) {
      var %v $replace($v2,:,$chr(32),gain,)
      hadd $sockname $+(gain.,$gettok(%v,1,32)) $hget($sockname,$+(gain.,$gettok(%v,1,32))) $calc($hget($sockname,$+(start.,$gettok(%v,1,32))) - $gettok($v2,4,58))
      hinc $sockname $+(gain.,total) $iif(!$otherstats($v2),$iif($lvl($calc($hget($sockname,$+(start.,$gettok(%v,1,32))) - $gettok(%v,3,32))) <= 99,$v1,99))
    }
    elseif (END == %t) {
      var %x 2
      while (%x <= 26) {
        var %a %a $iif($hget($sockname,$+(start.,$s1(%x))) > $hget($sockname,$+(gain.,$s1(%x))),$+($c2(%cn,$s1(%x)),$c1(%cn,$chr(40)),$c1(%cn,$lvl($hget($sockname,$+(gain.,$s1(%x))))),$&
          $iif($lvl($hget($sockname,$+(start.,$s1(%x)))) != $lvl($hget($sockname,$+(gain.,$s1(%x)))),$iif($lvl($hget($sockname,$+(start.,$s1(%x)))) > 0,$+(->,$lvl($hget($sockname,$+(start.,$s1(%x))))))),$chr(41)) $&
          $c2(%cn,$+(+,$bytes($calc($hget($sockname,$+(start.,$s1(%x))) - $hget($sockname,$+(gain.,$s1(%x)))),bd))) $c2(%cn,|))
        inc %x 
      }
      if (!$gettok(%a,1-,124)) { 
        $output($hget($sockname,output) $logo(%cn,Track) $hget($sockname,pnick) has gained no xp over $c2(%cn,$hget($sockname,t)))
        hfree $sockname
        sockclose $sockname
      } 
      else {
        var %a $t1(%a),%os $hget($sockname,$+(start.,total)),%og $hget($sockname,$+(gain.,total)),%overall $iif($calc(%os - %og) > 1,$+(+,$v1))
        $output($hget($sockname,output) $logo(%cn,Track) $c1(%cn,Exp gains for $hget($sockname,pnick)) $c2(%cn,in last $hget($sockname,t)) $&
          Overall: %overall $iif($calc($hget($sockname,$+(start.,overall)) - $hget($sockname,$+(gain.,overall))) > 1,$c1(%cn,$+(+,$bytes($v1,bd)))) $gettok(%a,1-8,124))
        $iif($numtok(%a,124) > 8, $output($hget($sockname,output) $logo(%cn,Track) $gettok(%a,9-17,124)))
        $iif($numtok(%a,124) > 18, $output($hget($sockname,output) $logo(%cn,Track) $gettok(%a,18-,124)))
        $output($hget($sockname,output) $logo(%cn,Graph) $hlink($+(http://runetracker.org/track-,$hget($sockname,nick))))
        hfree $sockname
        sockclose $sockname
        halt
      }
    }
  }
  elseif (track.* iswm $sockname) {
    var %r
    sockread %r
    if (*Invalid argument* iswm %r) {
      $output($hget($sockname,output) $logo(%cn,Track) $c1(%cn,$hget($sockname,nick)) $c2(%cn,Is an invalid username))
      hfree $sockname
      sockclose $sockname
      halt
    }
    if (*started:* iswm %r) { 
      var %x $gettok(%r,2,58)
    }
    if (0:* iswm %r) {
      if (-1 isin $gettok(%r,2,58)) {
        $output($hget($sockname,output) $logo(%cn,Track) $c1(%cn,$hget($sockname,nick)) $c2(%cn,invalid username))
        hfree $sockname
        sockclose $sockname
      } 
      else {
        hadd $sockname xp $gettok(%r,2,58)
      }
    }
    if (2419200:* iswm %r) {
      var %plvl $lvl($calc($hget($sockname,xp) - $gettok(%r,2,58))), %lvl $lvl($hget($sockname,xp)),%skill $hget($sockname,skill)
      hadd $sockname month $bytes($gettok(%r,2,58),bd) $iif(!$otherstats(%skill),$iif(%plvl < %lvl,$+(%plvl,->,%lvl),%lvl))
    }
    if ($+($hget($sockname,time),:,*) iswm %r) {
      hadd $sockname Gain $gettok(%r,2,58)
      if ($gettok(%r,2,58) == 0) {
        $output($hget($sockname,output) $logo(%cn,Track) $c1(%cn,$hget($sockname,pnick)) $c2(%cn,has gained no exp in) $&
          $c1(%cn,$hget($sockname,skill)) $c2(%cn,for) $c1(%cn,$hget($sockname,t)))
        hfree $sockname
        sockclose $sockname
      }
      else {
        var %plvl $lvl($calc($hget($sockname,xp) - $hget($sockname,Gain))),%lvl $lvl($hget($sockname,xp)),%skill $hget($sockname,skill)
        $output($hget($sockname,output) $logo(%cn,Track) $c1(%cn,%skill) $c2(%cn,exp achieved by) $c1(%cn,$hget($sockname,pnick)) $&
          $c2(%cn,in the last $+($hget($sockname,t),:)) $c1(%cn,$+(+,$bytes($hget($sockname,Gain),bd))) $&
          $iif(!$otherstats(%skill),$c1(%cn,|) $c2(%cn,lvl:) $c1(%cn,$iif(%plvl < %lvl,$+(%plvl,$chr(45),$chr(62),%lvl),%lvl)))))
        $output($hget($sockname,output) $logo(%cn,Track) $c2(%cn,Graph:) $hlink($+(http://runetracker.org/track-,$hget($sockname,nick))) $&
          $iif($hget($sockname,month),$c1(%cn,Month:) $c2(%cn,$v1))) 
        hfree $sockname       
        sockclose $sockname
      }
    }
  }
  elseif (rswiki.* iswm $sockname) {
    var %r,%x $hget($sockname,query)
    sockread %r
    if (*RSWIKI:* iswm %r) {
      tokenize 32 $token(%r,2,58)
      $output($hget($sockname,output) $logo(%cn,Rswiki: %x) $1-50)
      $output($hget($sockname,output) $logo(%cn,Rswiki) $iif($51,$c1(%cn,$51- $chr(124))) $c2(%cn,Link:) $hlink($+(http://runescape.wikia.com/wiki/,$fname(%x)))) 
      hfree $sockname
      sockclose $sockname
    }
    elseif (*NOT FOUND* iswm %r) {
      $output($hget($sockname,output) $logo(%cn,Rswiki) Query: $c2(%cn,$qt(%x)) $c1(%cn,Not Found))  
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (fml.* iswm $sockname) {
    var %f
    sockread %f
    if (*Today,* iswm %f) {
      hadd $sockname fml %f
    }
    elseif (*AGREE:* iswm %f) {
      hadd $sockname agree $gettok(%f,2,58)
    }
    elseif (*DESERVED:* iswm %f) {
      hadd $sockname deserve $gettok(%f,2,58)
    } 
    elseif (*COMMENTS:* iswm %f) {
      $output($hget($sockname,output) $logo(%cn,FML) $c1(%cn,$hget($sockname,fml)) $c1(%cn,||) $c2(%cn,Agree:) $c1(%cn,$hget($sockname,agree)) $&
        $c2(%cn,Deserved:) $c1(%cn,$hget($sockname,deserve)) $c2(%cn,Comments:) $c1(%cn,$gettok(%f,2,58)))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (tfln.* iswm $sockname) {
    var %t
    sockread %t
    if (*TFLN:* iswm %t) {
      tokenize 58 %t
      $output($hget($sockname,output) $logo(%cn,TFLN) $c2(%cn,$replace($2,$chr(40),[,$chr(41),],$chr(32),)) $c1(%cn,$3))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (bash.* iswm $sockname) {
    var %b
    sockread %b
    if (*Does Not exist* iswm %b) {
      $output($hget($sockname,output) $logo(%cn,Bash) Quote: $qt($hget($sockname,id)))
      hfree $sockname
      sockclose $sockname
    }
    if (*Number only please* iswm %b) {
      $output($hget($sockname,output) $logo(%cn,Bash) $c1(%cn,Correct syntax:) $c2(%cn,!bash #number))
      hfree $sockname
      sockclose $sockname
    }
    if (*QUOTE:* iswm %b) {
      hadd $sockname quote $remove($replace($gettok(%b,2-,58),lt,<,gt,>,","),&,;)
    }
    if (*ID:* iswm %b) {
      hadd $sockname quoteid $gettok(%b,2,58)
    }
    if (*RATING:* iswm %b) {
      $output($hget($sockname,output) $logo(%cn,Bash) $hget($sockname,quote) $c2(%cn,Rating:) $c1(%cn,$gettok(%b,2,58)) $c2(%cn,ID:) $c1(%cn,$hget($sockname,quoteid)))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (urban.* iswm $sockname) {
    var %u
    sockread %u
    if (*Word not found* iswm %u) {
      $output($hget($sockname,output) $logo(%cn,Urban) $c2(%cn,$qt($hget($sockname,word))) $c1(%cn,Not found in the urban dictionary))
      hfree $sockname
      sockclose $sockname
    }
    elseif (*URBAN:* iswm %u) {
      $output($hget($sockname,output) $logo(%cn,Urban) $c2(%cn,$qt($hget($sockname,word))) $c1(%cn,$regsubex($gettok(%u,2-,58),/^(.)/S,$upper(\t))))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (weather.* iswm $sockname) {
    var %w
    sockread %w
    if (*@@not found* iswm %w) {
      $output($hget($sockname,output) $logo(%cn,Weather) Location Not found)
    }
    if (*PHP:* iswm %w) {
      var %category $c1(%cn,$token(%w,2,58))
      if (*Last Updated* iswmcs %category) { 
        hadd $sockname ostring 1 
      }
      var %i $token(%w,3-,58),$&
        %info $iif(*Url* iswmcs %category,$hlink(%i),$c2(%cn,%i)),$&
        %tablename $iif($hget($sockname,ostring),info2,info1)
      hadd $sockname %tablename $hget($sockname,%tablename) %category $+ $iif(*Weather for* !iswm %category,:) %info
    }
    if (*:End* iswm %w) {
      $output($hget($sockname,output) $logo(%cn,Weather) $hget($sockname,info1))
      $output($hget($sockname,output) $logo(%cn,Weather) $hget($sockname,info2))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (halo.* iswm $sockname) {
    var %h
    sockread %h
    if (*HALO3:* iswm %h) {
      if (*not found* iswm %h) || ($+(*,$str(|,8),*) iswm %h) {
        $output($hget($Sockname,output) $logo(%cn,Halo3) $c1(%cn,No information was found for) $c2(%cn,$qt($hget($sockname,user))))
        hfree $sockname
        sockclose $sockname 
      }
      else {
        var %b $c1(%cn,$chr(124))
        tokenize 124 %h
        $output($hget($Sockname,output) $logo(%cn,Halo3) $c2(%cn,$replace($hget($sockname,user),+,$chr(32))) $c1(%cn,$remove($1,HALO3:)) $&
          %b $c1(%cn,Highest skill:) $c2(%cn,$2) %b $c1(%cn,Total exp:) $c2(%cn,$4) %b $c1(%cn,Next:) $c2(%cn,$9) %b $c1(%cn,Total Games:) $c2(%cn,$3))
        $output($hget($Sockname,output) $logo(%cn,Halo3) $c1(%cn,Ranked:) $c2(%cn,$5) %b $c1(%cn,Social:) $c2(%cn,$6) %b $c1(%cn,Custom:) $c2(%cn,$7) $&
          %b $c1(%cn,Campaign:) $c2(%cn,$8) %b $c1(%cn,Link:) $hlink($+(http://www.bungie.net/stats/halo3/careerstats.aspx?player=,$hget($sockname,user))))
        hfree $sockname
        sockclose $sockname 
      }
    }
  }
  elseif (xbl.* iswm $sockname) {
    var %x
    sockread %x
    if (*@@Does Not Exist* iswm %x) {
      $output($hget($Sockname,output) $logo(%cn,Xbl) Gamertag $c2(%cn,$qt($hget($sockname,user))) $c1(%cn,does not exist))
      hfree $sockname
      sockclose $sockname
    }
    elseif (*@@privacy settings turned on* iswm %x) {
      $output($hget($Sockname,output) $logo(%cn,Xbl) $c2(%cn,$qt($hget($sockname,user))) $c1(%cn,has privacy settings enabled))
      hfree $sockname
      sockclose $sockname
    }
    elseif (*GAMERTAG:* iswm %x) {
      hadd $sockname tag $gettok(%x,2,58)
    }
    elseif (*REP:* iswm %x) {
      hadd $sockname rep $gettok(%x,2,58)
    }
    elseif (*GAMERSCORE:* iswm %x) {
      hadd $sockname gs $gettok(%x,2,58)
    }
    elseif (*LOCATION:* iswm %x) {
      hadd $sockname loc $gettok(%x,2,58)
    }
    elseif (*ZONE:* iswm %x) {
      hadd $sockname zone $gettok(%x,2,58)
    }
    elseif (*STATUS:* iswm %x) {
      hadd $sockname status $gettok(%x,2,58)
    }
    elseif (*LAST SEEN:* iswm %x) {
      var %b $c1(%cn,|),%rep $hget($sockname,rep)
      $output($hget($sockname,output) $logo(%cn,3Xbox 7Live) $c2(%cn,$hget($sockname,tag)) %b Gamerscore: $c2(%cn,$hget($sockname,gs)) %b Rep: $stars(%cn,xbl,$remove(%rep,%),%rep) $&
        Location: $c2(%cn,$hget($sockname,loc)) %b Zone: $c2(%cn,$hget($sockname,zone)) %b Status $c2(%cn,$hget($sockname,status)) $&
        $c1(%cn,$iif($hget($sockname,status) == offline,Last seen:,currently)) $c2(%cn,$gettok(%x,2-,58)))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (gf.* iswm $sockname) {
    var %g
    sockread %g
    if (*W1:* iswm %g) {
      hadd $sockname results1 $gettok(%g,3,58)
    }
    if (*W2:* iswm %g) { 
      if (($gettok(%g,2,58) && $hget($sockname,results1) !isnum)) {
        $output($hget($sockname,output) $logo(%cn,Googlefight) Both $c2(%cn,$hget($sockname,word1)) $c1(%cn,and) $c2(%cn,$hget($sockname,word2)) $c1(%cn,Returned) $c2(%cn,0) $c1(%cn,Results))
        hfree $sockname
        sockclose $sockname
      }
      else {
        var %a $hget($sockname,results1),%b $gettok(%g,2,58),%sort $sorttok(%a %b,32,nr),$&
          %c $c2(%cn,$iif(%a == $gettok(%sort,1,32),$hget($sockname,word1),$hget($sockname,word2))) $c1(%cn,won by:) $c2(%cn,$bytes($calc($gettok(%sort,1,32) - $gettok(%sort,2,32)),bd))
        $output($hget($sockname,output) $logo(%cn,Googlefight) $hget($sockname,word1) has $c2(%cn,$bytes(%a,bd)) $c1(%cn,results while $hget($sockname,word2) has) $c2(%cn,$bytes(%b,bd)) $c1(%cn,results.))
        $output($hget($sockname,output) $logo(%cn,Googlefight) $iif(%a == %b,$c2(%cn,Result:) $c1(%cn,Draw, both received an equal number of results),Winner: %c $c1(%cn,results.)))  
        hfree $sockname
        sockclose $sockname
      }
    }
  }
  elseif (Cyborg.* iswm $sockname) {
    var %c
    sockread %c
    if (*CYBORG:* iswm %c) {
      $output($hget($sockname,output) $logo(%cn,Cyborg) $c2(%cn,$token(%c,2,58) $+ :) $c1(%cn,$token(%c,3-,58)))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (ytinfo.* iswm $sockname) { 
    var %y
    sockread %y
    if (*Video not found* iswm %y) {
      $output($hget($sockname,output) $logo(%cn,Youtube) No Video results found)
      hfree $sockname
      sockclose $sockname
    }
    elseif (*Title* iswm %y) {
      tokenize 124 %y
      var %b $c1(%cn,|),%title $gettok($1,2,58),%length $gettok($2,2-3,58),%rating $remove($gettok($3,2,58),$chr(32)),%views $remove($gettok($4,2,58),$chr(32)),%ratings $remove($gettok($5,2,58),$chr(32)),%meh %y
      $output($hget($sockname,output) $logo(%cn,$+(,$c2(%cn,You),0,$chr(44),4tube,$chr(15))) $c1(%cn,Title:) $c2(%cn,%title) %b $c1(%cn,Duration:) $c2(%cn,%length) %b $c1(%cn,Rating:) $stars(%cn,yt,%rating,%rating) %b $&
        $c1(%cn,Views:) $c2(%cn,$+(%views,$c1(%cn,$+($chr(40),$iif(%ratings,$v1,0) ratings,$chr(41))))))  
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (yt.* iswm $sockname) { 
    var %y
    sockread %y
    if (*Video not found* iswm %y) {
      $output($hget($sockname,output) $logo(%cn,Youtube) No Video results found)
      hfree $sockname
      sockclose $sockname
    }
    elseif (*Title* iswm %y) {
      tokenize 124 %y
      var %b $c1(%cn,|),%title $gettok($1,2,58),%link $remove($gettok($2,2,58),$chr(32)),%length $gettok($3,2-3,58),%rating $remove($gettok($4,2,58),$chr(32)),%views $remove($gettok($5,2,58),$chr(32))
      $output($hget($sockname,output) $logo(%cn,$+(,$c2(%cn,You),0,$chr(44),4tube,$chr(15))) $c1(%cn,Title:) $c2(%cn,%title) %b $c1(%cn,Duration:) $c2(%cn,%length) %b $c1(%cn,Rating:) $stars(%cn,yt,%rating,%rating) %b $&
        Views: $c2(%cn,%views) %b Link: $hlink($+(http://www.youtube.com/watch?v=,%link)))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (google.* iswm $sockname) { 
    var %g
    sockread %g
    if (*@@Search for that on your own* iswm %g) {
      $output($hget($sockname,output) $logo(%cn,Google) LET ME GOOGLE THAT FOR YOU! $c2(%cn,Wait just open up a browser to search for) $+($c1(%cn,$qt($hget($sockname,search))),$c2(%cn,...)))
      hfree $sockname
      sockclose $sockname
    }
    if (*Title* iswm %g) {
      tokenize 124 %g
      var %b $c1(%cn,|)
      $output($hget($sockname,output) $logo(%cn,12G4O7O12G3L4E) $c2(%cn,Title:) $c1(%cn,$remove($1,Title:)) %b $c2(%cn,Description:) $c1(%cn,$2) %b $hlink($3))
      hfree $sockname
      sockclose $sockname
    }
  }
  elseif (define.* iswm $sockname) { 
    var %c
    sockread %c
    if (*Word not found* iswm %c) {
      $output($hget($sockname,output) no definitions for $c2(%cn,$qt($hget($sockname,search))) $c1(%cn,found))
      hfree $sockname
      sockclose $sockname
    }
    else {
      if ($regex(%c,/<i>abbreviation(.*?)<\/div>/gi)) {
        $output($hget($sockname,output) $logo(%cn,Define) $c2(%cn,$+($hget($sockname,search),:)) $c1(%cn,Abbreviation $nohtml($regml(1))))
        hfree $sockname
        sockclose $sockname
      }
      elseif ($regex(%c,/<div class="ds-list"><b>1. </b>(.*?)<\/div>/Si)) {
        $output($hget($sockname,output) $logo(%cn,Define) $c2(%cn,$+($hget($sockname,search),:)) $c1(%cn,$replace($regml(1),<i>,:,</i>,)))
        hfree $sockname
        sockclose $sockname
      }
    }
  }
  elseif (botnews.* iswm $sockname) {
    var %b
    sockread %b
    if (*LAST TWEET:* iswm %b) {
      if (%b != $readini(Hermes.ini,n,Botnews,latest)) && ($readini(Hermes.ini,settings,Botnews) == 1) {
        writeini Hermes.ini Botnews latest %b
        .msg $botchan $logo(%cn,Bot News) $gettok(%b,2-,58)       
        sockclose $sockname
      }
    }
  }
  elseif (version.* iswm $sockname) {
    var %v
    sockread %v
    if (*Version:* iswm %v) {
      var %x $gettok(%v,2,58)
      if (!$hget($sockname,update)) {
        $output($hget($sockname,output) $logo(%cn,Version) Runescape Bot framework $c2(%cn,$+(v,$release)))
        $iif(%x != $release,$output(%o $hget($sockname,output) $logo(%cn,Version) Type $c2(%cn,!update) $c1(%cn,to get the latest version))) 
        sockclose $sockname
      }
      elseif ($hget($sockname,update)) {
        .signal -n updatecheck $iif(%x != $release,update)
        hfree $sockname
        sockclose $sockname
      }
    }
  }
}
on *:invite:#: {
  if ($hget(itimer,$chan)) {
    halt
  }
  if ($+(*,$chr(44),*) !iswm $chan) { 
    var %cn $nick
    .join $chan 
    if ($readini(Hermes.ini,Blacklist,$chan)) {
      .msg $chan $logo(%cn,Invite) Channel blacklisted
      .part $chan 
      .msg $botchan $logo(%cn,Invite) $me has left $chan channel $c2(%cn,blacklisted)
    } 
    .msg $chan $iif($readini(Hermes.ini,settings,invmsg),$c2(%cn,$remove($v1,$chr(126))) $c1(%cn,I was invited by) $c2(%cn,$nick),$c1(%cn,Easy to use Runescape bot "Hermes") $c2(%cn,Hello world!))
    .msg $botchan $logo(%cn,Invite) Invited by %cn $address(%cn,2) to channel $chan $chan($1).mode)
  }
}
on *:kick:#: {
  if ($knick == $me) { 
    var %n $nick
    hadd -mu30 itimer $chan on
    .msg $botchan $logo(%n,Kick) I've been kicked from $c1(%n,$chan) by $c2(%n,%n) $c1(%n,$qt($1-))
  }
}
on *:load: { 
  writeini Hermes.ini Settings noreply #bots #chan1 #chan2 #chan3 #etc
  .dialog -md cpanel cpanel
}

on *:start: {
  .flood +c 300 5 5 30
  .timer 1 3 echo -s $+(.:,$botchan is currently set as default bot channel- you can use the Hermes dialog to change this,:.)
}
on *:connect: {
  $iif($readini(Hermes.ini,settings,Botnews) == 1,/timerbotnews 0 3600 sockopen $+(botnews.,$right($ticks,5)) beardbot.netii.net 80)
  .join $iif($readini(Hermes.ini,settings,Botchan) != $chr(35),$remove($v1,$chr(126)),#Beard)
  .join $iif($readini(Hermes.ini,settings,Homechan) != $chr(35),$remove($v1,$chr(126)),#Beard)
}
on *:signal:updatecheck: {
  if ($1 == update) { 
    .update
  }
  else {
    .msg $botchan 4Hermes Open source bot script is up to date
    $tip(Update,Error: version $release,Hermes Open source bot script is up to date)
  }
}
ctcp *:hermes:?: { 
  .ctcp $nick beard-bot.co.uk Hermes Version: $release
}
alias Colour.alog {
  var %n $1,%x $regsubex($2-,/(\d+|\d+.)x/Sig,$c2(%n,\1 $+ x) $+ $c1(%n))
  var %y $regsubex(%x,/(\d+.)XP/Sig,$c2(%n,$bytes($strip(\1),bd) $+ xp) $+ $c1(%n))
  var %z $regsubex(%y,/\s(\d+)\s/g,$chr(32) $+ $c2(%n,\1) $c1(%n))
  return $replace(%z,[,$c1(%n) $+ [ $+ $c2(%n),],$c1(%n) $+ ]) 
}
alias -l rp { 
  ;Calculates an equation & replaces abbreviations for large numbers
  var %a $remove($1,$chr(44))
  return $calc($regsubex(%a, /(\d+\.?\d+?|\d+)([kmbt])/g,$chr(40)\1*1 $+ $str(000,$pos(kmbt,\2)) $+ $chr(41)))
} 
alias -l stars {
  ;Creates the rating stars for the youtube and xboxlive scripts
  var %n $1,%a $int($calc(5*$ceil($iif($2 == yt,$calc($3 * 20),$3)) /100)),%b $calc(5-%a),%c1 7,%c2 14
  return $+(%c1,,$str(*,%a),%c2,$str(*,%b),$chr(32),,$+($c1(%n,[),$c2(%n,$4),$c1(%n,]))))
} 
alias -l sn {
  ;Returns an abbreviation of a large number
  if ($remove($$1,$chr(44)) isnum) {
    var %a $gettok($bytes($v1,b),0,44),%b $bytes($v1,b),%c $+($gettok(%b,1,44),$iif(%a != 1,.),$iif($mid($gettok(%b,2,44),1,2) == 0,0,$v1),$replace(%a,1,$null,2,k,3,m,4,b,5,t))
    return $iif(%c >= 1000 || $regex(%c,/[kmbt]/),$+($chr(40),%c,$chr(41)))
  }
}
alias -l s1 { 
  ;Returns skill name based on number
  return $gettok(Overall.Attack.Defence.Strength.Constitution.Ranged.Prayer.Magic.Cooking.Woodcutting.Fletching.Fishing.Firemaking.Crafting.Smithing.Mining.Herblore.Agility.Thieving.Slayer.Farming.Runecraft.Hunter.Construction.Summoning.Dungeoneering,$1,46)
}
alias -l s2 {
  ;Returns number based on skill name
  return $findtok(attack.defence.strength.Constitution.ranged.prayer.magic.cooking.woodcutting.fletching.fishing.firemaking.crafting.smithing.mining.herblore.agility.thieving.slayer.farming.runecraft.hunter.construction.summoning.dungeoneering,$1,1,46)
}
alias -l s3 {
  ;Returns shortened skill names based on number
  return $gettok(Overall.Att.Def.Str.Cns.Range.Pray.Mage.Cook.Wc.Fletch.Fish.Fm.Craft.Smith.Mine.Herb.Agil.Thieve.Slay.Farm.Rc.Hunt.Con.Summ.Dung.Duel.Bounty.Bounty-Rogue.FOG.BA-Att.BA-Def.BA-Coll.BA-Heal.CW,$1,46)
}
alias -l t1 {
  return $replace($1,Attack,Att,Defence,Def,Strength,Str,Constitution,Cns,Ranged,Range,Prayer,Pray,Magic,Mage,Cooking,Cook,Woodcutting,Wc,Fletching,Fletch,Fishing,Fish,Firemaking,Fm,Crafting,Craft,Smithing,Smith,Mining,Mine,Herblore,Herb,Agility,Agil,Thieving,Thiev,Slayer,Slay,Farming,Farm,Runecraft,Rc,Hunter,Hunt,Construction,Con,Summoning,Summ,Dungeoneering,Dung)
}
alias -l lvl {
  ;Returns Level based on experience
  var %a 0,%b 1,%c $1
  while (%a <= %c) {
    inc %a $calc($floor($calc(%b + 300 * 2 ^ (%b / 7))) / 4)
    inc %b
  }
  return $calc(%b - 1)
}
alias -l exp {
  ;Returns experience based on level
  var %x 1,%l $calc($1 - 1),%xp 0
  while (%x <= %l) {
    var %tx $calc($floor($calc(%x + 300 * 2 ^ (%x / 7))) / 4)
    inc %xp %tx
    inc %x
  }
  return $int(%xp)
}
alias -l soulwars {
  ;$1 skill, $2 current level,$3 xptonext
  var %expperzeal $floor($calc((($2 ^ 2) / 600) * $iif($regex($1,/(attack|strength|defence|constitution)/Si),525,$iif($regex($1,/(magic|ranged)/Si),480,270))))
  return $ceil($calc($3 / %expperzeal))
}
alias -l tog {
  ;$1 current level, $2 xptonext
  return $bytes($ceil($calc($2 / $iif($1 >= 30,60,$calc((100 + $floor($2 / 27)) / 10)))),b)
}
alias -l pcpoints { 
  ;$1 skill, $2 10/100, $3 current level, $4 xptonext
  var %base $ceil($calc((($3 ^ 2) / 600) * $iif($regex($1,/(attack|strength|defence|constitution)/Si),35,$iif($regex($1,/(magic|ranged)/Si),32,18))))
  var %bonus $ceil($calc(%base * $iif($2 == 10, 1.01,1.10)))
  return $floor($calc($4 / %bonus))
}
alias -l cmb { 
  ;Calculates combat level: $cmb(96 94 94 99 94 78 86 79) returns: 129.5 [Melee] 
  tokenize 32 $1-
  var %att $1,%str $2,%def $3,%hp $4,%range $5,%prayer $6,%magic $7,%summ $8 
  ;base level calculation
  var %a $calc(%def *100),%b $calc(%hp *100)
  var %c $iif($and(%prayer,1),$calc((%prayer -1) *50),$calc(%prayer *50)),%d $iif($and(%summ,1),$calc((%summ -1) *50),$calc(%summ *50))
  var %p2pbase $calc((%a + %b + %c + %d)/400),%f2pbase $calc((%a + %b + %c)/400)
  ;combat class calculation
  var %e $calc(%att * 130),%g $calc(%str * 130)
  var %h $iif($and(%range,1),$calc((%range *195)-65),$calc(%range *195)),%i $iif($and(%magic,1),$calc((%magic *195)-65),$calc(%magic *195))
  var %melee-cmb $+($calc((%e + %g)/400),:Melee),%range-cmb $+($calc(%h /400),:,Range),%mage-cmb $+($calc(%i /400),:,Mage)
  ;final combat calculation
  var %sort $sorttok(%melee-cmb %range-cmb %mage-cmb,32,nr)
  var %base $iif($8,%p2pbase,%f2pbase),%highest $gettok(%sort,1,58),%class $+([,$token($token(%sort,2,58),1,32),])
  return $calc(%highest + %base) $iif(!$prop,%class)
}
alias -l nextlevel { 
  var %string Att/Str: Def/Cns: Prayer: Summ:,%i 1,
  var %p2p $ncmb($1-),%f2p $ncmb($puttok($1-,0,8,32))
  while (%i <= 4) {
    var %l $+(%i,-,$calc(%i +1)),%stat $token($1-,%l,32)
    var %str $iif(%i == 4,$token($1-,8,32),$token(%stat,1,32) || $token(%stat,2,32)) 
    var %f $token(%f2p,%i,32),%p $token(%p2p,%i,32)
    var %x %x $iif(%str < 99,$iif(%p || %f,$c2($prop,$token(%string,%i,32)) $&
      $c1($prop,%p $+($chr(40),$iif(%i == 4,0,%f),$chr(41)))))
    inc %i
  }
  return %x
}
alias -l ncmb {
  var %stats $1-,%cmb $cmb(%stats),%i 1,%ntok $numtok($1-,32)
  var %nextlevel $calc($floor($cmb(%stats).base) +1),%result
  while (%i <= %ntok) {
    var %statstart $token(%stats,%i,32),%stat %statstart
    var %tempstats $puttok(%stats,%stat,%i,32)
    while ($floor($cmb(%tempstats).base) < %nextlevel) {
      inc %stat
      var %tempstats $puttok(%stats,%stat,%i,32)
    }
    var %result %result $calc(%stat - %statstart)
    inc %i
  }
  tokenize 32 %result
  var %which.stats $iif(*melee* iswm %cmb,$1 $3,$iif(*range* iswm %cmb,$5,$7)) 
  return %which.stats $6 $8
}
alias -l otherstats return $regex($$1,/(Overall|Bounty|Bounty-Rogue|FOG|BA-Attacker|BA-Defender|BA-Collector|BA-Healer)/Si)
alias -l elg {
  if ($1 == $chr(60)) { return less than }
  elseif ($1 == $chr(61)) { return equal to }
  elseif ($1 == $chr(62)) { return greater than }
}
alias -l skill {
  if ($regex($1,/^(overall|total)/Si)) Return Overall 
  elseif ($regex($1,/^(att|atk|attack)/Si)) Return Attack 
  elseif ($regex($1,/^(str|strenth|strength)/Si)) Return Strength 
  elseif ($regex($1,/^(def|defence)/Si)) Return Defence 
  elseif ($regex($1,/^(hp|hits|hitpoints|constitution)/Si)) Return Constitution 
  elseif ($regex($1,/^(range|ranging)/Si)) Return Ranged 
  elseif ($regex($1,/^(pray(er)?)/Si)) Return Prayer 
  elseif ($regex($1,/^(mage|magic)/Si)) Return Magic
  elseif ($regex($1,/^(cook|cooking)/Si)) Return Cooking
  elseif ($regex($1,/^(wc|wood(cut(ting)?))/Si)) Return Woodcutting
  elseif ($regex($1,/^(fletch|fletching)/Si)) Return Fletching
  elseif ($regex($1,/^(fishing|fish)/Si)) Return Fishing
  elseif ($regex($1,/^(fm|fire|firemaking)/Si)) Return Firemaking
  elseif ($regex($1,/^(craft|crafting)/Si)) Return Crafting
  elseif ($regex($1,/^(smithing|smith)/Si)) Return Smithing
  elseif ($regex($1,/^(mine|mining)/Si)) Return Mining
  elseif ($regex($1,/^(herb|Herblore)/Si)) Return Herblore
  elseif ($regex($1,/^(agil|agility)/Si)) Return Agility
  elseif ($regex($1,/^(theif|theiv|thiev|theiving|thieving)/Si)) return Thieving
  elseif ($regex($1,/^(slay|Slayer)/Si)) Return Slayer
  elseif ($regex($1,/^(farm|Farming)/Si)) Return Farming
  elseif ($regex($1,/^(rune|rc|runecrafting|runecraft)/Si)) Return Runecraft
  elseif ($regex($1,/^(hunt|hunting|hunter)/Si)) Return Hunter
  elseif ($regex($1,/^(con|construction)/Si)) Return Construction 
  elseif ($regex($1,/^(sum|summ|summon|summoning)/Si)) Return Summoning 
  elseif ($regex($1,/^(dung?(eon)?|dg)/Si)) Return Dungeoneering
}
alias -l skillparams {
  ;$1 nickforcolours, $2 skill, $3 xptillnxt,$4 current level
  var %b $c1($1,|),%cn $1,%skill $iif($regex($2,/^(attack|strength|defence)/Si),combat,$2)
  var %defparams $readini(defparams.ini,n,params,%skill)
  var %params $iif($readini(Mylist.ini,n,$address($1,2),$2),$v1,$iif(%skill == Magic,$+(%defparams,`,$lvlspell($3),$iif($3 >= 70,`Ice burst:40),$iif($3 >= 94,`Ice barrage:52)),%defparams))
  if ($2 != Summoning) {
    var %n $numtok(%params,96),%x 1,%xptillnxt $3
    while (%x <= %n) {
      tokenize 58 $token(%params,%x,96)
      var %div1 $iif(%skill != Smithing,[.]),%div3 $iif(%skill == Smithing,$c1(%cn,/))
      var %a %a $c1(%cn,$1) $c2(%cn,$bytes($ceil($calc(%xptillnxt / $2)),db)) $+ $iif($token($2,2,32),%div3) $&
        $iif($v1,$c2(%cn,$+($token(%div1,1,46),$bytes($ceil($calc(%xptillnxt / $v1)),db),$token(%div1,2,46)))) $+ $iif($token($2,3,32),%div3) $&
        $iif($v1,$c2(%cn,$+($token(%div1,1,46),$bytes($ceil($calc(%xptillnxt / $v1)),db),$token(%div1,2,46)))) $iif(%x != %n,%b)
      inc %x
    }
    var %txt $iif(%skill == Prayer,Buried $c2(%cn,[Ecto] [Altar]),$iif(%skill == Ranged,NPC [cannon],$iif(%skill == Smithing,$+($c2(%cn,Smelt),$c1(%cn,/),$c2(%cn,Smith),$c1(%cn,/),$c2(%cn,Both))))) 
    return %txt %a 
  }
  else {
    var %mylist $readini(Mylist.ini,n,$address($1,2),$2)
    var %x Gold Crimson Green Blue,%n $iif(%mylist,$numtok(%params,96),4),%l 1
    while (%l <= %n) {
      var %params $iif(%mylist,$token(%mylist,%l,96),$($+($,makewhat,$chr(40),$4,$chr(41),.,$token(%x,%l,32)),2)),$&
        %exp $token(%params,6,64),%shards $token(%params,5,64),%name $token(%params,2,64),$&
        %charm $replace($iif(%mylist,$token(%params,3,64),$token(%x,%l,32)),Gold,07Gold,Crimson,04Crimson,Blue,02Blue,Green,03Green)
      var %a %a $c2(%cn,%name) $+($c1(%cn,[),$bytes($ceil($calc($3 / %exp)),bd),x,%charm,$c1(%cn,])) $&
        $+([S:,$bytes($ceil($calc(($3 /%exp) * %shards)),bd),]) $iif(%l != %n,%b)
      inc %l
    }
    return %a
  }
}
alias -l lvlspell {
  if ($1 isnum 3-35) return Fire bolt:22.5 
  elseif ($1 isnum 36-47) return Water blast:28.5 
  elseif ($1 isnum 48-53) return Earth blast:31.5 
  elseif ($1 isnum 54-59) return Fire blast:34.5 
  elseif ($1 isnum 60-65) return Water wave:37.5 
  elseif ($1 isnum 66-70) return Earth wave:40 
  elseif ($1 isnum 71-75) return Fire wave:42.5 
  elseif ($1 isnum 76-81) return Wind surge:75 
  elseif ($1 isnum 82-85) return Water surge:80 
  elseif ($1 isnum 86-90) return Earth Surge:85
  else return Fire surge:90 
}
alias -l charmdisplay {
  var %number $rp($3),%cn $1
  tokenize 64 $($+($,makewhat,$chr(40),$2,$chr(41),.,$4),2)
  if ($prop == Charms) {
    return $c2(%cn,$2) $replace($3,Gold,07Gold,Crimson,04Crimson,Blue,02Blue,Green,03Green) $&
      $+($c1(%cn,Shards:) $c2(%cn,$5) $c1(%cn,$chr(40)),$c2(%cn,$bytes($ceil($calc($5 * %number)),db)),$c1(%cn,$chr(41)) $&
      $c1(%cn,Exp:) $c2(%cn,$bytes($ceil($6),db)) $c1(%cn,$chr(40)),$c2(%cn,$bytes($ceil($calc($6 * %number)),db)),$c1(%cn,$chr(41)) $&
      $c1(%cn,Cost:) $c2(%cn,$bytes($calc($5 * %number *25),db)) gp)
  }
}
alias -l makewhat {
  ;($1 Level) ($2 Pouch) ($3 Charm) ($4 Seconds) ($5 Shards) ($6 exp)
  ;Gold
  if ($prop == Gold) {
    if ($1 isnum 1-3) return 1@Spirit wolf@Gold@Wolf bones@7@4.8 
    elseif ($1 isnum 4-9) return 4@Dreadfowl@Gold@Raw chicken@8@9.3 
    elseif ($1 isnum 10-12) return 10@Spirit spider@Gold@Spider carcass@8@12.6 
    elseif ($1 isnum 13-15) return 13@Thorny snail@Gold@Thin snail@9@12.6 
    elseif ($1 isnum 16-16) return 16@Granite crab@Gold@Iron ore@7@21.6 
    elseif ($1 isnum 17-39) return 17@Mosquito@Gold@Proboscis@1@46.5 
    elseif ($1 isnum 40-51) return 40@Bull ant@Gold@Marigolds@11@52.8
    elseif ($1 isnum 52-65) return 52@Spirit terrorbird@Gold@Raw bird meat@12@68.4 
    elseif ($1 isnum 66-66) return 66@Barker toad@Gold@Swamp toad@11@87.0 
    elseif ($1 isnum 67-70) return 67@War tortoise@Gold@Tortoise shell@1@58.6 
    elseif ($1 isnum 71-126) return 71@Arctic bear@Gold@Polar kebbit fur@14@93.2 
  }
  ;Green
  elseif ($prop == Green) {
    if ($1 isnum 18-27) return 18@Desert wyrm@Green@Bucket of sand@45@31.2 
    elseif ($1 isnum 28-32) return 28@Compost mound@Green@Compost@47@49.8 
    elseif ($1 isnum 33-33) return 33@Beaver@Green@Willow logs@72@57.6 
    elseif ($1 isnum 34-40) return 34@Void ravager@Green@Ravager charm@74@59.6 
    elseif ($1 isnum 41-42) return 41@Macaw@Green@Clean guam@78@72.4 
    elseif ($1 isnum 43-46) return 43@Spirit Cockatrice or variants@Green@Cockatrice egg@88@75.2 
    elseif ($1 isnum 47-53) return 47@Magpie@Green@Gold ring@88@83.2 
    elseif ($1 isnum 54-55) return 54@Abyssal parasite@Green@Abyssal charm@106@94.8 
    elseif ($1 isnum 56-61) return 56@Ibis@Green@Harpoon@109@98.8 
    elseif ($1 isnum 62-67) return 62@Abyssal lurker@Green@Abyssal charm@119@109.6 
    elseif ($1 isnum 68-68) return 68@Bunyip@Green@Raw shark@110@119.2 
    elseif ($1 isnum 69-75) return 69@Fruit bat@Green@Banana@130@121.2 
    elseif ($1 isnum 76-77) return 76@Forge Regent@Green@Ruby harvest@141@134.0 
    elseif ($1 isnum 78-79) return 78@Giant ent@Green@Willow branch@124@136.8 
    elseif ($1 isnum 80-87) return 80@Hydra@Green@Water orb@128@140.8 
    elseif ($1 isnum 88-92) return 88@Unicorn stallion@Green@Unicorn horn@140@154.4 
    elseif ($1 isnum 93-126) return 93@Abyssal Titan@Green@Abyssal charm@113@163.2 
  }
  ;Crimson
  elseif ($prop == Crimson) {
    if ($1 isnum 19-21) return 19@Spirit scorpion@Crimson@Bronze claws@57@83.2  
    elseif ($1 isnum 22-30) return 22@Spirit Tz-Kih@Crimson@Obsidian charm@64@96.8  
    elseif ($1 isnum 31-31) return 31@Vampire bat@Crimson@Vampire dust@81@136.0  
    elseif ($1 isnum 32-41) return 32@Honey badger@Crimson@Honeycomb@84@140.8  
    elseif ($1 isnum 42-45) return 42@Evil turnip@Crimson@Evil Carved turnip@104@184.8  
    elseif ($1 isnum 46-48) return 46@Pyrelord@Crimson@Tinderbox@111@202.4  
    elseif ($1 isnum 49-60) return 49@Bloated leech@Crimson@Raw beef@117@215.2  
    elseif ($1 isnum 61-62) return 61@Smoke devil@Crimson@Goat horn dust@141@268.0  
    elseif ($1 isnum 63-63) return 63@Spirit cobra@Crimson@Snake hide@116@276.8  
    elseif ($1 isnum 64-69) return 64@Stranger plant@Crimson@Bagged plant 1@128@281.6  
    elseif ($1 isnum 70-71) return 70@Ravenous Locust@Crimson@Pot of flour@79@132.0  
    elseif ($1 isnum 72-73) return 72@Phoenix@Crimson@Phoenix quill@165@302.0  
    elseif ($1 isnum 74-74) return 74@Granite lobster@Crimson@Granite (500g)@166@325.6  
    elseif ($1 isnum 75-76) return 75@Praying mantis@Crimson@Flowers -Red-@168@329.6  
    elseif ($1 isnum 77-82) return 77@Talon beast@Crimson@Talon beast charm@174@1015.2  
    elseif ($1 isnum 83-84) return 83@Spirit dagannoth@Crimson@Dagannoth hide@1@364.8  
    elseif ($1 isnum 85-91) return 85@Swamp Titan@Crimson@Swamp lizard@150@373.6  
    elseif ($1 isnum 92-94) return 92@Wolpertinger@Crimson@Raw rabbit+Wolf bones@203@404.8  
    elseif ($1 isnum 95-95) return 95@Iron Titan@Crimson@Iron platebody@198@417.6  
    elseif ($1 isnum 96-98) return 96@Pack yak@Crimson@Yak-hide@211@422.4  
    elseif ($1 isnum 99-126) return 99@Steel Titan@Crimson@Steel platebody@198@417.6  
  }
  ;Blue
  elseif ($prop == Blue) {
    if ($1 isnum 23-24) return 23@Albino rat@Blue@Raw rat meat@75@202.4  
    elseif ($1 isnum 25-28) return 25@Spirit kalphite@Blue@Potato cactus@51@220.0  
    elseif ($1 isnum 29-33) return 29@Giant Chinchompa@Blue@Chinchompa@84@255.2  
    elseif ($1 isnum 34-33) return 34@Void spinner@Blue@Spinner charm@74@59.6  
    elseif ($1 isnum 34-33) return 34@Void torcher@Blue@Torcher charm@74@59.6  
    elseif ($1 isnum 34-35) return 34@Void shifter@Blue@Shifter charm@74@59.6  
    elseif ($1 isnum 36-45) return 36@Bronze minotaur@Blue@Bronze bar@102@316.8  
    elseif ($1 isnum 46-54) return 46@Iron minotaur@Blue@Iron bar@125@404.8  
    elseif ($1 isnum 55-55) return 55@Spirit jelly@Blue@Jug of water@151@484.0  
    elseif ($1 isnum 56-56) return 56@Steel minotaur@Blue@Steel bar@141@492.8  
    elseif ($1 isnum 57-56) return 57@Spirit Graahk@Blue@Graahk fur@154@501.6  
    elseif ($1 isnum 57-56) return 57@Spirit Kyatt@Blue@Kyatt fur@153@501.6  
    elseif ($1 isnum 57-57) return 57@Spirit Larupia@Blue@Larupia fur@153@501.6  
    elseif ($1 isnum 58-65) return 58@Karamthulhu overlord@Blue@Fishbowl -Empty-@144@510.4  
    elseif ($1 isnum 66-72) return 66@Mithril minotaur@Blue@Mithril bar@152@580.8  
    elseif ($1 isnum 73-75) return 73@Obsidian Golem@Blue@Obsidian charm@195@642.4  
    elseif ($1 isnum 76-78) return 76@Adamant minotaur@Blue@Adamantite bar@144@668.8  
    elseif ($1 isnum 79-79) return 79@Fire Titan@Blue@Fire talisman@198@695.2  
    elseif ($1 isnum 79-82) return 79@Moss Titan@Blue@Earth talisman@202@695.2  
    elseif ($1 isnum 83-85) return 83@Lava Titan@Blue@Obsidian charm@219@730.4  
    elseif ($1 isnum 86-88) return 86@Rune minotaur@Blue@Runite bar@1@756.8  
    elseif ($1 isnum 89-126) return 89@Geyser Titan@Blue@Water talisman@222@783.2  
  }
}
alias rings {
  ;Thanks to RSWiki for making this data publicly available.
  ;http://runescape.wikia.com/wiki/Fairy_ring
  if ($regex($1-,/East/Si)) return CKS@Canifis Mushroom Patch-DLS@Canifis Pub-ALQ@Haunted Woods-BKR@Mort Myre Swamp-BIQ@Khardian Desert (NorthWest)-DLQ@ Kharidian Desert (East)
  elseif ($regex($1-,/(C|S)ent(er|re)/Si)) return DKR@EdgeVille-DIS@Wizard Tower-AIQ@MudSkipper Point-BLP@TzHaar-DKP@Karambwan Fishing Area-CKR@Southern Karajima-
  elseif ($regex($1-,/West/Si)) return AKQ@Woodlands Hunting Area-AJS@Penguin Island-CIP@Miscellania-DKS@Keldagrim and Snow Hunting-AJR@Slayer Cave-CJR@Sinclair Mansion-DJR@Sinclair Mansion-ALS@McGrubor's Wood-BLR@Legend's Guild-BIS@Unicorn Pen Ardougne Zoo-DJP@Necromancer-CIQ@South Tree Gnome Village-CLS@Hazelmere-BKP@Chompy Frog Pond West-AKS@Chompy Frog Pond SouthEast-BJQ@Ancient Cavern
  elseif ($regex($1-,/Slay(er)?/Si)) return AJR@Slayer Cave-CKS@Slayer Tower-BJQ@Ancient Cavern-ALR@Abyssal Demons
  elseif ($regex($1-,/Farm(ing|er)?/Si)) return ALQ@NorthWest Port Phasmatys-AJR@Troll Stronghold 
  elseif ($regex($1-,/(^AIQ$)|Mud(skip(p)?(er)?)?/i)) return AIQ@Asgarnia MudSkipper Point  
  elseif ($regex($1-,/(^AJQ$)|Dorgesh|Kaan/i)) return AJQ@Dark cave south of Dorgesh-Kaan 
  elseif ($regex($1-,/(AJR)|Rock( )?Crab(s)?|^Slayer( cave)$/i)) return AJR@Slayer Cave SouthEast of Relleka, Troll Strong Hold, and Rock Crabs
  elseif ($regex($1-,/(^AKQ$)|Kandarin|Piscatoris|Fishing Colony|Phoenix|Falcon(er|ing)?|Monk( )?(Fish)?/i)) return AKQ@Kandarin: Piscatoris, Phoenix Cave, Falconer, and MonkFish
  elseif ($regex($1-,/(^AKS$)|Jungle Hunt|Chompy/i)) return AKQ@Feldip area 
  elseif ($regex($1-,/(^ALQ$)|Morytania|Haunt(ed)? Wood(s)?/i)) return ALQ @ Mortyania: Haunted Woods East of Canifis  
  elseif ($regex($1-,/(^ALS$)|McGrubor|Coal Truck|Fish(ing)? Guild/i)) return ALS@Kandarin: McGrubor's Wood, Coal Trucks, Fishing Guild, Hemenster  
  elseif ($regex($1-,/(^KIQ$)$|Kalphite|Shanty|Bedabin/i)) return BIQ@Kharidian Desert: Shanty, Kalphite Lair, Bedabin Camp 
  elseif ($regex($1-,/(^BJQ$)|Ancient Cavern|Waterfiend|Kuradal|Mithril D(ragon)?/i)) return BJQ@ Ancient Cavern: Mirthril Dragons and Waterfieds  
  elseif ($regex($1-,/(^BJR$)|Fish(ing|er)? Re(a)?lm/i)) return BJR@Fisher Realm  
  elseif ($regex($1-,/(^BKP$)|Feldip Hill?|Chompy|C(astle)?W(ars)?|Jiggig/i)) return BKP@Feldip Hills, South of CastleWars, Chompy, and Jiggig 
  elseif ($regex($1-,/(^BKR$)|Mory(tania)?|Mort( Myre)?|Canifis|Nature Spirit/i)) return BKR@Morytania: Mort Myre, Canifis, Nature Spirit Alter 
  elseif ($regex($1-,/(^BLP$)|TzHarr|Fire Cape|Onyx/i)) return BLP@TzHarr  
  elseif ($regex($1-,/(^BLR$)|Legend(\')?(s)?|Thormac( Tower)?/i)) return BLR@Legends Guild, Thormac's Tower Witchaven 
  elseif ($regex($1-,/(^CIP$)|Miscellania|Kingdom/i)) return CIP@Miscellania 
  elseif ($regex($1-,/(^CIQ$)|Yan(v)?ille|Tree( )?Gnome( )?(Village)?/i)) return CIQ@Yanille: Tree Gnome Village and Castle Wars 
  elseif ($regex($1-,/(^CJR$)|Rel(l)?iek(k)?a|(Seers|Cam(alot|my)) (Maple|Tree)/i)) return CJR@Kandarin: Relieka, Seers/Camalot Maple Trees  
  elseif ($regex($1-,/(^CKR$)|Kar(a|i)mja|Nature Alt(e|a)r|Karam(bwanji)?/i)) return CKR@Karamja: Shilo, Nature Alter, Tai Bwo Wannai  
  elseif ($regex($1-,/(^CKS$)|Morytania|Kharyll|Mushroom|Burgh De Rott|Slayer Tower/i)) return CKS@Morytania: Kharyll Teleport, Mushroom Patch, Burgh De Rott, Slayer Tower  
  elseif ($regex($1-,/(^CLS$)|Yan(v)?ille Island/i)) return CLS@Yanille Island: Hazelmere and Jungle Spiders 
  elseif ($regex($1-,/(^DIS$)|Wizard Tower|Draynor|Lumberage( Swamp)?|R(une)?C(rafting)? Guild/i)) return DIS@Misthalin: Wizard Tower, Draynor, Lumberage Swamp, RuneCrafting Guild 
  elseif ($regex($1-,/(^DJP$)|Tower( Of)?( Life)?|Ard(y|ougne)|Port khazard/i)) Return DJP@Kandarin:  Tower of Life, Ardougne, and Port Khazard 
  elseif ($regex($1-,/(^DJR$)|Sinclair( Mansion)?/i)) return DJR@Kandarin: Sinclair Mansion 
  elseif ($regex($1-,/(^DKP$)|Musa( Point)?/i)) return DKP@Musa Point  
  elseif ($regex($1-,/(^DKR$)|Edge(ville)?|G(rand)?E(xchange)?/i)) return DKR@Misthalin: EdgeVille and GrandExchange  
  elseif ($regex($1-,/(^DKS$)|(Snow(y)?|Polar) Hunt(er)?/i)) return DKS@Kandarin: Snowy/Polar Hunder Area 
  elseif ($regex($1-,/(^DLQ$)|(Desert)?Lizard(s)?|Nardah|Ruin(s)?Uzer/i)) return DLQ@Kharidian: Desert Lizards, Nardah, Ruins Uzer 
  elseif ($regex($1-,/(^DLS$)|Myreque Hidout|Hollow(s)?|Blood( Alt(a|e)r)?/i)) return DLS@Myreque: Hollows and Blood Alter
  elseif ($regex($1-,/(^DIP$)|Mos(Le'Harmless)?|Cave(Horror)?$/i)) return DIP@Mos Le'Harmless: Island South Of Cave Horrors
  elseif ($regex($1-,/(^CLR$)|ape atol?|atol?/i)) return CLR@Ape Atoll: agility course
  else return Error
}
alias onoff {
  if ($regex($1,/public/Si)) return public
  elseif ($regex($1,/(rsp|rsplayers)$/Si)) return rsp
  elseif ($regex($1,/skills$/Si)) return skills
  elseif ($regex($1,/l(oot)?s(hare)?$/Si)) return lootshare
  elseif ($regex($1,/(rs|runescape)news$/Si)) return rsnews
  elseif ($regex($1,/name(check)?/Si)) return namecheck
  elseif ($regex($1,/stats$/Si)) return stats
  elseif ($skill($1)) return $skill($1)
  elseif ($regex($1,/cmb-est$/Si)) return cmb-est
  elseif ($regex($1,/co?mba?t?%?/Si)) return cmb
  elseif ($regex($1,/(high|low)$/Si)) return highlow
  elseif ($regex($1,/(le?ve?l|exp)( |$)/Si)) return level
  elseif ($regex($1,/rank$/Si)) return rank
  elseif ($regex($1,/compare$/Si)) return compare
  elseif ($regex($1,/Charm(s)?/Si)) return charm
  elseif ($regex($1,/spell$/Si)) return spell
  elseif ($regex($1,/(pouch|familiar)$/Si)) return pouch
  elseif ($regex($1,/potion$/Si)) return potion
  elseif ($regex($1,/(con)?grat[sz]\b/Si)) return gratz
  elseif ($regex($1,/F(airy(Ring)?|R)( |$)/Si))  return fairy
  elseif ($regex($1,/(gu|geupdate)$/Si)) return geupdate
  elseif ($regex($1,/ge$/Si)) && (!$regex($1,/geup/)) return ge
  elseif ($regex($1,/cs$/Si)) return coinshare
  elseif ($regex($1,/world$/Si)) return world
  elseif ($regex($1,/clan$/Si)) return clan
  elseif ($regex($1,/ml$/Si)) return memberlist
  elseif ($regex($1,/alog$/Si)) return alog
  elseif ($regex($1,/(npc|monster)$/Si)) return npc
  elseif ($regex($1,/quest$/Si)) return quest
  elseif ($regex($1,/(item|istats)$/Si)) return item
  elseif ($regex($1,/alch$/Si)) return alch
  elseif ($regex($1,/track?/Si)) return track
  elseif ($regex($1,/rswiki$/Si)) return rswiki
  elseif ($regex($1,/fml$/Si)) return fml
  elseif ($regex($1,/bash$/Si)) return bash
  elseif ($regex($1,/(urban|ud)$/Si)) return urban
  elseif ($regex($1,/weather$/Si)) return weather
  elseif ($regex($1,/(halo|h3)$/Si)) return halo 
  elseif ($regex($1,/(xbl|gc)$/Si)) return xbl
  elseif ($regex($1,/(gf|googlefight)$/Si)) return gf
  elseif ($regex($1,/cyborg$/Si)) return cyborg
  elseif ($regex($1,/(yt|youtube)$/Si)) return youtube
  elseif ($regex($1,/google$/Si)) return google
  elseif ($regex($1,/site$/Si)) return site
  elseif ($regex($1,/ascii$/Si)) return ascii
  elseif ($regex($1,/define$/Si)) return define
  elseif ($regex($1,/wave$/Si)) return wave
  elseif ($regex($1,/food$/Si)) return food
  elseif ($regex($1,/8ball$/Si)) return 8ball
  elseif ($regex($1,/onceaminute$/Si)) return onceaminute
  elseif ($regex($1,/calc(ulator)$/Si)) return calculator
}
alias -l pcheck { 
  elseif ($skill($1)) return skills
  if ($regex($1,/http://www.youtube.com/Si)) return yt 
  elseif (8ball isin $1) return 8ball
  elseif ($food($1)) return food
  else return $1
}
alias -l food {
  if ($regex($1,/^[!@~.](pepsi|cola|sprite|crapachino|tea)/Si)) return a refreshing cup of $regml(1)
  elseif ($regex($1,/^[!@~.](crumpet|waffle|kfc|chicken)/Si)) return a finger licking good $regml(1)
}
dialog cpanel {
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
  button "Update", 18, 54 100 37 12, cancel
}

On *:dialog:cpanel:init:*: {
  didtok $dname 4 32 02 03 04 06 07 10 13
  didtok $dname 2 35 $remove($readini(Hermes.ini,settings,Botchan),$chr(126))
  didtok $dname 3 35 $remove($readini(Hermes.ini,settings,Homechan),$chr(126))
  didtok $dname 9 96 $remove($readini(Hermes.ini,settings,noreply),$chr(126))
  didtok $dname 10 96 $remove($readini(Hermes.ini,settings,invmsg),$chr(126))
  did $iif($readini(Hermes.ini,settings,Botnews) == 1,-c,-u) $dname 13 
  didtok $dname 14 124 $iif($readini(Hermes.ini,settings,publictrig),$v1,@)
  didtok $dname 16 124 $iif($read(settings.txt),$v1,!.~`)
}
On *:dialog:cpanel:sclick:5: {
  writeini Hermes.ini Settings Colour $iif($did(4).seltext,$v1,13)
  writeini Hermes.ini Settings Botchan $did(2) 
  writeini Hermes.ini Settings Homechan $did(3) 
  writeini Hermes.ini Settings noreply $didtok(9,32)
  writeini Hermes.ini Settings invmsg $didtok(10,32)
  writeini Hermes.ini Settings Botnews $did(13).state
  writeini Hermes.ini Settings publictrig $left($didtok(14,32),1)
  write settings.txt $did(16)
  $iif($did(13).state == 1,/timerbotnews 0 $duration(1d) sockopen $+(botnews.,$right($ticks,5)) $&
    beardbot.netii.net 80,/timerbotnews off)
}
On *:dialog:cpanel:sclick:18: {
  if ($isalias(update)) {
    var %v $+(version.,$right($ticks,5))
    hadd -m %v update y
    sockopen %v beardbot.netii.net 80  
  }
}
menu * {
  -
  Hermes:Hermes 
  -
}
