#######################################################################
## CMake Macros for an embeddable project
##
## Author: Denis Arnaud
## Date: July 2011
#######################################################################


###################################################################
##                     Project Configuration                     ##
###################################################################
##
# Set the project names
macro (set_project_names _project_name_param)
  # Set the pretty name
  string (TOUPPER ${_project_name_param} _pretty_name_tmp)
  if (${ARGC} GREATER 1)
	set (_pretty_name_tmp ${ARGV1})
  endif (${ARGC} GREATER 1)
  set (PACKAGE_PRETTY_NAME "${_pretty_name_tmp}" CACHE INTERNAL "Description")

  # Set the lowercase project name
  string (TOLOWER "${_project_name_param}" _package_tmp)
  set (PACKAGE "${_package_tmp}" CACHE INTERNAL "Description")

  # Set the uppercase project name
  string (TOUPPER "${_project_name_param}" _package_name_tmp)
  set (PACKAGE_NAME "${_package_name_tmp}" CACHE INTERNAL "Description")

  # Set the project name
  project (${PACKAGE})
endmacro (set_project_names)

##
# Set the project versions
macro (set_project_versions _major _minor _patch)
  set (_full_version ${_major}.${_minor}.${_patch})
  #
  set (${PROJECT_NAME}_VERSION_MAJOR ${_major})
  set (${PROJECT_NAME}_VERSION_MINOR ${_minor})
  set (${PROJECT_NAME}_VERSION_PATCH ${_patch})
  set (${PROJECT_NAME}_VERSION ${_full_version})
  #
  set (PACKAGE_VERSION ${_full_version})
  # Note that the soname can be different from the version. The soname
  # should change only when the ABI compatibility is no longer guaranteed.
  set (GENERIC_LIB_VERSION ${_full_version})
  set (GENERIC_LIB_SOVERSION ${_major}.${_minor})
endmacro (set_project_versions)

