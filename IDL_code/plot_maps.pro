PRO plot_maps, FGMAPS=FGMAPS, LFIMAPS=LFIMAPS, HFIMAPS=HFIMAPS, $
               PLOTFREQ=PLOTFREQ, PLOTCMB=PLOTCMB, PLOTFG=PLOTFG, $
               BW=BW,EQUATORIAL=EQUATORIAL, $
               SHOWBAR=SHOWBAR, SHOWOUTLINE=SHOWOUTLINE

;+
; Using LS/AZ code to plot Planck maps in pretty way
;
; Keywords:
;   FWMAPS: set to reread foreground & CMB maps (otherwise use SAV file)
;   LFIMAPS: set to reread LFI maps (otherwise use SAV file)
;   HFIMAPS: set to reread HFI maps (otherwise use SAV file)
;   
;   PLOTFREQ: plot frequency maps
;   PLOTCMB: plot CMB map
;   PLOTFG: plot foreground maps
;   
;   BW: set to plot using Black & White and "red temperature" colour
;   scales, otherwise use "Planck" colour scale
;
;   EQUATORIAL: set to plot in Equatorial coordinates (otherwise use
;   Galactic coordinates
;
;   SHOWBAR: set to show colour bar
;   SHOWOUTLINE: set to plot outline around map
;
; Requirements:
;   Requires HEALPix (available from healpix.jpl.nasa.gov/)
;
;   Need to have compiles HFI_PLOT, LS_cartview and LS_data2cart to
;   use Planck colour scale (available from github.com/zonca/paperplots)
;   
; Resolutions:
;   Plots to resolutions between 100px and 12000px across. Change variables
;   Nmlist, NmlistBW, Nmlistred and Pxlist to alter that
;   (sorry, it's hard-coded at the moment!)
;
;   The first plot of each maps is printed to screen, so it is
;   recommended that you always use the 100px images (also useful as a
;   check)
;
; Example usage:
;   To plot all maps in Planck colour scale
;      PLOT_MAPS, /PLOTFREQ, /PLOTFG, /PLOTCMB, /SHOWOUTLINE
;
;   To plot all maps in B/W and red colour scales, with colour bar and
;   no outline
;      PLOT_MAPS, /PLOTFREQ, /PLOTFG, /PLOTCMB, /SHOWBAR, /BW
;
; Output files:
;   Filenames of PNG files set by selected options
;   Images use index colour table (not RGB/CMYK)
;   Resolutions refer to map width, but have empty space at top and
;   bottom.
;   High resolution files take a long time to produce and can be large.
;-

FDIR = '/export/data/spxcen/deltaDX9/' ;;;;;;!!!!!!!!  You need to change this to your local directory.

CTDIR = FDIR ;  The CTDIR needs to be a directory that IDL can read/write to.  
CTFILE = 'Planck_CT.tbl' ; The HFI_CT script will create this file for you as needed in the specified CTDIR directory
HDRDIR = CTDIR ; This is where the RGB vectors for the high dynamic range (frequency map colour table) are located, default is the same place as the CMB colour table.
HDRFILE = 'RGB_Planck_hdr.idl' ; This is the file containing the high dynamic range RGB vectors.  Put it in the specified HDRDIR folder (change the HDRDIR location as you see fit)

;;Directory with maps in
MDIR='/export/data/spxcen/deltaDX9/'

;;Path to FITS files

lfifits=[ $ 
        'Freqs/LFI_30_1024_20120914_nominal_1s', $
        'Freqs/LFI_44_1024_20120914_nominal_1s', $
        'Freqs/LFI_70_1024_20120912_nominal_1s']

hfifits=[ $
        'Freqs/HFI_100_2048_20120611_nominal', $
        'Freqs/HFI_143_2048_20120611_nominal', $
        'Freqs/HFI_217_2048_20120611_nominal', $
        'Freqs/HFI_353_2048_20120611_nominal', $
        'Freqs/HFI_545_2048_20121129_nominal_MJyResca_noZodi', $
        'Freqs/HFI_857_2048_20121129_nominal_MJyResca_noZodi']

fgfits=[ $
       'FG/dx9_delta_v1_7b_avrg_co', $
       'FG/dx9_delta_v1_7b_avrg_dust_flux', $
       'FG/dx9_delta_v1_7b_avrg_lowfreq', $
       'Masks/COM_CompMap_Mask-rulerminimal_2048_R1.00.fits']
;;'FG/COM_CompMap_Lensing_2048_R1.10.fits'


cmbfits=['CMB/dx9_smica_harmonic_cmb_inpainted_97']

IF KEYWORD_SET(PLOTCMB) OR KEYWORD_SET(PLOTFG) Then Begin
   IF KEYWORD_SET(FGMAPS) THEN BEGIN
      ;;Read in FG+CMB maps from files
      READ_FITS_MAP, MDIR+CMBfits+'.fits', mapcmb, hdr, ehdrcmb, NSIDE=NSCMB, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+FGfits[0]+'.fits', mapco, hdr, ehdrco, NSIDE=NSCO, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+FGfits[1]+'.fits', mapdust, hdr, ehdrdust, NSIDE=NSDUST, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+FGfits[2]+'.fits', maplow, hdr, ehdrlow, NSIDE=NSLOW, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      
      mapcmb=REFORM(mapcmb[*,0])         ;in uK already
      mapco=REFORM(mapco[*,0])           ;in uk km/s already
      mapdust=REFORM(mapdust[*,0])*1e6   ;in Jy/sr now
      maplow=REFORM(maplow[*,0])         ;in uk already
      
      ;;write to IDL SAV file for quick access next time
      SAVE, FILENAME=MDIR+'FG_maps.sav', mapcmb, mapco, mapdust, maplow, ehdrcmb, ehdrco, ehdrdust, ehdrlow
      ;;
      print, 'FG+CMB maps saved to an idl file. Hopefully this will restore quicker now.'
      ;;stop
   ENDIF ELSE BEGIN
      print,'Restoring FG+CMB maps from file...'
      RESTORE, FILENAME = MDIR+'FG_maps.sav'
   ENDELSE
   
   IF KEYWORD_SET(BW) THEN BEGIN
      ;;set min/max for Foregrounds colour scales
      ;;            co, dust, low, mask
      offsetlistfg=[0,    0,    0,   0.]
      minlistfg=   [1e-1, 1e4,  1e1, 0.]
      maxlistfg=   [1e3,  1e10, 2e7, 1.]
      ;;set whether to use log
      logfglist=   [1,    1,    1,   0]
      ;;set units for Foregrounds
      unitsFG=['uK km/s', 'Jy/sr', 'uK', '']
      
      ;;set min/max for CMB colour scale
      offsetcmb=0
      mincmb=-500
      maxcmb=500
   ENDIF ELSE BEGIN
      ;;Create cuts to make it look a *bit* prettier

      ;;mapco[where(mapco LT 0)]=1
      mapco=mapco*1e1
      ;;mapco[where(mapco LT -10)]=-10
      
      mapdust=mapdust/1d2
      mapdust[where(mapdust LT 1e2)]=1e2
      
      maplow=maplow
      maplow[where(maplow LE 1e1)]=1e1
      
      unitsFG=['x0.1 uK km/s', 'x100 Jy/sr', 'uK', '']
   ENDELSE
   
   unitsCMB='uK (CMB)'

ENDIF

IF KEYWORD_SET(PLOTFREQ) THEN BEGIN  
   IF KEYWORD_SET(LFImaps) THEN BEGIN
      ;;Read in LFI maps from files
      READ_FITS_MAP, MDIR+LFIfits[0]+'.fits', map30, hdr, ehdr30, NSIDE=NS30, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+LFIfits[1]+'.fits', map44, hdr, ehdr44, NSIDE=NS44, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+LFIfits[2]+'.fits', map70, hdr, ehdr70, NSIDE=NS70, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      
      map30 = REFORM(map30[*,0])*1d6   ; in uK now.
      map44 = REFORM(map44[*,0])*1d6   ; in uK now.
      map70 = REFORM(map70[*,0])*1d6   ; in uK now.
      ;;
      SAVE, FILENAME=MDIR+'LFI_maps.sav', map30, map44, map70, ehdr30, ehdr44, ehdr70
      ;;
      print, 'LFI maps saved to an idl file. Hopefully this will restore quicker now.'
      ;;stop
      ;;
   ENDIF ELSE BEGIN
      print,'Restoring LFI maps from file...'
      RESTORE, FILENAME = MDIR+'LFI_maps.sav'
   ENDELSE
   
   IF KEYWORD_SET(HFImaps) THEN BEGIN
      READ_FITS_MAP, MDIR+HFIfits[0]+'.fits', map100, hdr, ehdr100, NSIDE=NS, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+HFIfits[1]+'.fits', map143, hdr, ehdr143, NSIDE=NS, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+HFIfits[2]+'.fits', map217, hdr, ehdr217, NSIDE=NS, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+HFIfits[3]+'.fits', map353, hdr, ehdr353, NSIDE=NS, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+HFIfits[4]+'.fits', map545, hdr, ehdr545, NSIDE=NS, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      READ_FITS_MAP, MDIR+HFIfits[5]+'.fits', map857, hdr, ehdr857, NSIDE=NS, COORDSYS=COORD, ORDERING=ORDER, SILENT=SILENT
      ;;
      map100 = REFORM(map100[*,0])*1d6   ; in uK now.
      map143 = REFORM(map143[*,0])*1d6   ; in uK now.
      map217 = REFORM(map217[*,0])*1d6   ; in uK now.
      map353 = REFORM(map353[*,0])*1d6   ; in uK now.
      map545 = REFORM(map545[*,0])*1d6   ; in Jy/sr.
      map857 = REFORM(map857[*,0])*1d6   ; in Jy/sr now.
      ;;
      print, 'HFI maps saved to an idl file. Hopefully this will restore quicker now.'
      SAVE, FILENAME=MDIR+'HFI_maps.sav', map100, map143, map217, map353, map545, map857, ehdr100, ehdr143, ehdr217, ehdr353, ehdr545,ehdr857
      ;;
      ;;stop
      ;;
   ENDIF ELSE BEGIN
      ;;
      print, 'Restoring HFI maps from file...'
      RESTORE, FILENAME = MDIR+'HFI_maps.sav'    
      ;;
   ENDELSE
   
   if Keyword_set(BW) Then Begin
      ;;set offset and colour scale for freq maps
      offsetlistfreq=[3e2, 3e2, 5e2, 4e2, 4e2, 4e2, 0,    0,    0]
      minlistfreq=   [1e1, 1e1, 1e2, 1e1, 1e1, 1e2, 4e1, 2e3, 1e5]
      maxlistfreq=   [1e5, 1e5, 1e5, 1e4, 1e4, 1e5, 1e6,  1e7,  1e9]
      
   Endif Else Begin
      
      ;;  Apply the KMG magic offsets to the maps.
      map30 = map30 - 64.7d
      map44 = map44 - 24.1d
      map70 = map70 - 28.5d
      map100 = map100 - 30.1d
      map143 = map143 - 55.7d
      map217 = map217 - 133d    ;+ 100d
      map353 = map353 - 681d + 250d
      
      map545 = map545/1d3
      map857 = map857/1d3
      
   ENDELSE
   
   unitsFreq=['uK (CMB)','uK (CMB)','uK (CMB)','uK (CMB)','uK (CMB)','uK (CMB)','uK (CMB)','kJy/sr','kJy/sr']
   
ENDIF
print,'Plotting maps...'

winlim=1

MINVAL = -1d3 ; The minimum value to plot is -1000 uK  The CMB maps have a -1000,1000 uK_CMB scale
MAXVAL =  1d3                 ;; The maximum value to plot is  1000 uK
MINVAL_ = -1d3 ; The minimum value to plot is -1000 uK  The frequency maps have a -10^3 to +10^7 colour range.  
MAXVAL_ =  1d7 ; The maximum value to plot is  1000 uK  This range is hard coded (actually the 10^7/10^3 ratio is hard coded, but the decision by the EB is to hard code this plot range).

;;  Set the new colortable, use the /HIGHDR keyword and HDRFILE (high-dynamic-range-file) keyword to direct to your local copy of rgb_37.idl
;;
HFI_CT, CTDIR=CTDIR, CTFILE=CTFILE, /LOAD, /HIGHDR, HDRFILE=HDRFILE ; this tells me the location of the revised colour table, file CTFILE in directory CTDIR, 
;;       these are also inputs if you have a colourtable file already.  The LOAD keyword then loads the colour table after it has been created.
;;       The HDRDIR is where the high-dynamic range RGB vectors are stored.  The default location is the CTDIR location.  This file must be manually placed in the correct directory.

;; Make an outline for the lattitude and longitude lines. This is needed to draw an ellipse around the map [if desired]. 
;;
Ngrat = 181d   ; number of points for the additional graticule curves.
If keyword_set(EQUATORIAL) Then Begin
    out_ = {COORD:'Q',RA:DBLARR(Ngrat),DEC:DBLARR(Ngrat), LINESTYLE:0, PSYM:0, SYMSIZE:0} ; the outline structure accepted by mollview.
Endif Else Begin
    out_ = {COORD:'G',RA:DBLARR(Ngrat),DEC:DBLARR(Ngrat), LINESTYLE:0, PSYM:0, SYMSIZE:0} ; the outline structure accepted by mollview.
Endelse
;; 
Nout = 2                     ; the outline is done as two half-curves.
out = REPLICATE(out_,Nout)
;;
RA = DBLARR(Ngrat) ; held constant while DEC changes  ;  The RA and DEC are in healpix/mollview notation.
DEC = DINDGEN(Ngrat) - 90d      ; bottom to top, -90 to +90 deg.
;;
out[0].RA = RA - 180d           ;  The half curve at -180 deg.
out[0].DEC = DEC
out[0].LINESTYLE=0
;;
out[1].RA = RA + 180d           ;  The half curve at +180 deg.
out[1].DEC = DEC
out[1].LINESTYLE=0
;;
;;

if keyword_set(EQUATORIAL) Then Begin
   NmPref = 'Plots/PlanckFig_EQ_map_columbi1_IDL_HighDR_'
   NmPrefBW= 'Plots/PlanckFig_EQ_BW_map_'
   NmPrefred= 'Plots/PlanckFig_EQ_red_map_'
   coord=['G','Q']
Endif Else Begin
   NmPref = 'Plots/PlanckFig_map_columbi1_IDL_HighDR_'
   NmPrefBW= 'Plots/PlanckFig_BW_map_'
   NmPrefred= 'Plots/PlanckFig_red_map_'
   coord=['G','G']
Endelse
If keyword_set(showbar) Then Begin
   NmPref=NmPref+'colbar_'
   NmPrefBW=NmPrefBW+'colbar_'
   NmPrefred=NmPrefred+'colbar_'
   NOBAR=0
Endif Else Begin
   NOBAR=1
Endelse

If keyword_set(showoutline) Then Begin
   outline=out
Endif Else Begin
   NmPref=NmPref+'no-out_'
   NmPrefBW=NmPrefBW+'no-out_'
   NmPrefred=NmPrefred+'no-out_'
Endelse

;;Stuff for naming files of different resolutions
NmSuf = 'px'
Nm_100  = NmPref + '100' + NmSuf
Nm_250  = NmPref + '250' + NmSuf
Nm_500  = NmPref + '500' + NmSuf
Nm_1000 = NmPref + '1000'+ NmSuf
Nm_3000 = NmPref + '3000'+ NmSuf
Nm_6000 = NmPref + '6000'+ NmSuf
Nm_12000 = NmPref + '12000'+ NmSuf
Nm_100_BW  = NmPrefBW + '100' + NmSuf
Nm_250_BW  = NmPrefBW + '250' + NmSuf
Nm_500_BW  = NmPrefBW + '500' + NmSuf
Nm_1000_BW = NmPrefBW + '1000'+ NmSuf
Nm_3000_BW = NmPrefBW + '3000'+ NmSuf
Nm_6000_BW = NmPrefBW + '6000'+ NmSuf
Nm_12000_BW = NmPrefBW + '12000'+ NmSuf
Nm_100_red  = NmPrefred + '100' + NmSuf
Nm_250_red  = NmPrefred + '250' + NmSuf
Nm_500_red  = NmPrefred + '500' + NmSuf
Nm_1000_red = NmPrefred + '1000'+ NmSuf
Nm_3000_red = NmPrefred + '3000'+ NmSuf
Nm_6000_red = NmPrefred + '6000'+ NmSuf
Nm_12000_red = NmPrefred + '12000'+ NmSuf
;;Delete some entries below to plot fewer resolutions
;;Must be same as PXlist (see below)
Nmlist=[Nm_100, Nm_250, Nm_500, Nm_1000, Nm_3000, Nm_6000, Nm_12000]
NmlistBW=[Nm_100_BW, Nm_250_BW, Nm_500_BW, Nm_1000_Bw, Nm_3000_Bw, Nm_6000_BW, Nm_12000_BW]
Nmlistred=[Nm_100_red, Nm_250_red, Nm_500_red, Nm_1000_red, Nm_3000_red, Nm_6000_red, Nm_12000_red]

;;
PX_100  =  100
PX_250  =  250
PX_500  =  500
PX_1000 = 1000
PX_3000 = 3000
PX_6000 = 6000
PX_12000 = 12000
;;delete some entries to plot fewer resolutions
;;Must be same number as Nmlist, NmlistBW and Nmlistred (see above)
Pxlist=[PX_100, PX_250, PX_500, PX_1000, PX_3000, PX_6000, PX_12000]

;;delete entries to only plot some freqs/foregrounds
freqlist=['30','44','70','100','143','217','353','545','857']
fglist=['co','dust','low','mask']


Nres=n_elements(Pxlist)
Nfreq=n_elements(freqlist)
Nfg=n_elements(fglist)

;;for r=0,Nres-1 DO BEGIN
for r=0,nres-1 DO BEGIN
   
   IF keyword_set(BW) Then Begin
      ;;Plot B/W and red colour scales
      PX=Pxlist[r]
      Nmx=NmlistBW[r]
      Nmxc=Nmlistred[r]
      
      IF Keyword_set(PLOTCMB) Then Begin
         map=mapcmb
         Nm=Nmx+'_'+'CMB_moll'
         Nc=Nmx+'_'+'CMB_cart'
         Nmc=Nmxc+'_'+'CMB_moll'
         Ncc=Nmxc+'_'+'CMB_cart'
         WINDOW=r*2
         if PX GT winlim THEN WINDOW=-WINDOW
         mollview, map, NESTED=0, COLT=0, OFFSET=offsetcmb,$
                   MIN=mincmb, MAX=maxcmb, FLIP=0, COORD=coord, $
                   NOBAR=NOBAR, WINDOW=WINDOW, units=unitsCMB, $
                   OUTLINE=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nm+'.png'
         mollview, map, NESTED=0, COLT=3, OFFSET=offsetcmb,$
                   MIN=mincmb, MAX=maxcmb, FLIP=0, COORD=coord, $
                   nobar=nobar, WINDOW=WINDOW, units=unitsCMB, $
                   outline=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nmc+'.png'
         
         PY=PX/2
         reso_arcmin=360.*60./PX
         WINDOW=r*2 + 1
         if PX GT winlim THEN WINDOW=-WINDOW
         cartview, map, NESTED=0,COLT=0 ,OFFSET=offsetcmb,$
                   MIN=mincmb, MAX=maxcmb, FLIP=0, COORD=coord, $
                   TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                   PNG=FDIR+Nc+'.png', nobar=nobar, WINDOW=WINDOW, units=unitsCMB
         cartview, map, NESTED=0,COLT=3 ,OFFSET=offsetcmb,$
                   MIN=mincmb, MAX=maxcmb, FLIP=0, COORD=coord, $
                   TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                   PNG=FDIR+Ncc+'.png', nobar=nobar, WINDOW=WINDOW, units=unitsCMB
      ENDIF
      
      If keyword_set(plotFG) Then Begin
         for fg=0,nfg-1 Do Begin
            err=EXECUTE('map=map'+fglist[fg])
            Nm=Nmx+'_'+fglist[fg]+'_moll'
            Nc=Nmx+'_'+fglist[fg]+'_cart'
            Nmc=Nmxc+'_'+fglist[fg]+'_moll'
            Ncc=Nmxc+'_'+fglist[fg]+'_cart'
            
            WINDOW=(r*2*nfg)+fg*2
            if PX GT winlim THEN WINDOW=-1
            mollview, map, NESTED=0, COLT=0,$
                      LOG=logfglist[fg],OFFSET=offsetlistfg[fg],$
                      MIN=minlistfg[fg], MAX=maxlistfg[fg], FLIP=0, COORD=coord, $
                      NOBAR=nobar, WINDOW=WINDOW, units=unitsfg[fg], $
                      outline=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nm+'.png'
            mollview, map, NESTED=0, COLT=3,$
                      LOG=logfglist[fg],OFFSET=offsetlistfg[fg],$
                      MIN=minlistfg[fg], MAX=maxlistfg[fg], FLIP=0, COORD=coord, $
                      NOBAR=nobar, WINDOW=WINDOW, units=unitsfg[fg], $
                      outline=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nmc+'.png'
            
            PY=PX/2
            reso_arcmin=360.*60./PX
            WINDOW=(r*2*nfg) + fg*2 + 1
            if PX GT winlim THEN WINDOW=-1
            cartview, map, NESTED=0,COLT=0,$
                      LOG=logfglist[fg],OFFSET=offsetlistfg[fg],$
                      MIN=minlistfg[fg], MAX=maxlistfg[fg], FLIP=0, COORD=coord, $
                      TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                      PNG=FDIR+Nc+'.png', /nobar, WINDOW=WINDOW, units=unitsfg[fg]
            cartview, map, NESTED=0,COLT=3,$
                      LOG=logfglist[fg],OFFSET=offsetlistfg[fg],$
                      MIN=minlistfg[fg], MAX=maxlistfg[fg], FLIP=0, COORD=coord, $
                      TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                      PNG=FDIR+Ncc+'.png', nobar=nobar, WINDOW=WINDOW, units=unitsfg[fg]
         ENDFOR
      ENDIF
      
      If Keyword_set(PlotFREQ) Then Begin
         for f=0,nfreq-1 Do Begin
            err=EXECUTE('map=map'+freqlist[f])
            Nm=Nmx+'_'+freqlist[f]+'GHz_moll'
            Nc=Nmx+'_'+freqlist[f]+'GHz_cart'
            Nmc=Nmxc+'_'+freqlist[f]+'GHz_moll'
            Ncc=Nmxc+'_'+freqlist[f]+'GHz_cart'
            
            WINDOW=r*2
            if PX GT winlim THEN WINDOW=-1
            mollview, map, /NESTED, COLT=0,/LOG,OFFSET=offsetlistfreq[f],$
                      MIN=minlistfreq[f], MAX=maxlistfreq[f], FLIP=0, $
                      nobar=nobar, WINDOW=WINDOW, COORD=coord, units=unitsFreq[f], $
                      outline=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nm+'.png'
            mollview, map, /NESTED, COLT=3,/LOG,OFFSET=offsetlistfreq[f],$
                      MIN=minlistfreq[f], MAX=maxlistfreq[f], FLIP=0, $
                      nobar=nobar, WINDOW=WINDOW, COORD=coord, units=unitsFreq[f], $
                      outline=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nmc+'.png'
            
            PY=PX/2
            reso_arcmin=360.*60./PX
            WINDOW=r*2 + 1
            if PX GT winlim THEN WINDOW=-1
            cartview, map, /NESTED,COLT=0,/LOG,OFFSET=offsetlistfreq[f],$
                      MIN=minlistfreq[f], MAX=maxlistfreq[f], FLIP=0, $
                      TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                      PNG=FDIR+Nc+'.png', nobar=nobar, WINDOW=WINDOW, COORD=coord, $
                      units=unitsFreq[f]
            cartview, map, /NESTED,COLT=3,/LOG,OFFSET=offsetlistfreq[f],$
                      MIN=minlistfreq[f], MAX=maxlistfreq[f], FLIP=0, $
                      TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                      PNG=FDIR+Ncc+'.png', nobar=nobar, WINDOW=WINDOW, COORD=coord, $
                      units=unitsFreq[f]
         ENDFOR
      ENDIF
   ENDIF ELSE BEGIN
      
      ;;Use "Planck" colour scale
      
      PX=Pxlist[r]
      Nmx=Nmlist[r]
      
      IF Keyword_SET(PlotCMB) Then Begin
         map=mapcmb
         Nm=Nmx+'_'+'CMB_moll'
         Nc=Nmx+'_'+'CMB_cart'
         
         WINDOW=r*2
         if PX GT winlim THEN WINDOW=-WINDOW
         LS_mollview, map, NESTED=0, COLT=41, CTDIR=CTDIR, CTFILE=CTFILE, $
                      MIN=MINVAL_, MAX=MAXVAL_, FLIP=0, nobar=nobar, WINDOW=WINDOW, $
                      outline=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nm+'.png', $
                      CBLBL=unitsCMB, /CBLIN, /MODASINH, /CBTICKS, /CBTICKLAB, /CBOUT, $
                      COORD=coord
         
         PY=PX/2
         reso_arcmin=360.*60./PX
         WINDOW=r*2 + 1
         if PX GT winlim THEN WINDOW=-WINDOW
         LS_cartview, map, NESTED=0, COLT=41, CTDIR=CTDIR, CTFILE=CTFILE, $
                      MIN=MINVAL_, MAX=MAXVAL_, FLIP=0, $
                      TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                      PNG=FDIR+Nc+'.png', nobar=nobar, WINDOW=WINDOW, COORD=coord, $
                      CBLBL=unitsCMB, /CBLIN, /MODASINH, /CBTICKS, /CBTICKLAB, /CBOUT 
      ENDIF
      
      If keyword_Set(PlotFG) Then Begin
         for fg=0,nfg-1 Do Begin
            err=EXECUTE('map=map'+fglist[fg])
            Nm=Nmx+'_'+fglist[fg]+'_moll'    
            Nc=Nmx+'_'+fglist[fg]+'_cart'
            
            WINDOW=r*2*nfg + fg*2
            if PX GT winlim THEN WINDOW=-WINDOW
            LS_mollview, map, NESTED=0, COLT=41, CTDIR=CTDIR, CTFILE=CTFILE, $
                         MIN=MINVAL_, MAX=MAXVAL_, FLIP=0, nobar=nobar, WINDOW=WINDOW, $
                         outline=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nm+'.png', $
                         CBLBL=unitsFG[fg], /CBLIN, /MODASINH, /CBTICKS, /CBTICKLAB, /CBOUT, $
                         COORD=coord
            
            PY=PX/2
            reso_arcmin=360.*60./PX
            WINDOW=r*2*nfg + fg*2 + 1
            if PX GT winlim THEN WINDOW=-WINDOW
            LS_cartview, map, NESTED=0, COLT=41, CTDIR=CTDIR, CTFILE=CTFILE, $
                         MIN=MINVAL_, MAX=MAXVAL_, FLIP=0, $
                         TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                         PNG=FDIR+Nc+'.png', nobar=nobar, WINDOW=WINDOW, COORD=coord, $
                         CBLBL=unitsFG[fg], /CBLIN, /MODASINH, /CBTICKS, /CBTICKLAB, /CBOUT 
         ENDFOR
      ENDIF
      
      IF KEYWORD_SET(PLOTFREQ) Then Begin
         for f=0,nfreq-1 Do Begin
            err=EXECUTE('map=map'+freqlist[f])
            Nm=Nmx+'_'+freqlist[f]+'GHz_moll'    
            Nc=Nmx+'_'+freqlist[f]+'GHz_cart'
            
            WINDOW=r*2
            if PX GT winlim THEN WINDOW=-WINDOW
            LS_mollview, map, /NESTED, COLT=41, CTDIR=CTDIR, CTFILE=CTFILE, $
                         MIN=MINVAL_, MAX=MAXVAL_, FLIP=0, nobar=nobar, WINDOW=WINDOW, $
                         outline=outline, TITLE=' ', PXSIZE=PX, PNG=FDIR+Nm+'.png', $
                         CBLBL=unitsFreq[f], /CBLIN, /MODASINH, /CBTICKS, /CBTICKLAB, /CBOUT, $
                         COORD=coord
            
            PY=PX/2
            reso_arcmin=360.*60./PX
            WINDOW=r*2 + 1
            if PX GT winlim THEN WINDOW=-WINDOW
            LS_cartview, map, /NESTED, COLT=41, CTDIR=CTDIR, CTFILE=CTFILE, $
                         MIN=MINVAL_, MAX=MAXVAL_, FLIP=0, $
                         TITLE=' ', PXSIZE=PX, PYSIZE=PY, RESO_ARCMIN=RESO_ARCMIN, $
                         PNG=FDIR+Nc+'.png', nobar=nobar, WINDOW=WINDOW, COORD=coord, $
                         CBLBL=unitsFreq[f], /CBLIN, /MODASINH, /CBTICKS, /CBTICKLAB, /CBOUT 
         ENDFOR
      ENDIF
   ENDELSE
ENDFOR

END
