{
    inputs =
        {
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            originator-pid.url = "github:viktordanek/originator-pid/6119b7f41d4b666d535a21862aaaa906fbe197a7" ;
            shell-script =
                {
                    url = "github:viktordanek/shell-script/4974ddc86591c9eb7c4c428b988e3beb016c3b53" ;
                } ;
            string.url = "github:viktordanek/string/139557a8e70542b3eec4d729791e7e6283c220e8" ;
            standard-input.url = "github:viktordanek/standard-input/377e010bb1dd5becc27fb31d1180b8781afbcb4f" ;
            temporary.url = "github:viktordanek/temporary/e1f37a3a4fb63f16994b4415108df04fee6dec6b" ;
            visitor.url = "github:viktordanek/visitor" ;
        } ;
    outputs =
        { flake-utils , nixpkgs , originator-pid , self , shell-script , standard-input , temporary , string , visitor } :
            let
                fun =
                    system :
                        let
                            _shell-script = builtins.getAttr system shell-script.lib ;
                            _visitor = builtins.getAttr system visitor.lib ;
                            lib =
                                {
                                    default-name ? "script" ,
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
                                                primary ;
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
                                                                                    primary = value "$out" ;
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
                                                                    primary ;
                                                            in builtins.concatStringsSep " &&\n\t" constructors ;
                                                    name = "shell-scripts" ;
                                                    src = ./. ;
                                                } ;
                                        primary =
                                            _visitor
                                                {
                                                    lambda =
                                                        path : value :
                                                            let
                                                                injection =
                                                                    {
                                                                        shell-script =
                                                                            {
                                                                                environment ? x : [ ] ,
                                                                                script ,
                                                                                tests ? null
                                                                            } : ignore :
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
                                                                                                                shell-scripts = name : fun : "--set ${ name } ${ builtins.trace "${ builtins.typeOf ( fun _shell-scripts ) }" ( fun shell-scripts ) }" ;
                                                                                                                standard-input = builtins.getAttr system standard-input.lib ;
                                                                                                                string = builtins.getAttr system string.lib ;
                                                                                                            } ;
                                                                                                        name = builtins.toString ( if builtins.length path > 0 then builtins.elemAt path ( ( builtins.length path ) - 1 ) else default-name ) ;
                                                                                                        script = script ;
                                                                                                        tests = tests ;
                                                                                                    }
                                                                                            ) ;
                                                                                    in
                                                                                        if eval.success then eval.value
                                                                                        else builtins.throw "There was a problem evaluating the shell-script defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                                    } ;
                                                                in value injection ;
                                                }
                                                { }
                                                shell-scripts ;
                                in
                                    {
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
                                                                                    primary = value null ;
                                                                                    in
                                                                                        [
                                                                                           "${ pkgs.coreutils }/bin/ln --symbolic ${ primary.tests} ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }"
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
                                                                    primary ;
                                                            in builtins.concatStringsSep " &&\n\t" constructors ;
                                                    name = "tests" ;
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
                                                                                    foo =
                                                                                        [
                                                                                            {
                                                                                                bar =
                                                                                                    { shell-script , ... } :
                                                                                                        shell-script
                                                                                                            {
                                                                                                                environment =
                                                                                                                    { originator-pid , path-int , path-string , standard-input , shell-scripts , string } :
                                                                                                                        [
                                                                                                                            ( string "JQ" "${ pkgs.jq }/bin/jq" )
                                                                                                                            ( shell-scripts "FOO" ( shell-scripts : builtins.getAttr "bar" ( builtins.elemAt ( shell-scripts.foo ) 0 ) ) )
                                                                                                                            ( originator-pid { } )
                                                                                                                            ( path-int "PATH_INT" 1 )
                                                                                                                            ( path-string "PATH_STRING" 2 )
                                                                                                                            ( standard-input { } )
                                                                                                                            ( string "TEMPLATE_FILE" ( self + "/scripts/foobar.json" ) )
                                                                                                                            ( string "YQ" "${ pkgs.yq }/bin/yq" )
                                                                                                                        ] ;
                                                                                                                script = self + "/scripts/foobar.sh" ;
                                                                                                                tests =
                                                                                                                    {
                                                                                                                        main =
                                                                                                                            ignore :
                                                                                                                                {
                                                                                                                                    standard-output = builtins.readFile ( self + "/expected/standard-output" ) ;
                                                                                                                                } ;
                                                                                                                    } ;
                                                                                                            } ;
                                                                                            }
                                                                                        ] ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/touch $out &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ builtins.getAttr "bar" ( builtins.elemAt ( shell-scripts.shell-scripts.foo ) 0 ) } &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ shell-scripts.tests }
                                                                    '' ;
                                                        name = "foobar" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}