##
# Set a few options:
#  * BUILD_SHARED_LIBS   - Whether or not to build shared libraries
#  * CMAKE_BUILD_TYPE    - Debug or release
#  * CMAKE_INSTALL_PREFIX
#  * INSTALL_DOC         - Whether or not to build and install the documentation
#  * INSTALL_LIB_DIR     - Installation directory for the libraries
#  * INSTALL_BIN_DIR     - Installation directory for the binaries
#  * INSTALL_INCLUDE_DIR - Installation directory for the header files
#  * INSTALL_DATA_DIR    - Installation directory for the data files
#  * INSTALL_SAMPLE_DIR  - Installation directory for the (CSV) sample files
#
macro (set_project_options _build_doc)
  # Shared libraries
  option (BUILD_SHARED_LIBS "Set to OFF to build static libraries" ON)

  # Set default cmake build type to Debug (None Debug Release RelWithDebInfo
  # MinSizeRel)
  if (NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE "Debug")
  endif()

  # Set default install prefix to project root directory
  if (CMAKE_INSTALL_PREFIX STREQUAL "/usr/local")
    set (CMAKE_INSTALL_PREFIX "/usr")
  endif()

  # Documentation
  option (INSTALL_DOC "Set to OFF to skip build/install Documentation" 
    ${_build_doc})

  # Set the library installation directory (either 32 or 64 bits)
  set (LIBDIR "lib${LIB_SUFFIX}" CACHE PATH
    "Library directory name, either lib or lib64")

  # Offer the user the choice of overriding the installation directories
  set (INSTALL_LIB_DIR ${LIBDIR} CACHE PATH
    "Installation directory for libraries")
  set (INSTALL_BIN_DIR bin CACHE PATH "Installation directory for executables")
  set (INSTALL_INCLUDE_DIR include CACHE PATH
    "Installation directory for header files")
  set (INSTALL_DATA_DIR share CACHE PATH
    "Installation directory for data files")
  set (INSTALL_SAMPLE_DIR share/${PROJECT_NAME}/samples CACHE PATH
    "Installation directory for (CSV) sample files")

  # Make relative paths absolute (needed later on)
  foreach (_path_type LIB BIN INCLUDE DATA SAMPLE)
    set (var INSTALL_${_path_type}_DIR)
    if (NOT IS_ABSOLUTE "${${var}}")
      set (${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
    endif ()
  endforeach (_path_type)

  ##
  # Basic documentation (i.e., AUTHORS, NEWS, README, INSTALL)
  set (BASICDOC_FILES AUTHORS NEWS README INSTALL)
  set (BASICDOC_PATH "share/doc/${PACKAGE}-${PACKAGE_VERSION}")

endmacro (set_project_options)

#
macro (install_basic_documentation)
  install (FILES ${BASICDOC_FILES} DESTINATION ${BASICDOC_PATH})
endmacro (install_basic_documentation)


#
macro (store_in_cache)
  # Force some variables that could be defined in the command line to be
  # written to cache
  set (BUILD_SHARED_LIBS "${BUILD_SHARED_LIBS}" CACHE BOOL
	"Set to OFF to build static libraries" FORCE)
  set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH
	"Where to install ${PROJECT_NAME}" FORCE)
  set (CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING
	"Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
  set (CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" CACHE PATH
	"Path to custom CMake Modules" FORCE)
  set (INSTALL_DOC "${INSTALL_DOC}" CACHE BOOL
	"Set to OFF to skip build/install Documentation" FORCE)
endmacro (store_in_cache)


#####################################
##            Packaging            ##
#####################################
#
macro (packaging_init _project_name)
  include (InstallRequiredSystemLibraries)

  set (CPACK_PACKAGE_NAME "${_project_name}")
endmacro (packaging_init)

#
macro (packaging_set_description _project_description)
  set (CPACK_PACKAGE_DESCRIPTION "${_project_description}")
endmacro (packaging_set_description)

#
macro (packaging_set_summary _project_summary)
  set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "${_project_summary}")
endmacro (packaging_set_summary)

#
macro (packaging_set_contact _project_contact)
  set (CPACK_PACKAGE_CONTACT "${_project_contact}")
endmacro (packaging_set_contact)

#
macro (packaging_set_vendor _project_vendor)
  set (CPACK_PACKAGE_VENDOR "${_project_vendor}")
endmacro (packaging_set_vendor)

# Both parameters are semi-colon sepetated lists of the types of
# packages to generate, e.g., "TGZ;TBZ2"
macro (packaging_set_other_options _package_type_list _source_package_type_list)
  #
  set (CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
  set (CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
  #set (CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
  set (CPACK_PACKAGE_VERSION_PATCH ${GIT_REVISION})
  set (CPACK_PACKAGE_VERSION ${${PROJECT_NAME}_VERSION})

  # Basic documentation
  if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/README)
    message (FATAL_ERROR "A README file must be defined and located at the root directory")
  endif (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/README)
  set (CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/README)
  set (CPACK_RESOURCE_FILE_README ${CMAKE_CURRENT_SOURCE_DIR}/README)

  # Licence
  if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/COPYING)
    message (FATAL_ERROR "A licence file, namely COPYING, must be defined and located at the root directory")
  endif (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/COPYING)
  set (CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/COPYING)

  ##
  # Reset the generators for the binary packages
  # Available types of package: DEB, RPM, STGZ, TZ, TGZ, TBZ2
  set (CPACK_GENERATOR "${_package_type_list}")
  #set (CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.3.6), libgcc1 (>= 1:4.1)")

  ##
  # Source packages
  # Available types of package: TZ, TGZ, TBZ2
  set (CPACK_SOURCE_GENERATOR "${_source_package_type_list}")

  set (CPACK_SOURCE_PACKAGE_FILE_NAME 
    "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}"
    CACHE INTERNAL "tarball basename")
  set (AUTOTOOLS_IGNRD "/tmp/;/tmp2/;/autom4te\\\\.cache/;autogen\\\\.sh$")
  set (PACK_IGNRD "${CPACK_PACKAGE_NAME}\\\\.spec;/build/;\\\\.gz$;\\\\.bz2$")
  set (EDIT_IGNRD "\\\\.swp$;\\\\.#;/#;~$")
  set (SCM_IGNRD 
    "/CVS/;/\\\\.svn/;/\\\\.bzr/;/\\\\.hg/;/\\\\.git/;\\\\.gitignore$")
  set (CPACK_SOURCE_IGNORE_FILES
    "${AUTOTOOLS_IGNRD};${SCM_IGNRD};${EDIT_IGNRD};${PACK_IGNRD}"
    CACHE STRING "CPACK will ignore these files")
  #set (CPACK_SOURCE_IGNORE_DIRECTORY ${CPACK_SOURCE_IGNORE_FILES} .git)

  # Initialise the source package generator with the variables above
  include (CPack)

  # Add a 'dist' target, similar to what is given by GNU Autotools
  add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

  ##
  # Reset the generator types for the binary packages. Indeed, the variable
  # has been reset by "include (Cpack)".
  set (CPACK_GENERATOR "${_package_type_list}")

endmacro (packaging_set_other_options)


###################################################################
##                         Dependencies                          ##
###################################################################
# ~~~~~~~~ Wrapper ~~~~~~~~
macro (get_external_libs)
  # CMake scripts, to find some dependencies (e.g., Boost, MySQL, SOCI)
  set (CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/config/)

  #
  set (PROJ_DEP_LIBS_FOR_LIB "")
  set (PROJ_DEP_LIBS_FOR_BIN "")
  set (PROJ_DEP_LIBS_FOR_TST "")
  foreach (_arg ${ARGV})
    string (TOLOWER ${_arg} _arg_lower_full)

    # Extract the name of the external dependency
    string (REGEX MATCH "^[a-z]+" _arg_lower ${_arg_lower_full})

    # Extract the required version of the external dependency
    string (REGEX MATCH "[0-9._-]+$" _arg_version ${_arg_lower_full})

    if (${_arg_lower} STREQUAL "git")
      get_git (${_arg_version})
    endif (${_arg_lower} STREQUAL "git")

    if (${_arg_lower} STREQUAL "boost")
      get_boost (${_arg_version})
    endif (${_arg_lower} STREQUAL "boost")

    if (${_arg_lower} STREQUAL "readline")
      get_readline (${_arg_version})
    endif (${_arg_lower} STREQUAL "readline")

    if (${_arg_lower} STREQUAL "mysql")
      get_mysql (${_arg_version})
    endif (${_arg_lower} STREQUAL "mysql")

    if (${_arg_lower} STREQUAL "soci")
      get_soci (${_arg_version})
    endif (${_arg_lower} STREQUAL "soci")

    if (${_arg_lower} STREQUAL "stdair")
      get_stdair (${_arg_version})
    endif (${_arg_lower} STREQUAL "stdair")

    if (${_arg_lower} STREQUAL "doxygen")
      get_doxygen (${_arg_version})
    endif (${_arg_lower} STREQUAL "doxygen")

  endforeach (_arg)
endmacro (get_external_libs)

# ~~~~~~~~~~ Git ~~~~~~~~~~
macro (get_git)
  message (STATUS "Requires Git without specifying any version")

  find_package (Git)
  if (Git_FOUND)
    Git_WC_INFO (${CMAKE_CURRENT_SOURCE_DIR} PROJ)
    set (GIT_REVISION ${PROJ_WC_REVISION_HASH})
    message (STATUS "Current Git revision name: ${PROJ_WC_REVISION_NAME}")
  endif (Git_FOUND)
endmacro (get_git)

# ~~~~~~~~~~ BOOST ~~~~~~~~~~
macro (get_boost)
  set (_required_version 0)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires Boost-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires Boost without specifying any version")
  endif (${ARGC} GREATER 0)

  #
  # Note: ${Boost_DATE_TIME_LIBRARY} and ${Boost_PROGRAM_OPTIONS_LIBRARY}
  # are already set by ${SOCIMYSQL_LIBRARIES} and/or ${SOCI_LIBRARIES}.
  #
  set (Boost_USE_STATIC_LIBS OFF)
  set (Boost_USE_MULTITHREADED ON)
  set (Boost_USE_STATIC_RUNTIME OFF)
  set (BOOST_REQUIRED_COMPONENTS
    program_options date_time iostreams serialization filesystem 
    unit_test_framework)
  find_package (Boost ${_required_version} REQUIRED
    COMPONENTS ${BOOST_REQUIRED_COMPONENTS})

  if (Boost_FOUND)
    # 
    set (Boost_HUMAN_VERSION
      ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION})
    message (STATUS "Found Boost version: ${Boost_HUMAN_VERSION}")

    # Update the list of include directories for the project
    include_directories (${Boost_INCLUDE_DIRS})

    # Update the list of dependencies for the project
    set (PROJ_DEP_LIBS_FOR_LIB ${PROJ_DEP_LIBS_FOR_LIB}
      ${Boost_IOSTREAMS_LIBRARY} ${Boost_SERIALIZATION_LIBRARY}
      ${Boost_FILESYSTEM_LIBRARY} ${Boost_DATE_TIME_LIBRARY})
    set (PROJ_DEP_LIBS_FOR_BIN ${PROJ_DEP_LIBS_FOR_BIN}
      ${Boost_PROGRAM_OPTIONS_LIBRARY})
    set (PROJ_DEP_LIBS_FOR_TST ${PROJ_DEP_LIBS_FOR_TST}
      ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})

    # For display purposes
    set (BOOST_REQUIRED_LIBS
      ${Boost_IOSTREAMS_LIBRARY} ${Boost_SERIALIZATION_LIBRARY}
      ${Boost_FILESYSTEM_LIBRARY} ${Boost_DATE_TIME_LIBRARY}
      ${Boost_PROGRAM_OPTIONS_LIBRARY} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})

  endif (Boost_FOUND)

