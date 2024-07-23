print,"READONLYSEIS"
   close,1
   pi = 3.1415926535897
   test =3 
   spacescale = 1000.0

   modulmyu = 2.0e10
   filedir="/home/datdyn/becker/finel/"
   ;;filedir = ""
   ;;modeldir = filedir+"en_echelon/"+strtrim(test, 1)+"/"
   modeldir = filedir+"random/"+strtrim(test, 1)+"/"
   ;;modeldir=filedir+"eff_modul/"+strtrim(test, 1)+"/"
   ;;modeldir=filedir+"/home/bigusr/becker/model_data/arc_faults_again/"+strtrim(test, 1)+"/"

   
   
                                ; stresscompare und simpleshearfs vergleichen die 
                                ; tatsaechliche aktivierungsanzahl mit
                                ; der nach der coulombspannung
                                ; erwarteten. stats erstellt
                                ; momentstatistiken 
                                ; psprint erstellt PS images der
                                ; raeumlichen seismizitaet 


      print,"Working on "+modeldir
      
      print,"Reading  "+modeldir+"seis"
      openr,1,modeldir+"seis"
      readf,1,nrflt,start,stop
      m=dblarr(nrflt,stop-start+1)
      nract=intarr(stop-start+1)
      n=0 &  tmpfc=dblarr(2) &  ittimemax=0
      minmoment = 1.0e30
      maxmoment = 0.0
      while not eof(1) do begin
         readf,1,it,flt & readf,1,x1,y1 & readf,1,x2,y2 & readf,1,rupture_length
         readf,1,du,ds 
         time= it - start
         tmpmoment = rupture_length*spacescale*15000*abs(du)*spacescale*modulmyu
         IF(minmoment GT tmpmoment)THEN minmoment=tmpmoment
         IF(maxmoment LT tmpmoment)THEN maxmoment=tmpmoment
         n=n+1
      ENDWHILE
      close,1
      print, "Min moment:", minmoment, " Maxmoment: ", maxmoment
END 




