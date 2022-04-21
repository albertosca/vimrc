

  
  if &background == 'dark'
    
  let s:shade0 = "#003333"
  let s:shade1 = "#1f4f4d"
  let s:shade2 = "#3d6a67"
  let s:shade3 = "#5c8681"
  let s:shade4 = "#7aa19b"
  let s:shade5 = "#99bdb5"
  let s:shade6 = "#b7d8cf"
  let s:shade7 = "#d6f4e9"
  let s:accent0 = "#ff7f57"
  let s:accent1 = "#47ceb5"
  let s:accent2 = "#ffe266"
  let s:accent3 = "#47ceb5"
  let s:accent4 = "#47ceb5"
  let s:accent5 = "#0fa36b"
  let s:accent6 = "#0fea76"
  let s:accent7 = "#0fea76"
  
  endif
  

  
  if &background == 'light'
    
  let s:shade0 = "#dde7e8"
  let s:shade1 = "#bed5d3"
  let s:shade2 = "#9ec3bf"
  let s:shade3 = "#7fb1aa"
  let s:shade4 = "#609e95"
  let s:shade5 = "#418c80"
  let s:shade6 = "#217a6c"
  let s:shade7 = "#026857"
  let s:accent0 = "#ff7f57"
  let s:accent1 = "#026857"
  let s:accent2 = "#47ceb5"
  let s:accent3 = "#026857"
  let s:accent4 = "#026857"
  let s:accent5 = "#0fa36b"
  let s:accent6 = "#003333"
  let s:accent7 = "#0fa36b"
  
  endif
  

  let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}
  let s:p.normal.left = [ [ s:shade1, s:accent5 ], [ s:shade7, s:shade2 ] ]
  let s:p.normal.right = [ [ s:shade1, s:shade4 ], [ s:shade5, s:shade2 ] ]
  let s:p.inactive.right = [ [ s:shade1, s:shade3 ], [ s:shade3, s:shade1 ] ]
  let s:p.inactive.left =  [ [ s:shade4, s:shade1 ], [ s:shade3, s:shade0 ] ]
  let s:p.insert.left = [ [ s:shade1, s:accent3 ], [ s:shade7, s:shade2 ] ]
  let s:p.replace.left = [ [ s:shade1, s:accent1 ], [ s:shade7, s:shade2 ] ]
  let s:p.visual.left = [ [ s:shade1, s:accent6 ], [ s:shade7, s:shade2 ] ]
  let s:p.normal.middle = [ [ s:shade5, s:shade1 ] ]
  let s:p.inactive.middle = [ [ s:shade4, s:shade1 ] ]
  let s:p.tabline.left = [ [ s:shade6, s:shade2 ] ]
  let s:p.tabline.tabsel = [ [ s:shade6, s:shade0 ] ]
  let s:p.tabline.middle = [ [ s:shade2, s:shade4 ] ]
  let s:p.tabline.right = copy(s:p.normal.right)
  let s:p.normal.error = [ [ s:accent0, s:shade0 ] ]
  let s:p.normal.warning = [ [ s:accent2, s:shade1 ] ]

  let g:lightline#colorscheme#ThemerVimLightline#palette = lightline#colorscheme#fill(s:p)

  