endmacro (get_boost)

# ~~~~~~~~~~ Readline ~~~~~~~~~
macro (get_readline)
  set (_required_version 0)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires Readline-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires Readline without specifying any version")
  endif (${ARGC} GREATER 0)

  set (READLINE_FOUND False)

  find_package (Readline)
  if (READLINE_LIBRARY)
    set (READLINE_FOUND True)
  endif (READLINE_LIBRARY)

  if (READLINE_FOUND)
    # Update the list of include directories for the project
    include_directories (${READLINE_INCLUDE_DIR})

    # Update the list of dependencies for the project
    set (PROJ_DEP_LIBS_FOR_LIB ${PROJ_DEP_LIBS_FOR_LIB} ${READLINE_LIBRARY})
  endif (READLINE_FOUND)

endmacro (get_readline)

# ~~~~~~~~~~ MySQL ~~~~~~~~~
macro (get_mysql)
  set (_required_version 0)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires MySQL-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires MySQL without specifying any version")
  endif (${ARGC} GREATER 0)

  find_package (MySQL)
  if (MYSQL_FOUND)

    # Update the list of include directories for the project
    include_directories (${MYSQL_INCLUDE_DIR})

    # Update the list of dependencies for the project
    set (PROJ_DEP_LIBS_FOR_LIB ${PROJ_DEP_LIBS_FOR_LIB} ${MYSQL_LIBRARIES})
  endif (MYSQL_FOUND)

endmacro (get_mysql)

# ~~~~~~~~~~ SOCI ~~~~~~~~~~
macro (get_soci)
  set (_required_version 0)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires SOCI-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires SOCI without specifying any version")
  endif (${ARGC} GREATER 0)

  find_package (SOCI)
  if (SOCI_FOUND)
    #
    message (STATUS "Found SOCI version: ${SOCI_VERSION}")

    # Update the list of include directories for the project
    include_directories (${SOCI_INCLUDE_DIR})

    # Update the list of dependencies for the project
    set (PROJ_DEP_LIBS_FOR_LIB ${PROJ_DEP_LIBS_FOR_LIB} ${SOCI_LIBRARIES})
  endif (SOCI_FOUND)

  find_package (SOCIMySQL)
  if (SOCIMYSQL_FOUND)
    #
    message (STATUS "Found MySQL back-end support for SOCI")

    # Update the list of include directories for the project
    include_directories (${SOCIMYSQL_INCLUDE_DIR})

    # Update the list of dependencies for the project
    set (PROJ_DEP_LIBS_FOR_LIB ${PROJ_DEP_LIBS_FOR_LIB} ${SOCIMYSQL_LIBRARIES})
  endif (SOCIMYSQL_FOUND)

endmacro (get_soci)

# ~~~~~~~~~~ Doxygen ~~~~~~~~~
macro (get_doxygen)
  set (_required_version 0)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires Doxygen-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires Doxygen without specifying any version")
  endif (${ARGC} GREATER 0)

  find_package (Doxygen REQUIRED)
endmacro (get_doxygen)

# ~~~~~~~~~~ StdAir ~~~~~~~~~
macro (get_stdair)
  set (_required_version 0)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires StdAir-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires StdAir without specifying any version")
  endif (${ARGC} GREATER 0)

  find_package (StdAir REQUIRED HINTS ${WITH_STDAIR_PREFIX})
  if (StdAir_FOUND)
    #
    message (STATUS "Found StdAir version: ${STDAIR_VERSION}")

    # Update the list of include directories for the project
    include_directories (${STDAIR_INCLUDE_DIRS})

    # Update the list of dependencies for the project
    set (PROJ_DEP_LIBS_FOR_LIB ${PROJ_DEP_LIBS_FOR_LIB} ${STDAIR_LIBRARIES})

  else (StdAir_FOUND)
    set (ERROR_MSG "The StdAir library cannot be found. If it is installed in")
    set (ERROR_MSG "${ERROR_MSG} a in a non standard directory, just invoke")
    set (ERROR_MSG "${ERROR_MSG} 'cmake' specifying the -DWITH_STDAIR_PREFIX=")
    set (ERROR_MSG "${ERROR_MSG}<StdAir install path> variable.")
    message (FATAL_ERROR "${ERROR_MSG}")
  endif (StdAir_FOUND)

endmacro (get_stdair)


