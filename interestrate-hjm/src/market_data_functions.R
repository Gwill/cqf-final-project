parseHistoricalForwardCurve = function(shortend_filename,longend_filename) {
  forward_curve_shortend=read.csv(paste(getwd(),shortend_filename,sep=""), skip=3,header = TRUE,stringsAsFactors = FALSE)
  forward_curve_longend=read.csv(paste(getwd(),longend_filename,sep=""), skip=3,header = TRUE,stringsAsFactors = FALSE)  
  date_format = "%d %b %y"
  
  #count number of observations
  k=0
  for (i in seq(1,nrow(forward_curve_longend))) {
    date = as.Date(forward_curve_longend[i,1],date_format)
    if (!is.na(date)) {
      if (forward_curve_longend[i,2] != "") {
        k = k+1    
      }
    }       
  }
  nbrecords = k
  
  #initialze matrix
  HistoricalForwardCurve = matrix(NA,nrow=nbrecords,ncol=51,byrow = TRUE);
  colnames(HistoricalForwardCurve) = c(0.08, seq(0.5,25,by=0.5))
  DateForwardCurve =  rep(as.Date("01 Jan 70",date_format),nbrecords)
  
  #populate matrix
  #we asumme that short-end file and long-end have same data structure and same dates
  k=1
  for (i in seq(1,nrow(forward_curve_longend))) {
    date = as.Date(forward_curve_longend[i,1],date_format)
    if (!is.na(date)) {
      if (forward_curve_shortend[i,2] != "") {    
        #make sure date are aligned between the shortend file and longend file
        if (forward_curve_shortend[i,1] == forward_curve_longend[i,1]) {
          DateForwardCurve[k] = date
          HistoricalForwardCurve[k,1] = as.numeric(forward_curve_shortend[i,2])
          for (j in seq(2,51)) HistoricalForwardCurve[k,j] = as.numeric(forward_curve_longend[i,j])        
        }
        else {
          cat("Dates are not aligned between shortend file and longend file at record [",i,"]\n")
        }      
        k = k+1   
      }
      else {
        cat("No forward curve data for", format(as.Date(forward_curve_longend[i,1],date_format),date_format),"\n")
      }
    }
  }
  
  cat("UK instantaneous commercial bank liability forward curve loaded between",format(as.Date(min(DateForwardCurve),origin = as.Date("01 Jan 70",date_format)),date_format),"and",format(as.Date(max(DateForwardCurve),origin = as.Date("01 Jan 70",date_format)),date_format),"\n")
  return(list(date=DateForwardCurve,forwardcurve=HistoricalForwardCurve))
}

parseForwardCurve = function(date,shortend_filename,longend_filename) {
  #date = as.Date("2014-05-30","%Y-%m-%d")
  #shortend_filename ="/../data/ukblc05_mdaily_fwdcurve_shortend.csv"
  
  forward_curve_shortend=read.csv(paste(getwd(),shortend_filename,sep=""), skip=3,header = TRUE,stringsAsFactors = FALSE)
  date_format = "%d %b %y"
  forward_curve_shortend[,1] = as.Date(forward_curve_shortend[,1],date_format)
  forward_curve_shortend = forward_curve_shortend[-1,] #suppress first line that does not contain data
  
  #initialze matrix
  ForwardCurve = matrix(NA,nrow=1,ncol=(ncol(forward_curve_shortend)-1),byrow = TRUE);
  colnames(ForwardCurve) = seq(1/12,5,by=1/12)

  #populate matrix
  ForwardCurve[1,] = as.numeric(forward_curve_shortend[forward_curve_shortend[,1] == date,2:ncol(forward_curve_shortend)])  
  
  return(ForwardCurve)
}

