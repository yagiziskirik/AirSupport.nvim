command! -bar -bang AirSupport call s:AirSupport(<bang>0)

function! s:AirSupport(force_float)
    " bang command
    lua require('telescope').extensions.AirSupport.AirSupport()
endfunction