##############################################
##           Build, Install, Export         ##
##############################################
macro (init_build)
  ##
  # Compilation
  # Note: the debug flag (-g) is set (or not) by giving the
  # corresponding option when calling cmake:
  # cmake -DCMAKE_BUILD_TYPE:STRING={Debug,Release,MinSizeRel,RelWithDebInfo}
  #set (CMAKE_CXX_FLAGS "-Wall -Wextra -pedantic -Werror")
  set (CMAKE_CXX_FLAGS "-Wall -Werror")
  include_directories (BEFORE ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
  
  ##
  # Set all the directory installation paths for the project (e.g., prefix,
  # libdir, bindir).
  # Note that those paths need to be set before the sub-directories are browsed
  # for the building process (see below), because that latter needs those paths
  # to be correctly set.
  set_install_directories ()

  ##
  # Initialise the list of modules to build and those to test
  set (PROJ_ALL_MOD_FOR_BLD "")
  set (PROJ_ALL_MOD_FOR_TST "")

  ##
  # Initialise the list of targets to build: libraries, binaries and tests
  set (PROJ_ALL_LIB_TARGETS "")
  set (PROJ_ALL_BIN_TARGETS "")
  set (PROJ_ALL_TST_TARGETS "")

endmacro (init_build)

# Define the substitutes for the variables present in the development
# support files.
# Note that STDAIR_SAMPLE_DIR is either defined because the current project
# is StdAir, or because the current project has a dependency on StdAir, 
# in which case STDAIR_SAMPLE_DIR is an imported variable.
macro (set_install_directories)
  set (prefix        ${CMAKE_INSTALL_PREFIX})
  set (exec_prefix   ${prefix})
  set (bindir        ${exec_prefix}/bin)
  set (libdir        ${exec_prefix}/${LIBDIR})
  set (libexecdir    ${exec_prefix}/libexec)
  set (sbindir       ${exec_prefix}/sbin)
  set (sysconfdir    ${prefix}/etc)
  set (includedir    ${prefix}/include)
  set (datarootdir   ${prefix}/share)
  set (datadir       ${datarootdir})
  set (pkgdatadir    ${datarootdir}/${PACKAGE})
  set (sampledir     ${STDAIR_SAMPLE_DIR})
  set (docdir        ${datarootdir}/doc/${PACKAGE}-${PACKAGE_VERSION})
  set (htmldir       ${docdir})
  set (mandir        ${datarootdir}/man)
  set (infodir       ${datarootdir}/info)
  set (pkgincludedir ${includedir}/stdair)
  set (pkglibdir     ${libdir}/stdair)
  set (pkglibexecdir ${libexecdir}/stdair)
endmacro (set_install_directories)


####
## Module support
####

##
# Set the name of the module
macro (module_set_name _module_name)
  set (MODULE_NAME ${_module_name})
  set (MODULE_LIB_TARGET ${MODULE_NAME}lib)
endmacro (module_set_name)

##
# For each sub-module:
#  * The libraries and binaries are built (with the regular
#    'make' command) and installed (with the 'make install' command).
#    The header files are installed as well.
#  * The corresponding targets (libraries and binaries) are exported within
#    a CMake import helper file, namely '${PROJECT_NAME}-library-depends.cmake'.
#    That CMake import helper file is installed in the installation directory,
#    within the <install_dir>/share/${PROJECT_NAME}/CMake sub-directory.
#    That CMake import helper file is used by the ${PROJECT_NAME}-config.cmake
#    file, to be installed in the same sub-directory. The
#    ${PROJECT_NAME}-config.cmake file is specified a little bit below.
macro (add_modules)
  set (_embedded_components ${ARGV})
  set (LIB_DEPENDENCY_EXPORT ${PROJECT_NAME}-library-depends)
  set (LIB_DEPENDENCY_EXPORT_PATH "${INSTALL_DATA_DIR}/${PROJECT_NAME}/CMake")
  #
  foreach (_embedded_comp ${_embedded_components})
    #
    add_subdirectory (${_embedded_comp})
  endforeach (_embedded_comp)

  # Register, for book-keeping purpose, the list of modules at the project level
  set (PROJ_ALL_MOD_FOR_BLD ${_embedded_components})

endmacro (add_modules)

##
# Convert the configuration headers (basically, just replace the @<variable>@
# variables).
macro (module_generate_config_helpers)

  # Generic module configuration header
  if (EXISTS config.h.in)
    configure_file (config.h.in config.h @ONLY)
  endif (EXISTS config.h.in)

  # Specific module configuration header
  set (PROJ_PATH_CFG_SRC 
    ${CMAKE_CURRENT_SOURCE_DIR}/config/${MODULE_NAME}-paths.hpp.in)
  set (PROJ_PATH_CFG_DIR ${CMAKE_CURRENT_BINARY_DIR}/config)
  if (EXISTS ${PROJ_PATH_CFG_SRC})
    set (PROJ_PATH_CFG ${PROJ_PATH_CFG_DIR}/${MODULE_NAME}-paths.hpp)
    configure_file (${PROJ_PATH_CFG_SRC} ${PROJ_PATH_CFG} @ONLY)
  
    # Add the 'hdr_cfg_${MODULE_NAME}' target, depending on the converted header
    add_custom_target (hdr_cfg_${MODULE_NAME} ALL DEPENDS ${PROJ_PATH_CFG})

  else (EXISTS ${PROJ_PATH_CFG_SRC})
    message (FATAL_ERROR "The ${PROJ_PATH_CFG_SRC} file is missing.")
  endif (EXISTS ${PROJ_PATH_CFG_SRC})

endmacro (module_generate_config_helpers)

##
# Building and installation of the "standard library".
# All the sources within each of the layers/sub-directories are used and
# assembled, in order to form a single library, named here the
# "standard library".
# The three parameters (among which only the first one is mandatory) are:
#  * A semi-colon separated list of all the layers in which header and source
#    files are to be found.
#  * Whether or not all the header files should be published. By default, only
#    the header files of the root directory are to be published.
#  * A list of additional dependency on inter-module library targets.
macro (module_library_add_standard _layer_list)
  # First, generate the configuration helper header files
  module_generate_config_helpers ()

  # ${ARGV} contains a single semi-colon (';') separated list, which
  # is the aggregation of all the elements of all the list parameters.
  # The list of intermodule dependencies must therefore be calculated.
  set (_intermodule_dependencies ${ARGV})

  # Extract the information whether or not all the header files need
  # to be published. Not that that parameter is optional. Its existence
  # has therefore to be checked.
  set (_publish_all_headers_flag False)
  if (${ARGC} GREATER 1)
    string (TOLOWER ${ARGV1} _flag_lower)
    if ("${_flag_lower}" STREQUAL "all")
      set (_publish_all_headers_flag True)
      list (REMOVE_ITEM _intermodule_dependencies ${ARGV1})
    endif ("${_flag_lower}" STREQUAL "all")
  endif (${ARGC} GREATER 1)

  # Initialise the list of header files with the configuration helper header.
  set (${MODULE_LIB_TARGET}_HEADERS ${PROJ_PATH_CFG})

  # Collect the header and source files for all the layers, as specified 
  # as input paramters of this macro
  set (_all_layers ${_layer_list})
  foreach (_layer ${_all_layers})
    # Remove the layer from the list of intermodule dependencies, so that that
    # latter contains only intermodule dependencies at the end. Note that that
    # latter list may be empty at the end (which then means that there is no
    # dependency among modules).
    list (REMOVE_ITEM _intermodule_dependencies ${_layer})

    # Derive the name of the layer. By default, the layer name corresponds
    # to the layer sub-directory. For the root layer (current source directory),
    # though, the layer name is 'root', rather than '.'
    set (_layer_name ${_layer})
    if ("${_layer_name}" STREQUAL ".")
      set (_layer_name root)
    endif ("${_layer_name}" STREQUAL ".")

    # Derive the name of the layer directory. By default, the layer directory
    # name corresponds to the layer sub-directory. For the root layer (current
    # source directory), though, the layer directory name is empty (""),
    # rather than './'
    set (_layer_dir_name "${_layer}/")
    if ("${_layer_dir_name}" STREQUAL "./")
      set (_layer_dir_name "")
    endif ("${_layer_dir_name}" STREQUAL "./")

    file (GLOB ${MODULE_LIB_TARGET}_${_layer_name}_HEADERS 
      RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${_layer_dir_name}*.hpp)
    list (APPEND ${MODULE_LIB_TARGET}_HEADERS
      ${${MODULE_LIB_TARGET}_${_layer_name}_HEADERS})

    file (GLOB ${MODULE_LIB_TARGET}_${_layer_name}_SOURCES 
      RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${_layer_dir_name}*.cpp)
    list (APPEND ${MODULE_LIB_TARGET}_SOURCES 
      ${${MODULE_LIB_TARGET}_${_layer_name}_SOURCES})
  endforeach (_layer)

  # Register, for book-keeping purpose, the list of layers at the module level
  set (${MODULE_NAME}_ALL_LAYERS ${_all_layers} PARENT_SCOPE)
  set (${MODULE_NAME}_ALL_LAYERS ${_all_layers})

  # Gather both the header and source files into a single list
  set (${MODULE_LIB_TARGET}_SOURCES
    ${${MODULE_LIB_TARGET}_HEADERS} ${${MODULE_LIB_TARGET}_SOURCES})

  ##
  # Building of the library.
  # Delegate the (CMake) target registration to a dedicated macro (below)
  module_library_add_specific (${MODULE_NAME} "."
    "${${MODULE_LIB_TARGET}_root_HEADERS}" "${${MODULE_LIB_TARGET}_SOURCES}" 
    ${_intermodule_dependencies})

  # Installation of all the remaining header files for the module, i.e.,
  # the header files located in all the layers except the root.
  module_header_install_everything_else ()

  # Convenient message to the user/developer
  if (NOT "${INSTALL_LIB_DIR}" MATCHES "^/usr/${LIBDIR}$")
    install (CODE "message (\"On Unix-based platforms, run export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${INSTALL_LIB_DIR} once per session\")")
  endif ()

endmacro (module_library_add_standard)

##
# Building and installation of a specific library.
# The first four parameters are mandatory and correspond to:
#  * The short name of the library to be built.
#    Note that the library (CMake) target is derived directly from the library
#    short name: a 'lib' suffix is just appended to the short name.
#  * The directory where to find the header files.
#  * The header files to be published/installed along with the library.
#  * The source files to build the library.
#    Note that the source files contain at least the header files. Hence,
#    even when there are no .cpp source files, the .hpp files will appear.
#
# Note that the header and source files should be given as single parameters,
# i.e., enclosed by double quotes (").
#
# The additional parameters, if given, correspond to the names of the
# modules this current module depends upon. Dependencies on the
# external libraries (e.g., Boost, SOCI, StdAir) are automatically
# appended, thanks to the get_external_libs() macro.
macro (module_library_add_specific
	_lib_short_name _lib_dir _lib_headers _lib_sources)
  # Derive the library (CMake) target from its name
  set (_lib_target ${_lib_short_name}lib)

  # Register the (CMake) target for the library
  add_library (${_lib_target} SHARED ${_lib_sources})

  # For each module, given as parameter of that macro, add the corresponding
  # library target to a dedicated list
  set (_intermodule_dependencies "")
  foreach (_arg_module ${ARGV})

    if (NOT "${_lib_dir};${_lib_short_name};${_lib_headers};${_lib_sources}" 
	MATCHES "${_arg_module}")
      list (APPEND _intermodule_dependencies ${_arg_module}lib)
    endif ()
  endforeach (_arg_module)

  # Add the dependencies:
  #  * on external libraries (Boost, MySQL, SOCI, StdAir), as calculated by 
  #    the get_external_libs() macro above;
  #  * on the other module libraries, as provided as paramaters to this macro
  target_link_libraries (${_lib_target} 
    ${PROJ_DEP_LIBS_FOR_LIB} ${_intermodule_dependencies})

  # Register the library target in the project (for reporting purpose).
  # Note, the list() commands creates a new variable value in the current scope:
  # the set() must therefore be used to propagate the value upwards. And for
  # those wondering whether we could do that operation with a single set()
  # command, I have already tried... unsucessfully(!)
  list (APPEND PROJ_ALL_LIB_TARGETS ${_lib_target})
  set (PROJ_ALL_LIB_TARGETS ${PROJ_ALL_LIB_TARGETS} PARENT_SCOPE)

  # Register the intermodule dependency targets in the project (for
  # reporting purpose).
  set (${MODULE_NAME}_INTER_TARGETS ${_intermodule_dependencies})
  set (${MODULE_NAME}_INTER_TARGETS ${_intermodule_dependencies} PARENT_SCOPE)

  # For the "standard library", an extra dependency must be added:
  #  * generated configuration header
  if (${_lib_short_name} STREQUAL ${MODULE_NAME})
    ##
    # Add the dependency on the generated configuration headers, 
    # as generated by the module_generate_config_helpers() macro
    add_dependencies (${_lib_target} hdr_cfg_${MODULE_NAME})
  endif (${_lib_short_name} STREQUAL ${MODULE_NAME})

  # DEBUG
  #message ("DEBUG -- [${_lib_target}] _lib_headers = ${_lib_headers}")

  ##
  # Library name (and soname)
  if (WIN32)
    set_target_properties (${_lib_target} PROPERTIES 
      OUTPUT_NAME ${_lib_short_name} 
      VERSION ${GENERIC_LIB_VERSION})
  else (WIN32)
    set_target_properties (${_lib_target} PROPERTIES 
      OUTPUT_NAME ${_lib_short_name}
      VERSION ${GENERIC_LIB_VERSION} SOVERSION ${GENERIC_LIB_SOVERSION})
  endif (WIN32)

  # If everything else is not enough for CMake to derive the language to
  # be used by the linker, it must be told to fall-back on C++
  get_target_property (_linker_lang ${_lib_target} LINKER_LANGUAGE)
  if ("${_linker_lang}" STREQUAL "_linker_lang-NOTFOUND")
    set_target_properties (${_lib_target} PROPERTIES LINKER_LANGUAGE CXX)
    message(STATUS "Had to set the linker language for '${_lib_target}' to CXX")
  endif ("${_linker_lang}" STREQUAL "_linker_lang-NOTFOUND")

  ##
  # Installation of the library
  install (TARGETS ${_lib_target}
    EXPORT ${LIB_DEPENDENCY_EXPORT}
    LIBRARY DESTINATION "${INSTALL_LIB_DIR}" COMPONENT runtime)

  # Register, for reporting purpose, the list of libraries to be built
  # and installed for that module
  list (APPEND ${MODULE_NAME}_ALL_LIBS ${_lib_target})
  set (${MODULE_NAME}_ALL_LIBS ${${MODULE_NAME}_ALL_LIBS} PARENT_SCOPE)

  # Install the header files for the library
  module_header_install_specific (${_lib_dir} "${_lib_headers}")

endmacro (module_library_add_specific)

##
# Installation of specific header files
macro (module_header_install_specific _lib_dir _lib_headers)
  #
  set (_relative_destination_lib_dir "/${_lib_dir}")
  if ("${_relative_destination_lib_dir}" STREQUAL "/.")
    set (_relative_destination_lib_dir "")
  endif ("${_relative_destination_lib_dir}" STREQUAL "/.")

  # Install header files
  install (FILES ${_lib_headers}
    DESTINATION 
    "${INSTALL_INCLUDE_DIR}/${MODULE_NAME}${_relative_destination_lib_dir}"
    COMPONENT devel)

  # DEBUG
  #message ("DEBUG -- [${_lib_dir}] _lib_headers = ${_lib_headers}")

endmacro (module_header_install_specific)

##
# Installation of all the remaining header files for the module, i.e.,
# the header files located in all the layers except the root.
macro (module_header_install_everything_else)
  # Add the layer for the generated headers to the list of source layers
  set (_all_layers ${${MODULE_NAME}_ALL_LAYERS} ${PROJ_PATH_CFG_DIR})

  # The header files of the root layer have already been addressed by the
  # module_library_add_standard() macro (which calls, in turn,
  # module_library_add_specific(), which calls, in turn, 
  # module_header_install_specific() on the root header files)

  # It remains to install the header files for all the other layers
  foreach (_layer ${_all_layers})
    # Install header files
    install (FILES ${${MODULE_LIB_TARGET}_${_layer}_HEADERS}
      DESTINATION "${INSTALL_INCLUDE_DIR}/${MODULE_NAME}/${_layer}"
      COMPONENT devel)
  endforeach (_layer ${${MODULE_NAME}_ALL_LAYERS})

endmacro (module_header_install_everything_else)

##
# Building and installation of the executables/binaries.
# The two parameters (among which only the first one is mandatory) are:
#  * The path/directory where the header and source files can be found
#    in order to build the executable.
#  * If specified, the name to be given to the executable. If no such name
#    is given as parameter, the executable is given the name of the current
#    module.
macro (module_binary_add _exec_source_dir)
  # First, derive the name to be given to the executable, defaulting
  # to the name of the module
  set (_exec_name ${MODULE_NAME})
  if (${ARGC} GREATER 1})
    set (_exec_name ${ARGV1})
  endif (${ARGC} GREATER 1})

  # Register the (CMake) target for the executable, and specify the name
  # of that latter
  add_executable (${_exec_name}bin ${_exec_source_dir}/${_exec_name}.cpp)
  set_target_properties (${_exec_name}bin PROPERTIES OUTPUT_NAME ${_exec_name})

  # Register the dependencies on which the binary depends upon
  target_link_libraries (${_exec_name}bin
    ${PROJ_DEP_LIBS_FOR_BIN} ${MODULE_LIB_TARGET} 
    ${${MODULE_NAME}_INTER_TARGETS})

  # Binary installation
  install (TARGETS ${_exec_name}bin
    EXPORT ${LIB_DEPENDENCY_EXPORT}
    RUNTIME DESTINATION "${INSTALL_BIN_DIR}" COMPONENT runtime)

  # Register the binary target in the project (for reporting purpose)
  list (APPEND PROJ_ALL_BIN_TARGETS ${_exec_name})
  set (PROJ_ALL_BIN_TARGETS ${PROJ_ALL_BIN_TARGETS} PARENT_SCOPE)

  # Register, for reporting purpose, the list of executables to be built
  # and installed for that module
  list (APPEND ${MODULE_NAME}_ALL_EXECS ${_exec_name})
  set (${MODULE_NAME}_ALL_EXECS ${${MODULE_NAME}_ALL_EXECS} PARENT_SCOPE)

