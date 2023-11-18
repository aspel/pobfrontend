project('POB Frontend', 'cpp', default_options : ['cpp_std=c++17'])

qt5_dep = dependency('qt5', modules : ['Gui','Core','Widgets'])
lua_dep = dependency('luajit')
zlib_dep = dependency('zlib')

# NB on OSX you also need to invoke meson like so, because luajit:
# LDFLAGS="-pagezero_size 10000 -image_base 100000000" meson pobfrontend build
if build_machine.system() == 'darwin'
   gl_dep = dependency('appleframeworks', modules: ['OpenGL'])
   curl_dep = dependency('libcurl')
else
   gl_dep = dependency('gl')
endif


# Import the extension module that knows how
# to invoke Qt tools.
qt5 = import('qt5')
prep = qt5.preprocess(moc_headers : ['subscript.hpp', 'pobwindow.hpp'])

if build_machine.system() == 'darwin'
  executable('PathOfBuilding',
    sources : ['main.cpp', prep],
    dependencies : [qt5_dep, gl_dep, zlib_dep, lua_dep, curl_dep],
    install : true)
else
  executable('PathOfBuilding',
    sources : ['main.cpp', prep],
    dependencies : [qt5_dep, gl_dep, zlib_dep, lua_dep],
    install : true)
endif

exclude_dir = [
  '.github',
  'docs',
  'tests',
]

exclude_file = [
  'runtime-win32.zip',
  '.busted',
  '.gitattributes',
  '.gitignore',
]

if build_machine.system() == 'darwin'
    install_data('pobLogo.icns', install_dir : 'Contents/Resources')
    install_data('Info.plist', install_dir : 'Contents')
    install_data('pobWrapper.sh', install_dir : 'Contents/MacOS')
    install_subdir('PathOfBuilding', install_dir : 'Contents/MacOS', 
      exclude_directories: exclude_dir, 
      exclude_files: exclude_file, 
      strip_directory : true)
    install_subdir('Frameworks', install_dir: 'Contents')
    meson.add_install_script('bash', '-xc', 'cd ${MESON_INSTALL_PREFIX}/Contents && dylibbundler --overwrite-dir --create-dir --bundle-deps --fix-file MacOS/lcurl.so')
else
    install_subdir('PathOfBuilding', install_dir : '',  
      exclude_directories: exclude_dir, 
      exclude_files: exclude_file, 
      strip_directory : true)
endif
