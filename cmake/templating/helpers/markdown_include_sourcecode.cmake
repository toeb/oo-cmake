
    function(markdown_include_sourcecode path)
        fread("${path}")
        ans(res)
        set(res "*${path}*: \n```${ARGN}\n${res}\n```")
        return_ref(res)
    endfunction()