endmacro (module_binary_add)

##
# Installation of the CMake import helper, so that third party projects
# can refer to it (for libraries, header files and binaries)
macro (module_export_install)
  install (EXPORT ${LIB_DEPENDENCY_EXPORT} DESTINATION
    "${INSTALL_DATA_DIR}/${PACKAGE}/CMake" COMPONENT devel)
endmacro (module_export_install)


###################################################################
##                            Tests                              ##
###################################################################
#
macro (add_test_suites)
  #
  set (_test_suite_dir_list ${ARGV})

  if (Boost_FOUND)
    # Tell CMake/CTest that tests will be performed
    enable_testing() 

    # Browse all the modules, and register test suites for each of them
    set (_check_target_list "")
    foreach (_module_name ${_test_suite_dir_list})
      set (${_module_name}_ALL_TST_TARGETS "")
      # Each individual test suite is specified within the dedicated
      # sub-directory. The CMake file within each of those test sub-directories
      # specifies a target named check_${_module_name}tst.
      add_subdirectory (test/${_module_name})

      # Register, for book-keeping purpose (a few lines below), 
      # the (CMake/CTest) test target of the current module 
      list (APPEND _check_target_list check_${_module_name}tst)
    endforeach (_module_name)

    # Register all the module (CMake/CTest) test targets at once
    add_custom_target (check DEPENDS ${_check_target_list})

    # Register, for reporting purpose, the list of modules to be tested
    set (PROJ_ALL_MOD_FOR_TST ${_test_suite_dir_list})

  endif (Boost_FOUND)

