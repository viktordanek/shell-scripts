{
    inputs =
        {
            environment-variable.url = "github:viktordanek/environment-variable" ;
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            originator-pid.url = "github:viktordanek/originator-pid/6119b7f41d4b666d535a21862aaaa906fbe197a7" ;
            shell-script.url = "github:viktordanek/shell-script" ;
            string.url = "github:viktordanek/string" ;
            standard-input.url = "github:viktordanek/standard-input" ;
            temporary.url = "github:viktordanek/temporary" ;
            visitor.url = "github:viktordanek/visitor" ;
        } ;
    outputs =
        { environment-variable , flake-utils , nixpkgs , originator-pid , self , shell-script , standard-input , temporary , string , visitor } :
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
                                                                                            "${ pkgs.coreutils }/bin/ln --symbolic ${ primary.shell-script } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ] ;
                                                                    }
                                                                    {
                                                                        list =
                                                                            path : list :
                                                                                builtins.concatLists
                                                                                    [
                                                                                        [
                                                                                            "${ pkgs.coreutils }/bin/mkdir ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ]
                                                                                        ( builtins.concatLists list )
                                                                                    ] ;
                                                                        set =
                                                                            path : set :
                                                                                builtins.concatLists
                                                                                    [
                                                                                        [
                                                                                            "${ pkgs.coreutils }/bin/mkdir ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }"
                                                                                        ]
                                                                                        ( builtins.concatLists ( builtins.attrValues set ) )
                                                                                    ] ;
                                                                    }
                                                                    primary.shell-scripts ;
                                                            in builtins.concatStringsSep " &&\n\t" constructors ;
                                                    name = "shell-scripts" ;
                                                    src = ./. ;
                                                } ;
                                            injection =
                                                path : derivation :
                                                    {
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
                                                                    in
                                                                        if eval.success then eval.value
                                                                        else builtins.throw "There was a problem evaluating the shell-script defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                        temporary =
                                                            {
                                                                init ? null ,
                                                                post ? null ,
                                                                release ? null ,
                                                                tests ? null
                                                            } :
                                                                let
                                                                    eval =
                                                                        builtins.tryEval
                                                                            (
                                                                                _shell-script
                                                                                    {
                                                                                        environment =
                                                                                            { string , ... } :
                                                                                                [
                                                                                                    ( string "MKTEMP" "${ pkgs.coreutils }/bin/mktemp" )
                                                                                                ] ;
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
                                                                                        script = self + "/temporary/setup.sh" ;
                                                                                        tests = tests ;
                                                                                    }
                                                                            ) ;
                                                                    in
                                                                        if eval.success then eval.value
                                                                        else builtins.throw "There was a problem evaluating the temporary defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                    } ;
                                        primary =
                                            {
                                                default-name =
                                                    if builtins.typeOf default-name == "string" then default-name
                                                    else builtins.throw "default-name is not string but ${ builtins.typeOf default-name }." ;
                                                host-path =
                                                    if builtins.typeOf host-path == "string" then host-path
                                                    else builtins.throw "host-path is not string but ${ builtins.typeOf host-path }." ;
                                                shell-scripts =
                                                    _visitor
                                                        {
                                                            lambda = path : value : value ;
                                                        }
                                                        { }
                                                        shell-scripts ;
                                            } ;
                                in
                                    {
                                        shell-scripts = _shell-scripts ;
                                        tests =
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase =
                                                        let
                                                            constructors =
                                                                builtins.concatStringsSep
                                                                    " &&\n\t"
                                                                    (
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
                                                                            primary.shell-scripts
                                                                    ) ;
                                                            in
                                                                ''
                                                                    ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                        ${ pkgs.coreutils }/bin/mkdir $out/bin &&
                                                                        makeWrapper ${ pkgs.writeShellScript "constructors" constructors } $out/bin/constructors --set LN ${ pkgs.coreutils }/bin/ln --set MKDIR ${ pkgs.coreutils }/bin/mkdir --set OUT $out &&
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
                                                                        fi
                                                                '' ;
                                                    name = "tests" ;
                                                    nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                    src = ./. ;
                                                } ;
                                    } ;
                            pkgs = builtins.import nixpkgs { system = system ; } ;
                            scripts =
                                {
                                    temporary =
                                        {
                                            setup =
                                                let
                                                    setup =
                                                        pkgs.stdenv.mkDerivation
                                                            {
                                                                installPhase =
                                                                    ''
                                                                    '' ;
                                                                name = "setup" ;
                                                                src = ./. ;
                                                            } ;
                                                    in
                                                        {

                                                        } ;
                                            teardown =
                                                {

                                                } ;
                                        } ;
                                } ;
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
                                                                                    shell-script =
                                                                                        { shell-script , ... } :
                                                                                            shell-script
                                                                                                {
                                                                                                    environment =
                                                                                                        { string , ... } :
                                                                                                            [
                                                                                                                ( string "CAT" "${ pkgs.coreutils }/bin/cat" )
                                                                                                                ( string "CUT" "${ pkgs.coreutils }/bin/cut" )
                                                                                                                ( string "CHMOD" "${ pkgs.coreutils }/bin/chmod" )
                                                                                                                ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                                                                ( string "SHA512SUM" "${ pkgs.coreutils }/bin/sha512sum" )
                                                                                                            ] ;
                                                                                                    script = self + "/shell-script.sh" ;
                                                                                                    tests =
                                                                                                        {
                                                                                                            shell-script =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        mounts =
                                                                                                                            {
                                                                                                                                "/singleton" =
                                                                                                                                    {
                                                                                                                                        expected = self + "/expected/shell-script/mounts/singleton" ;
                                                                                                                                        initial =
                                                                                                                                            [
                                                                                                                                                "echo 0d157cd5708ec01d0b865b8fbef69d7b28713423ec011a86a5278cf566bcbd8e79a2daa996d7b1b8224088711b75fda91bdc1d41d0e53dd7118cfbdec8296044 > /mount/target"
                                                                                                                                            ] ;
                                                                                                                                    } ;
                                                                                                                            } ;
                                                                                                                        standard-error = self + "/expected/shell-script/standard-error" ;
                                                                                                                        standard-output = self + "/expected/shell-script/standard-output" ;
                                                                                                                        status = 168 ;
                                                                                                                        test =
                                                                                                                            [
                                                                                                                                "candidate 2a6273b589f1a8b3ee9e5ad7fc51941863a0b5a8ed1eebe444937292110823579f4b9eb6c72d096012d4cf393335d7e8780ec7ec5d02579aabe050f22ebe2201"
                                                                                                                            ] ;
                                                                                                                    } ;
                                                                                                        } ;
                                                                                                } ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/touch $out &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ shell-scripts.shell-scripts.shell-script } &&
                                                                            if [ -f ${ shell-scripts.tests }/SUCCESS ]
                                                                            then
                                                                                ${ pkgs.coreutils }/bin/echo "The tests SUCCEEDED"
                                                                            elif [ -f ${ shell-scripts.tests }/FAILURE ]
                                                                            then
                                                                                ${ pkgs.coreutils }/bin/echo "There was a predicted failure in ${ shell-scripts.tests }" >&2 &&
                                                                                    exit 63
                                                                            else
                                                                                ${ pkgs.coreutils }/bin/echo "There was an unpredicted failure in ${ shell-scripts.tests }" >&2 &&
                                                                                    exit 62
                                                                            fi
                                                                    '' ;
                                                        name = "foobar" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}