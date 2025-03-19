{
    inputs =
        {
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            shell-script.url = "github:viktordanek/shell-script" ;
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
                                                            root =
                                                                builtins.concatLists
                                                                    [
                                                                        [
                                                                            "${ pkgs.coreutils }/bin/mkdir $out"
                                                                        ]
                                                                        constructors
                                                                    ] ;
                                                            in builtins.concatStringsSep " &&\n\t" root ;
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
                                                                            } : derivation :
                                                                                let
                                                                                    eval =
                                                                                        _shell-script
                                                                                            {
                                                                                                environment = environment ;
                                                                                                extensions =
                                                                                                    [
                                                                                                        {
                                                                                                            name = path ;
                                                                                                            value =
                                                                                                                name : index :
                                                                                                                    if builtins.typeOf index == "int" then
                                                                                                                        if index >= 0 && index < builtins.length path then builtins.elemAt path index
                                                                                                                        else if index < 0 then builtins.throw "index (${ builtins.toString index }) is less than zero at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }."
                                                                                                                        else builtins.throw "index (${ builtins.toString index}) is greater than the path length (${ builtins.toString ( builtins.length path ) }) at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }."
                                                                                                                    else builtins.throw "index is not int but ${ builtins.typeOf index } at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                                                                        }
                                                                                                        {
                                                                                                            name = "string" ;
                                                                                                            value = name : value : "--set ${ name } ${ builtins.toString value }" ;
                                                                                                        }
                                                                                                    ] ;
                                                                                                name = builtins.toString ( if builtins.length path > 0 then builtins.elemAt ( ( builtins.length path ) - 1 ) else default-name ) ;
                                                                                                tests = tests ;
                                                                                            } ;
                                                                                    in
                                                                                        if eval.success then eval.value
                                                                                        else builtins.throw "There was a problem evaluating the shell-script defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                                    } ;
                                                                in value injection ;
                                                }
                                                { }
                                                shell-scripts ;
                                        shell-scripts =
                                            _visitor
                                                {
                                                    lambda = path : value : builtins.concatStringsSep "/" ( builtins.concatLists [ [ derivation ] ( builtins.map builtins.toJSON path ) ] ) ;
                                                }
                                                {
                                                }
                                                primary ;
                                in
                                    {
                                        shell-scripts = shell-scripts ;
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
                                                                                    primary = value derivation ;
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
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}