endmacro (add_test_suites)

##
# Register a test with CMake/CTest.
# The parameters are:
#  * The name of the test, which will serve as the name for the test binary.
#  * The list of sources for the test binary. The list must be
#    semi-colon (';') seperated.
#  * A list of intermodule dependencies. That list is separated by
#    either white space or semi-colons (';').
macro (module_test_add_suite _test_name _test_sources)
  if (Boost_FOUND)
    # Register the test binary target
    add_executable (${_test_name}tst ${_test_sources})
    set_target_properties (${_test_name}tst PROPERTIES
      OUTPUT_NAME ${_test_name})

    message (STATUS "Test '${_test_name}' to be built with '${_test_sources}'")

    # Build the list of library targets on which that test depends upon
    set (_library_list "")
    foreach (_arg_lib ${ARGV})
      if (NOT "${_test_name};${_test_sources}" MATCHES "${_arg_lib}")
	list (APPEND _library_list ${_arg_lib}lib)
      endif ()
    endforeach (_arg_lib)

    # Tell the test binary that it depends on all those libraries
    target_link_libraries (${_test_name}tst ${_library_list} 
      ${MODULE_LIB_TARGET} ${PROJ_DEP_LIBS_FOR_TST})

    # Register the binary target in the module
    list (APPEND ${MODULE_NAME}_ALL_TST_TARGETS ${_test_name}tst)

    # Register the test with CMake/CTest
    if (WIN32)
      add_test (${_test_name}tst ${_test_name}.exe)
    else (WIN32)
      add_test (${_test_name}tst ${_test_name})
    endif (WIN32)
  endif (Boost_FOUND)

  # Register the binary target in the project (for reporting purpose)
  list (APPEND PROJ_ALL_TST_TARGETS ${${MODULE_NAME}_ALL_TST_TARGETS})
  set (PROJ_ALL_TST_TARGETS ${PROJ_ALL_TST_TARGETS} PARENT_SCOPE)

  # Register, for reporting purpose, the list of tests to be checked
  # for that module
  list (APPEND ${MODULE_NAME}_ALL_TESTS ${${MODULE_NAME}_ALL_TST_TARGETS})
  set (${MODULE_NAME}_ALL_TESTS ${${MODULE_NAME}_ALL_TESTS} PARENT_SCOPE)

