#!/usr/bin/env bash

# Removes all generated makefiles
make -f Makefile mrproper

# Dependencies for local or global builds.
# When building the packages separately, dependencies are not set as everything
# should already be available in $(COQMF_LIB)/user-contrib/MetaCoq/*
# checker is treated specially: due to code generation, we rebuild the template-coq module locally
# when building the checker package
# For local builds, we set specific dependencies of each subproject in */metacoq-config

# CWD=`pwd`

if command -v coqc >/dev/null 2>&1
then
    COQLIB=`coqc -where`

    if [ "$1" == "local" ]
    then
        echo "Building MetaCoq locally"
        CHECKER_DEPS="-R ../template-coq/theories MetaCoq.Template -I ../template-coq/build"
        PCUIC_MLDEPS="-I ../checker/src"
        PCUIC_VDEPS="-R ../checker/theories MetaCoq.Checker"
        SAFECHECKER_DEPS="${PCUIC_VDEPS} -R ../pcuic/theories MetaCoq.PCUIC"
        ERASURE_DEPS="-R ../safechecker/theories MetaCoq.SafeChecker"
        TRANSLATIONS_DEPS="${PCUIC_VDEPS}"
    else
        echo "Building MetaCoq globally (default)"
        # To find the metacoq template plugin
        CHECKER_DEPS="-I ${COQLIB}/user-contrib/MetaCoq/Template"
        # The pcuic plugin depends on the checker plugin
        # The safechecker and erasure plugins are self-contained
        # These dependencies should not be necessary when separate linking of ocaml object
        # files is supported by coq_makefile
        PCUIC_MLDEPS="-I ${COQLIB}/user-contrib/MetaCoq/Checker"
        PCUIC_VDEPS=""
        SAFECHECKER_DEPS=""
        ERASURE_DEPS=""
        TRANSLATIONS_DEPS=""
    fi

    echo "# DO NOT EDIT THIS FILE: autogenerated from ./configure.sh" > checker/metacoq-config
    echo "# DO NOT EDIT THIS FILE: autogenerated from ./configure.sh" > pcuic/metacoq-config
    echo "# DO NOT EDIT THIS FILE: autogenerated from ./configure.sh" > safechecker/metacoq-config
    echo "# DO NOT EDIT THIS FILE: autogenerated from ./configure.sh" > erasure/metacoq-config
    echo "# DO NOT EDIT THIS FILE: autogenerated from ./configure.sh" > translations/metacoq-config

    echo ${CHECKER_DEPS} >> checker/metacoq-config
    # echo "OCAMLPATH = \"${CWD}/template-coq\"" >> checker/metacoq-config
    echo ${CHECKER_DEPS} ${PCUIC_MLDEPS} ${PCUIC_VDEPS} >> pcuic/metacoq-config
    echo ${CHECKER_DEPS} ${SAFECHECKER_DEPS} >> safechecker/metacoq-config
    echo ${CHECKER_DEPS} ${SAFECHECKER_DEPS} ${ERASURE_DEPS} >> erasure/metacoq-config
    echo ${CHECKER_DEPS} ${TRANSLATIONS_DEPS} >> translations/metacoq-config
else
    echo "Error: coqc not found in path"
fi