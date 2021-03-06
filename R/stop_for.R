.stop_for_upload_size <-
    function(sizes, paths)
{
    toolarge <- sizes > .SW_UPLOAD_MAX_SIZE
    if (any(toolarge)) {
        idx <- head(toolarge)
        stop(sum(toolarge), " file(s) > 5 GB cannot be uploaded (yet):",
             "\n  ", paste(sQuote(paths[idx]), collapse="\n  "))
    }
}

.stop_for_writable <-
    function(container, objects, mode, paths)
{
    exist <- swexists(container, objects)
    if(mode%in%"skip"){
	idx<-which(!exist)
	return(idx)
    }
    if ((!"replace" %in% mode) && any(exist)) {
        idx <- head(which(exist))
        stop(sum(exist), " object(s) already exist and 'mode' is not 'replace'",
             "\n  mode: ", paste(sQuote(mode), collapse=", "),
             "\n  container: ", sQuote(container),
             "\n  paths: ", paste(sQuote(paths[idx]),
                                  collapse=",\n         "),
             "\n  object(s): ", paste(sQuote(objects)[idx], collapse=", "),
             call.=FALSE)
    }
}