endmacro (module_test_add_suite)

##
# Register all the test binaries for the current module.
# That macro must be called only once per module.
macro (module_test_build_all)
  if (Boost_FOUND)
    # Tell how to test, i.e., how to run the test binaries 
    # and collect the results
    add_custom_target (check_${MODULE_NAME}tst
      COMMAND ${CMAKE_CTEST_COMMAND} DEPENDS ${${MODULE_NAME}_ALL_TST_TARGETS})
  endif (Boost_FOUND)
endmacro (module_test_build_all)


###################################################################
##                    Development Helpers                        ##
###################################################################
# For other projects to use this component (let us name it myproj),
# install a few helpers for standard build/packaging systems: CMake,
# GNU Autotools (M4), pkgconfig/pc, myproj-config
macro (install_dev_helper_files)
  ##
  ## First, build and install CMake development helper files
  ##
  # Create a ${PROJECT_NAME}-config.cmake file for the use from 
  # the install tree and install it
  install (EXPORT ${LIB_DEPENDENCY_EXPORT}
	DESTINATION ${LIB_DEPENDENCY_EXPORT_PATH})
  set (${PACKAGE_NAME}_INCLUDE_DIRS "${INSTALL_INCLUDE_DIR}")
  set (${PACKAGE_NAME}_BIN_DIR "${INSTALL_BIN_DIR}")
  set (${PACKAGE_NAME}_LIB_DIR "${INSTALL_LIB_DIR}")
  set (${PACKAGE_NAME}_SAMPLE_DIR "${INSTALL_SAMPLE_DIR}")
  set (${PACKAGE_NAME}_CMAKE_DIR "${LIB_DEPENDENCY_EXPORT_PATH}")
  configure_file (${PROJECT_NAME}-config.cmake.in
	"${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake" @ONLY)
  configure_file (${PROJECT_NAME}-config-version.cmake.in
	"${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake" @ONLY)
  install (FILES
	"${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
	"${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
	DESTINATION "${${PACKAGE_NAME}_CMAKE_DIR}" COMPONENT devel)

  ##
  ## Then, build and install development helper files for other build systems
  ##
  # For the other developers to use that project, a few helper scripts are
  # installed:
  #  * ${PROJECT_NAME}-config (to be used by any other build system)
  #  * GNU Autotools M4 macro
  #  * packaging configuration script (pkgconfig/pc)
  include (config/devhelpers.cmake)

  # Install the development helpers
  install (PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${CFG_SCRIPT} 
	DESTINATION ${CFG_SCRIPT_PATH})
  install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGCFG_SCRIPT}
	DESTINATION ${PKGCFG_SCRIPT_PATH})
  install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${M4_MACROFILE}
	DESTINATION ${M4_MACROFILE_PATH})

endmacro (install_dev_helper_files)


#######################################
##          Overall Status           ##
#######################################
# Boost
macro (display_boost)
  if (Boost_FOUND)
    message (STATUS "* Boost:")
    message (STATUS "  - Boost_VERSION .............. : ${Boost_VERSION}")
    message (STATUS "  - Boost_LIB_VERSION .......... : ${Boost_LIB_VERSION}")
    message (STATUS "  - Boost_HUMAN_VERSION ........ : ${Boost_HUMAN_VERSION}")
    message (STATUS "  - Boost_INCLUDE_DIRS ......... : ${Boost_INCLUDE_DIRS}")
    message (STATUS "  - Boost required components .. : ${BOOST_REQUIRED_COMPONENTS}")
    message (STATUS "  - Boost required libraries ... : ${BOOST_REQUIRED_LIBS}")
  endif (Boost_FOUND)
endmacro (display_boost)

# Readline
macro (display_readline)
  if (READLINE_FOUND)
    message (STATUS)
    message (STATUS "* Readline:")
    message (STATUS "  - READLINE_VERSION ........... : ${READLINE_VERSION}")
    message (STATUS "  - READLINE_INCLUDE_DIR ....... : ${READLINE_INCLUDE_DIR}")
    message (STATUS "  - READLINE_LIBRARY ........... : ${READLINE_LIBRARY}")
  endif (READLINE_FOUND)
endmacro (display_readline)

# MySQL
macro (display_mysql)
  if (MYSQL_FOUND)
    message (STATUS)
    message (STATUS "* MySQL:")
    message (STATUS "  - MYSQL_VERSION .............. : ${MYSQL_VERSION}")
    message (STATUS "  - MYSQL_INCLUDE_DIR .......... : ${MYSQL_INCLUDE_DIR}")
    message (STATUS "  - MYSQL_LIBRARIES ............ : ${MYSQL_LIBRARIES}")
  endif (MYSQL_FOUND)
endmacro (display_mysql)

# SOCI
macro (display_soci)
  if (SOCI_FOUND)
    message (STATUS)
    message (STATUS "* SOCI:")
    message (STATUS "  - SOCI_VERSION ............... : ${SOCI_VERSION}")
    message (STATUS "  - SOCI_INCLUDE_DIR ........... : ${SOCI_INCLUDE_DIR}")
    message (STATUS "  - SOCIMYSQL_INCLUDE_DIR ...... : ${SOCIMYSQL_INCLUDE_DIR}")
    message (STATUS "  - SOCI_LIBRARIES ............. : ${SOCI_LIBRARIES}")
    message (STATUS "  - SOCIMYSQL_LIBRARIES ........ : ${SOCIMYSQL_LIBRARIES}")
  endif (SOCI_FOUND)
