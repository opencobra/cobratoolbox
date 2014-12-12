
%typemap(scoercein) SWIGTYPE, SWIGTYPE *, SWIGTYPE *const, SWIGTYPE &  
 %{ 
 if (is.null($input)) stop("Input null");
 if(isS4($input) && .hasSlot($input, "ref"))
 {
  if (length(grep("0x0>",capture.output(slot($input, "ref")))) > 0 ||
      length(grep("nil",capture.output(slot($input, "ref")))) > 0)
  { 
    stop("Input null");
  }
 }
 if (inherits($input, "ExternalReference")) $input = slot($input,"ref")
 %}


 %typemap(scoerceout) SWIGTYPE 
 %{
   if (length(grep("0x0>",capture.output($result))) > 0 ||
      length(grep("nil",capture.output($result))) > 0)
    {
      return(NULL);
    }

   $result <- new("$&R_class", ref=$result);
 %}
 
 %typemap(scoerceout) SWIGTYPE & 
 %{ 
   if (length(grep("0x0>",capture.output($result))) > 0 ||
      length(grep("nil",capture.output($result))) > 0)
    {
      return(NULL);
    }
    $result <- new("$R_class", ref=$result) ;
 %}
 
 %typemap(scoerceout) SWIGTYPE * 
 %{ 
   if (length(grep("0x0>",capture.output($result))) > 0 ||
      length(grep("nil",capture.output($result))) > 0)
    {
      return(NULL);
    }
    $result <- new("$R_class", ref=$result) ;
 %}
 
 %typemap(scoerceout) SWIGTYPE *const
 %{ 
   if (length(grep("0x0>",capture.output($result))) > 0 ||
      length(grep("nil",capture.output($result))) > 0)
    {
      return(NULL);
    }
    $result <- new("$R_class", ref=$result) ;
 %}
