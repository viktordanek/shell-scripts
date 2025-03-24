{
    inputs =
        {
            environment-variable.url = "github:viktordanek/environment-variable" ;
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            originator-pid.url = "github:viktordanek/originator-pid" ;
            shell-script.url = "github:viktordanek/shell-script/milestone/03282025" ;
            string.url = "github:viktordanek/string" ;
            standard-input.url = "github:viktordanek/standard-input" ;
            visitor.url = "github:viktordanek/visitor" ;
        } ;
    outputs =
        { environment-variable , flake-utils , nixpkgs , originator-pid , self , shell-script , standard-input , string , visitor } :
            let
                fun =
                    system :
                        let
                            _environment-variable = builtins.getAttr system environment-variable.lib ;
                            _shell-script = builtins.getAttr system shell-script.lib ;
                            _visitor = builtins.getAttr system visitor.lib ;
                            lib =
                                {
                                    default-name ? "script" ,
                                    host-path ? _environment-variable "TMPDIR" ,
                                    shell-scripts ? null ,
                                } :
                                    let
                                        _shell-scripts =
                                            _visitor
                                                {
                                                    lambda = path : value : builtins.concatStringsSep "/" ( builtins.concatLists [ [ derivation ] ( builtins.map builtins.toJSON path ) ] ) ;
                                                }
                                                {
                                                }
                                                primary.shell-scripts ;
                                        derivation =
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase =
                                                        let
                                                            constructors =
                                                                _visitor
                                                                    {
                                                                        lambda =
                                                                            path : value :
                                                                                let
                                                                                    primary = value ( injection path "$out" ) ;
                                                                                    in
                                                                                        [
                                                                                            "${ _environment-variable "LN" } --symbolic ${ primary.shell-script } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ ( _environment-variable "OUT" ) "links" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ] ;
                                                                    }
                                                                    {
                                                                        list =
                                                                            path : list :
                                                                                builtins.concatLists
                                                                                    [
                                                                                        [
                                                                                            "${ _environment-variable "MKDIR" } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ ( _environment-variable "OUT" ) "links" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ]
                                                                                        ( builtins.concatLists list )
                                                                                    ] ;
                                                                        set =
                                                                            path : set :
                                                                                builtins.concatLists
                                                                                    [
                                                                                        [
                                                                                            "${ _environment-variable "MKDIR" } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ ( _environment-variable "OUT" ) "links" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ]
                                                                                        ( builtins.concatLists ( builtins.attrValues set ) )
                                                                                    ] ;
                                                                    }
                                                                    primary.shell-scripts ;
                                                            in
                                                                ''
                                                                    ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                        ${ pkgs.coreutils }/bin/mkdir $out/bin &&
                                                                        makeWrapper ${ pkgs.writeShellScript "constructors" ( builtins.concatStringsSep " &&\n\t" constructors ) } $out/bin/constructors --set LN ${ pkgs.coreutils }/bin/ln --set MKDIR ${ pkgs.coreutils }/bin/mkdir --set OUT $out &&
                                                                        $out/bin/constructors
                                                                '' ;
                                                    name = "shell-scripts" ;
                                                    src = ./. ;
                                                } ;
                                            injection =
                                                path : derivation :
                                                    {
                                                        # cache =
                                                        shell-script =
                                                            {
                                                                environment ? x : [ ] ,
                                                                script ,
                                                                tests ? null
                                                            } :
                                                                let
                                                                    eval =
                                                                        builtins.tryEval
                                                                            (
                                                                                _shell-script
                                                                                    {
                                                                                        environment = environment ;
                                                                                        extensions =
                                                                                            {
                                                                                                originator-pid = builtins.getAttr system originator-pid.lib ;
                                                                                                path-int =
                                                                                                    name : index :
                                                                                                        if builtins.typeOf index == "int" then
                                                                                                            if index < 0 then builtins.throw "the index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is less than zero."
                                                                                                            else if index >= builtins.length path then builtins.throw "The index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is greater than or equal to the length of the path ${ builtins.toString ( builtins.length path ) }."
                                                                                                            else
                                                                                                                if builtins.typeOf ( builtins.elemAt path index ) == "int" then "--set ${ name } ${ builtins.toString ( builtins.elemAt path index ) }"
                                                                                                                else if builtins.typeOf ( builtins.elemAt path index ) == "string" then builtins.throw "since the index = ${ builtins.toString index } element of path = ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is a string and not an int it would be better to use path-string."
                                                                                                                else builtins.throw "the value at index = ${ builtins.toString index } element of path = ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not int, string but builtins.typeOf ( builtins.elemAt path index )"
                                                                                                        else builtins.throw "the index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not int but ${ builtins.typeOf index }." ;
                                                                                                path-string =
                                                                                                    name : index :
                                                                                                        if builtins.typeOf index == "int" then
                                                                                                            if index < 0 then builtins.throw "the index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is less than zero."
                                                                                                            else if index >= builtins.length path then builtins.throw "The index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is greater than or equal to the length of the path ${ builtins.toString ( builtins.length path ) }."
                                                                                                            else
                                                                                                                if builtins.typeOf ( builtins.elemAt path index ) == "string" then "--set ${ name } ${ builtins.elemAt path index }"
                                                                                                                else if builtins.typeOf ( builtins.elemAt path index ) == "int" then builtins.throw "since the index = ${ builtins.toString index } element of path = ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is an int and not a string it would be better to use path-int."
                                                                                                                else builtins.throw "the value at index = ${ builtins.toString index } element of path = ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not int, string but builtins.typeOf ( builtins.elemAt path index )"
                                                                                                        else builtins.throw "the index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not int but ${ builtins.typeOf index }." ;
                                                                                                shell-scripts =
                                                                                                    name : fun :
                                                                                                        let
                                                                                                            in
                                                                                                                "--set ${ name } ${ fun shell-scripts }" ;
                                                                                                standard-input = builtins.getAttr system standard-input.lib ;
                                                                                                string = builtins.getAttr system string.lib ;
                                                                                            } ;
                                                                                        name = builtins.toString ( if builtins.length path > 0 then builtins.elemAt path ( ( builtins.length path ) - 1 ) else primary.default-name ) ;
                                                                                        script = script ;
                                                                                        tests = tests ;
                                                                                    }
                                                                            ) ;
                                                                        shell-scripts =
                                                                            _visitor
                                                                                {
                                                                                    lambda = path : value : builtins.concatStringsSep "/" ( builtins.concatLists [ [ derivation "links" ] ( builtins.map builtins.toJSON path ) ] ) ;
                                                                                }
                                                                                { }
                                                                                primary.shell-scripts ;
                                                                    in
                                                                        if eval.success then eval.value
                                                                        else builtins.throw "There was a problem evaluating the shell-script defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                        temporary =
                                                            {
                                                                environment ? x : [ ] ,
                                                                init ? null ,
                                                                post ? null ,
                                                                release ? null ,
                                                                tests ? null
                                                            } :
                                                                let
                                                                    eval =
                                                                        builtins.tryEval
                                                                            (
                                                                                let
                                                                                    setup = init : release : post : null ;
                                                                                    in
                                                                                        _shell-script
                                                                                            {
                                                                                                champion = setup init release post ;
                                                                                                environment = environment ;
                                                                                                extensions =
                                                                                                    {
                                                                                                        originator-pid = builtins.getAttr system originator-pid.lib ;
                                                                                                        path-int =
                                                                                                            name : index :
                                                                                                                if builtins.typeOf index == "int" then
                                                                                                                    if index < 0 then builtins.throw "the index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is less than zero."
                                                                                                                    else if index >= builtins.length path then builtins.throw "The index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is greater than or equal to the length of the path ${ builtins.toString ( builtins.length path ) }."
                                                                                                                    else
                                                                                                                        if builtins.typeOf ( builtins.elemAt path index ) == "int" then "--set ${ name } ${ builtins.toString ( builtins.elemAt path index ) }"
                                                                                                                        else if builtins.typeOf ( builtins.elemAt path index ) == "string" then builtins.throw "since the index = ${ builtins.toString index } element of path = ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is a string and not an int it would be better to use path-string."
                                                                                                                        else builtins.throw "the value at index = ${ builtins.toString index } element of path = ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not int, string but builtins.typeOf ( builtins.elemAt path index )"
                                                                                                                else builtins.throw "the index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not int but ${ builtins.typeOf index }." ;
                                                                                                        path-string =
                                                                                                            name : index :
                                                                                                                if builtins.typeOf index == "int" then
                                                                                                                    if index < 0 then builtins.throw "the index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is less than zero."
                                                                                                                    else if index >= builtins.length path then builtins.throw "The index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is greater than or equal to the length of the path ${ builtins.toString ( builtins.length path ) }."
                                                                                                                    else
                                                                                                                        if builtins.typeOf ( builtins.elemAt path index ) == "string" then "--set ${ name } ${ builtins.elemAt path index }"
                                                                                                                        else if builtins.typeOf ( builtins.elemAt path index ) == "int" then builtins.throw "since the index = ${ builtins.toString index } element of path = ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is an int and not a string it would be better to use path-int."
                                                                                                                        else builtins.throw "the value at index = ${ builtins.toString index } element of path = ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not int, string but builtins.typeOf ( builtins.elemAt path index )"
                                                                                                                else builtins.throw "the index defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not int but ${ builtins.typeOf index }." ;
                                                                                                        shell-scripts =
                                                                                                            name : fun :
                                                                                                                let
                                                                                                                    in
                                                                                                                        "--set ${ name } ${ fun shell-scripts }" ;
                                                                                                        standard-input = builtins.getAttr system standard-input.lib ;
                                                                                                        string = builtins.getAttr system string.lib ;
                                                                                                        name = builtins.toString ( if builtins.length path > 0 then builtins.elemAt path ( ( builtins.length path ) - 1 ) else primary.default-name ) ;
                                                                                                        script = setup init release post ;
                                                                                                        tests = tests ;
                                                                                                    } ;
                                                                                                }
                                                                                ) ;
                                                                    in
                                                                        if eval.success then eval.value
                                                                        else builtins.throw "There was a problem evaluating the shell-script defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                    } ;
                                        primary =
                                            {
                                                default-name =
                                                    if builtins.typeOf default-name == "string" then default-name
                                                    else builtins.throw "default-name is not string but ${ builtins.typeOf default-name }." ;
                                                shell-scripts =
                                                    _visitor
                                                        {
                                                            lambda = path : value : value ;
                                                        }
                                                        { }
                                                        shell-scripts ;
                                            } ;
                                        scripts =
                                            {
                                                vacuum =
                                                    _shell-script
                                                        {
                                                            environment =
                                                                { resource , string , target } :
                                                                    [
                                                                        ( string "CAT" "${ pkgs.coreutils }/bin/cat" )
                                                                        ( string "CHMOD" "${ pkgs.coreutils }/bin/chmod" )
                                                                        ( string "CUT" "${ pkgs.coreutils }/bin/cut" )
                                                                        ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                        ( string "FIND" "${ pkgs.findutils }/bin/find" )
                                                                        ( string "MKDIR" "${ pkgs.coreutils }/bin/mkdir" )
                                                                        ( resource )
                                                                        ( string "SHA512SUM" "${ pkgs.coreutils }/bin/sha512sum" )
                                                                        ( string "WC" "${ pkgs.coreutils }/bin/wc" )
                                                                        ( target )
                                                                    ] ;
                                                            extensions =
                                                                {
                                                                    # resource = ''--run "export RESOURCE=$( ${ pkgs.coreutils }/bin/mktemp ${ host-path }/XXXXXXXX"'' ;
                                                                    string = name : value : "--set ${ name } ${ value }" ;
                                                                    target = ''--run "export TARGET=${ _environment-variable "RESOURCE" }/target"'' ;
                                                                } ;
                                                            name = "vacuum" ;
                                                            script = self + "/vacuum.sh" ;
                                                            tests = [ ] ;
                                                        } ;
                                            } ;
                                in
                                    {
                                        scripts = scripts ;
                                        shell-scripts = _shell-scripts ;
                                        tests =
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase =
                                                        let
                                                            constructors =
                                                                _visitor
                                                                    {
                                                                        lambda =
                                                                            path : value :
                                                                                let
                                                                                    primary = value ( injection path derivation ) ;
                                                                                    in
                                                                                        [
                                                                                           "${ _environment-variable "LN" } --symbolic ${ primary.tests } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ ( _environment-variable "OUT" ) "links" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ] ;
                                                                    }
                                                                    {
                                                                        list =
                                                                            path : list :
                                                                                builtins.concatLists
                                                                                    [
                                                                                        [
                                                                                            "${ _environment-variable "MKDIR" } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ ( _environment-variable "OUT" ) "links" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ]
                                                                                        ( builtins.concatLists list )
                                                                                    ] ;
                                                                        set =
                                                                            path : set :
                                                                                builtins.concatLists
                                                                                    [
                                                                                        [
                                                                                            "${ _environment-variable "MKDIR" } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ ( _environment-variable "OUT" ) "links" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ]
                                                                                        ( builtins.concatLists ( builtins.attrValues set ) )
                                                                                    ] ;
                                                                    }
                                                                    primary.shell-scripts ;
                                                            in
                                                                ''
                                                                    ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                        ${ pkgs.coreutils }/bin/mkdir $out/bin &&
                                                                        makeWrapper ${ pkgs.writeShellScript "constructors" ( builtins.concatStringsSep " &&\n\t" constructors ) } $out/bin/constructors --set LN ${ pkgs.coreutils }/bin/ln --set MKDIR ${ pkgs.coreutils }/bin/mkdir --set OUT $out &&
                                                                        $out/bin/constructors &&
                                                                        ALL=$( ${ pkgs.findutils }/bin/find $out/links -mindepth 1 -type l | ${ pkgs.coreutils }/bin/wc --lines ) &&
                                                                        SUCCESS=$( ${ pkgs.findutils }/bin/find $out/links -mindepth 1 -type l -exec ${ pkgs.coreutils }/bin/readlink {} \; | ${ pkgs.findutils }/bin/find $( ${ pkgs.coreutils }/bin/tee ) -mindepth 1 -maxdepth 1 -type f -name SUCCESS | ${ pkgs.coreutils }/bin/wc --lines ) &&
                                                                        FAILURE=$( ${ pkgs.findutils }/bin/find $out/links -mindepth 1 -type l -exec ${ pkgs.coreutils }/bin/readlink {} \; | ${ pkgs.findutils }/bin/find $( ${ pkgs.coreutils }/bin/tee ) -mindepth 1 -maxdepth 1 -type f -name FAILURE | ${ pkgs.coreutils }/bin/wc --lines ) &&
                                                                        if [ ${ _environment-variable "ALL" } == ${ _environment-variable "SUCCESS" } ]
                                                                        then
                                                                            ${ pkgs.coreutils }/bin/echo ${ _environment-variable "SUCCESS" } > $out/SUCCESS
                                                                        elif [ ${ _environment-variable "ALL" } == $(( ${ _environment-variable "SUCCESS" } + ${ _environment-variable "FAILURE" } )) ]
                                                                        then
                                                                            ${ pkgs.coreutils }/bin/echo ${ _environment-variable "FAILURE" } > $out/FAILURE
                                                                        else
                                                                            ${ pkgs.coreutils }/bin/touch ${ _environment-variable "FAILURE" }
                                                                        fi
                                                                '' ;
                                                    name = "tests" ;
                                                    nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                    src = ./. ;
                                                } ;
                                    } ;
                            pkgs = builtins.import nixpkgs { system = system ; } ;
                            in
                                {
                                    checks =
                                        {
                                            foobar =
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            let
                                                                shell-scripts =
                                                                    lib
                                                                        {
                                                                            shell-scripts =
                                                                                {
                                                                                    foobar-1 =
                                                                                        { shell-script , ... } :
                                                                                            shell-script
                                                                                                {
                                                                                                    environment =
                                                                                                        { string , ... } :
                                                                                                            [
                                                                                                                ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                                                            ] ;
                                                                                                    script = self + "/foobar.sh" ;
                                                                                                    tests =
                                                                                                        {
                                                                                                            foobar-1 =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        standard-output = "hi" ;
                                                                                                                        test = "candidate" ;
                                                                                                                    } ;
                                                                                                            foobar-2 =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        standard-output = "hi" ;
                                                                                                                        test = "candidate" ;
                                                                                                                    } ;
                                                                                                        } ;
                                                                                                } ;
                                                                                    foobar-2 =
                                                                                        { shell-script , ... } :
                                                                                            shell-script
                                                                                                {
                                                                                                    environment =
                                                                                                        { string , ... } :
                                                                                                            [
                                                                                                                ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                                                            ] ;
                                                                                                    script = self + "/foobar.sh" ;
                                                                                                    tests =
                                                                                                        {
                                                                                                            foobar-1 =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        standard-output = "hi" ;
                                                                                                                        test = "candidate" ;
                                                                                                                    } ;
                                                                                                            foobar-2 =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        standard-output = "hi" ;
                                                                                                                        test = "candidate" ;
                                                                                                                    } ;
                                                                                                        } ;
                                                                                                } ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/touch $out &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ shell-scripts.tests }
                                                                    '' ;
                                                        name = "foobar" ;
                                                        src = ./. ;
                                                    } ;
                                            vacuum =
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            let
                                                                point = lib { } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            ${ pkgs.coreutils }/bin/echo $out &&
                                                                            if [ -f ${ point.scripts.vacuum.tests }/SUCCESS ]
                                                                            then
                                                                                ${ pkgs.coreutils }/bin/echo SUCCESS &&
                                                                                    ${ pkgs.coreutils }/bin/ln --symbolic ${ point.scripts.vacuum.tests } $out/SUCCESS
                                                                            elif [ -f ${ point.scripts.vacuum.tests }/FAILURE ]
                                                                            then
                                                                                ${ pkgs.coreutils }/bin/echo FAILURE $out >&2 &&
                                                                                    ${ pkgs.coreutils }/bin/ln --symbolic ${ point.scripts.vacuum.tests }/FAILURE $out/FAILURE &&
                                                                                    exit 63
                                                                            else
                                                                                ${ pkgs.coreutils }/bin/echo ERROR $out >&2 &&
                                                                                    ${ pkgs.coreutils }/bin/touch $out/FAILURE &&
                                                                                    exit 63
                                                                            fi
                                                                    '' ;
                                                        name = "vacuum" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}