endmacro (display_soci)

# StdAir
macro (display_stdair)
  if (StdAir_FOUND)
    message (STATUS)
    message (STATUS "* StdAir:")
    message (STATUS "  - STDAIR_VERSION ............. : ${STDAIR_VERSION}")
    message (STATUS "  - STDAIR_BINARY_DIRS ......... : ${STDAIR_BINARY_DIRS}")
    message (STATUS "  - STDAIR_EXECUTABLES ......... : ${STDAIR_EXECUTABLES}")
    message (STATUS "  - STDAIR_LIBRARY_DIRS ........ : ${STDAIR_LIBRARY_DIRS}")
    message (STATUS "  - STDAIR_LIBRARIES ........... : ${STDAIR_LIBRARIES}")
    message (STATUS "  - STDAIR_INCLUDE_DIRS ........ : ${STDAIR_INCLUDE_DIRS}")
    message (STATUS "  - STDAIR_SAMPLE_DIR .......... : ${STDAIR_SAMPLE_DIR}")
  endif (StdAir_FOUND)
endmacro (display_stdair)

##
macro (display_status_all_modules)
  foreach (_module_name ${PROJ_ALL_MOD_FOR_BLD})
    message (STATUS "* Module ....................... : ${_module_name}")
    message (STATUS "  + Layers to be built ......... : ${${_module_name}_ALL_LAYERS}")
    message (STATUS "  + Dependencies on other layers : ${${_module_name}_INTER_TARGETS}")
    message (STATUS "  + Libraries to be built ...... : ${${_module_name}_ALL_LIBS}")
    message (STATUS "  + Executables to be built .... : ${${_module_name}_ALL_EXECS}")
    message (STATUS "  + Test to be checked ......... : ${${_module_name}_ALL_TESTS}")
  endforeach (_module_name)
endmacro (display_status_all_modules)

##
macro (display_status)
  message (STATUS)
  message (STATUS "=============================================================")
  message (STATUS "----------------------------------")
  message (STATUS "---     Project Information    ---")
  message (STATUS "----------------------------------")
  message (STATUS "PROJECT_NAME ................... : ${PROJECT_NAME}")
  message (STATUS "PACKAGE_PRETTY_NAME ............ : ${PACKAGE_PRETTY_NAME}")
  message (STATUS "PACKAGE ........................ : ${PACKAGE}")
  message (STATUS "PACKAGE_NAME ................... : ${PACKAGE_NAME}")
  message (STATUS "PACKAGE_VERSION ................ : ${PACKAGE_VERSION}")
  message (STATUS "GENERIC_LIB_VERSION ............ : ${GENERIC_LIB_VERSION}")
  message (STATUS "GENERIC_LIB_SOVERSION .......... : ${GENERIC_LIB_SOVERSION}")
  message (STATUS)
  message (STATUS "----------------------------------")
  message (STATUS "---     Build Configuration    ---")
  message (STATUS "----------------------------------")
  message (STATUS "Modules to build ............... : ${PROJ_ALL_MOD_FOR_BLD}")
  message (STATUS "Libraries to build ............. : ${PROJ_ALL_LIB_TARGETS}")
  message (STATUS "Binaries to build .............. : ${PROJ_ALL_BIN_TARGETS}")
  message (STATUS "Modules to test ................ : ${PROJ_ALL_MOD_FOR_TST}")
  message (STATUS "Binaries to test ............... : ${PROJ_ALL_TST_TARGETS}")
  display_status_all_modules ()
  message (STATUS "BUILD_SHARED_LIBS .............. : ${BUILD_SHARED_LIBS}")
  message (STATUS "CMAKE_BUILD_TYPE ............... : ${CMAKE_BUILD_TYPE}")
  message (STATUS "CMAKE_MODULE_PATH .............. : ${CMAKE_MODULE_PATH}")
  message (STATUS "CMAKE_INSTALL_PREFIX ........... : ${CMAKE_INSTALL_PREFIX}")
  message (STATUS)
  message (STATUS "----------------------------------")
  message (STATUS "--- Installation Configuration ---")
  message (STATUS "----------------------------------")
  message (STATUS "INSTALL_LIB_DIR ................ : ${INSTALL_LIB_DIR}")
  message (STATUS "INSTALL_BIN_DIR ................ : ${INSTALL_BIN_DIR}")
  message (STATUS "INSTALL_INCLUDE_DIR ............ : ${INSTALL_INCLUDE_DIR}")
  message (STATUS "INSTALL_DATA_DIR ............... : ${INSTALL_DATA_DIR}")
  message (STATUS "INSTALL_SAMPLE_DIR ............. : ${INSTALL_SAMPLE_DIR}")
  message (STATUS "INSTALL_DOC .................... : ${INSTALL_DOC}" )
  message (STATUS)
  message (STATUS "----------------------------------")
  message (STATUS "---   Packaging Configuration  ---")
  message (STATUS "----------------------------------")
  message (STATUS "CPACK_PACKAGE_CONTACT .......... : ${CPACK_PACKAGE_CONTACT}")
  message (STATUS "CPACK_PACKAGE_VENDOR ........... : ${CPACK_PACKAGE_VENDOR}")
  message (STATUS "CPACK_PACKAGE_VERSION .......... : ${CPACK_PACKAGE_VERSION}")
  message (STATUS "CPACK_PACKAGE_DESCRIPTION_FILE . : ${CPACK_PACKAGE_DESCRIPTION_FILE}")
  message (STATUS "CPACK_RESOURCE_FILE_LICENSE .... : ${CPACK_RESOURCE_FILE_LICENSE}")
  message (STATUS "CPACK_GENERATOR ................ : ${CPACK_GENERATOR}")
  message (STATUS "CPACK_DEBIAN_PACKAGE_DEPENDS ... : ${CPACK_DEBIAN_PACKAGE_DEPENDS}")
  message (STATUS "CPACK_SOURCE_GENERATOR ......... : ${CPACK_SOURCE_GENERATOR}")
  message (STATUS "CPACK_SOURCE_PACKAGE_FILE_NAME . : ${CPACK_SOURCE_PACKAGE_FILE_NAME}")
  #
  message (STATUS)
  message (STATUS "---------------------------------")
  message (STATUS "---     External libraries    ---")
  message (STATUS "---------------------------------")
  #
  display_boost ()
  display_readline ()
  display_mysql ()
  display_soci ()
  display_stdair ()
  #
  message (STATUS)
  message (STATUS "Change a value with: cmake -D<Variable>=<Value>" )
  message (STATUS "=============================================================")
  message (STATUS)

endmacro (display_status)