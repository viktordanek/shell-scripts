{
    inputs =
        {
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            shell-script =
                {
                    url = "github:viktordanek/shell-script/30961d947d9ee42e39e8b9cb0379ad7b34f426b9" ;
                } ;
            visitor.url = "github:viktordanek/visitor" ;
        } ;
    outputs =
        { flake-utils , nixpkgs , self , shell-script , visitor } :
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
                                                                                                                string = name : value : "--set ${ name } ${ builtins.toString value }" ;
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
                                                                                            "${ pkgs.coreutils }/bin/ln --symbolic ${ primary.tests } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }"
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
                                                                                        ( builtins.concatList list )
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
                                                            root =
                                                                builtins.concatLists
                                                                    [
                                                                        [
                                                                            "${ pkgs.coreutils }/bin/mkdir $out"
                                                                        ]
                                                                        constructors
                                                                    ] ;
                                                            in builtins.concatStringsSep " &&\n\t" root ;
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
                                                                                    foobar =
                                                                                        { shell-script , ... } :
                                                                                            shell-script
                                                                                                {
                                                                                                    environment =
                                                                                                        { string , ... } :
                                                                                                            [
                                                                                                                ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                                                                ( string "MESSAGE" "5875755ac3b432182a8817350e1994539d0b5c3ef238169ee7923dc498eea2a6cb9cbe242c7763f88e3c5e59b6050e03e215ca26201ced47157f6025f6e876b3" )
                                                                                                            ] ;
                                                                                                    script = self + "/scripts/foobar.sh" ;
                                                                                                    tests = null ;
                                                                                                } ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/touch $out &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ shell-scripts.shell-scripts.foobar } &&
                                                                            exit 44
                                                                    '' ;
                                                        name = "foobar" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}