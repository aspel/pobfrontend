project('POB Frontend', 'cpp', default_options : ['cpp_std=c++17'])

qt5_dep = dependency('qt5', modules : ['Gui','Core','Widgets'])
lua_dep = dependency('luajit')
# NB on OSX you also need to invoke meson like so, because luajit:
# LDFLAGS="-pagezero_size 10000 -image_base 100000000" meson pobfrontend build
if build_machine.system() == 'darwin'
   gl_dep = dependency('appleframeworks', modules: ['OpenGL'])
else
   gl_dep = dependency('gl')
endif
zlib_dep = dependency('zlib')

# Import the extension module that knows how
# to invoke Qt tools.
qt5 = import('qt5')
prep = qt5.preprocess(moc_headers : ['subscript.hpp', 'pobwindow.hpp'])

executable('PathOfBuilding',
  sources : ['main.cpp', prep],
  dependencies : [qt5_dep, gl_dep, zlib_dep, lua_dep],
  install : true)


if build_machine.system() == 'darwin'
    install_data('pobLogo.icns', install_dir : 'Contents/Resources')
    install_data('Info.plist', install_dir : 'Contents')
    install_data('pobWrapper.sh', install_dir : 'Contents/MacOS')
    meson.add_install_script('mesonInstaller.sh')
endif
