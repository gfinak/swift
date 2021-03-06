.swupload_file <-
    function(curl, hdr, container, object, path, verbose)
{
    if (verbose) {
        msg <- sprintf("uploading %s to %s", sQuote(basename(path)),
                        sQuote(object))
        message(msg)
    }
    url <- .RESTurl(hdr[["X-Storage-Url"]], container, object)
    .RESTupload(curl, hdr, url, path)
    object
}

swupload <-
    function(container, path=".", ..., prefix, mode=c("create", "replace", "skip"),
             verbose=TRUE)
{
    stopifnot(.isString(container))
    stopifnot(.isString(path))
    if (!file.exists(path))
        stop("'source' does not exist:\n  ", sQuote(source))
    stopifnot(missing(prefix) || .isString(prefix))
    mode <- match.arg(mode)
    stopifnot(.isLogical(verbose))

    isdir <- file.info(path)$isdir
    istrailing <- substring(path, nchar(path)) == "/"
    path <- normalizePath(path)
    root <- if (!isdir || !istrailing) dirname(path) else path
    if (isdir) {
        paths <- dir(path, ..., full.names=TRUE)
        paths <- paths[file.info(paths)$isdir != TRUE]
    } else {
        paths <- path
    }
    if (missing(prefix)) {
        prefix <- ""
        pattern <- sprintf("^%s/", root)
    } else {
        pattern <- sprintf("^%s", root)
    }
    objects <- sub(pattern, prefix, paths)

    .stop_for_upload_size(file.info(paths)$size, paths)
    idx<-.stop_for_writable(container, objects, mode, paths)
    if(mode%in%"skip"){
      if(length(idx)!=0)
	      objects<-objects[idx]
      else {
        message("All objects already uploaded")
        return(invisible())
      }
    }
    
    curl <- RCurl::getCurlHandle()
    hdr <- .swauth(curl)

    for (i in seq_along(paths))
        .swupload_file(curl, hdr, container, objects[[i]], paths[[i]], verbose)
    setNames(objects, paths)
}
