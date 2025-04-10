{
    inputs =
        {
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
                                                                    primary ;
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
                                                                                        name = builtins.toString ( if builtins.length path > 0 then builtins.elemAt path ( ( builtins.length path ) - 1 ) else default-name ) ;
                                                                                        script = script ;
                                                                                        tests = tests ;
                                                                                    }
                                                                            ) ;
                                                                        shell-scripts =
                                                                            _visitor
                                                                                {
                                                                                    lambda = path : value : builtins.concatStringsSep "/" ( builtins.concatLists [ [ derivation ] ( builtins.map builtins.toJSON path ) ] ) ;
                                                                                }
                                                                                {
                                                                                }
                                                                                primary ;
                                                                    in
                                                                        if eval.success then eval.value
                                                                        else builtins.throw "There was a problem evaluating the shell-script defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                        temporary =
                                                            {
                                                                init ? null ,
                                                                release ? null ,
                                                                post ? null ,
                                                                tests ? null
                                                            } :
                                                                let
                                                                    eval =
                                                                        builtins.tryEval
                                                                            (
                                                                                builtins.getAttr system temporary.lib
                                                                                    {
                                                                                        init =
                                                                                             if builtins.typeOf init == "lambda" then init shell-scripts
                                                                                             else if builtins.typeOf init == "null" then init
                                                                                             else builtins.throw "The init for the temporary defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not lambda, null but ${ builtins.typeOf init }." ;
                                                                                       post =
                                                                                            if builtins.typeOf post == "lambda" then post shell-scripts
                                                                                            else if builtins.typeOf post == "null" then post
                                                                                            else builtins.throw "The post for the temporary defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not lambda, null but ${ builtins.typeOf post }." ;
                                                                                       release =
                                                                                            if builtins.typeOf init == "lambda" then release shell-scripts
                                                                                            else if builtins.typeOf release == "null" then release
                                                                                            else builtins.throw "The release for the temporary defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is not lambda, null but ${ builtins.typeOf release }." ;
                                                                                        tests = tests ;
                                                                                    }
                                                                        ) ;
                                                                in
                                                                    if eval.success then eval.value
                                                                    else builtins.throw "There was a problem evaluating the temporary defined at ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) }." ;
                                                    } ;
                                        primary =
                                            _visitor
                                                {
                                                    lambda = path : value : value ;
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
                                                                                    primary = value ( injection path derivation ) ;
                                                                                    in
                                                                                        [
                                                                                           # "if ! ${ pkgs.diffutils }/bin/diff --recursive ${ primary.tests }/expected ${ primary.tests }/observed ; then ${ pkgs.coreutils }/bin/ln --symbolic ${ primary.tests } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) } ; fi"
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
                                                            in builtins.concatStringsSep " &&\n\t" ( builtins.concatLists [ [ "${ pkgs.coreutils }/bin/echo $out" ] constructors ] ) ;
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
                                                                                    file1 =
                                                                                        { shell-script , ... } :
                                                                                            shell-script
                                                                                                {
                                                                                                    environment =
                                                                                                        { string , ... } :
                                                                                                            [
                                                                                                                ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                                                            ] ;
                                                                                                    script = self + "/scripts/file.sh" ;
                                                                                                } ;
                                                                                    file2 =
                                                                                        { shell-script , ... } :
                                                                                            shell-script
                                                                                                {
                                                                                                    environment =
                                                                                                        { string , ... } :
                                                                                                            [
                                                                                                                ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                                                            ] ;
                                                                                                    script = self + "/scripts/file.sh" ;
                                                                                                } ;
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
                                                                                                                            ( shell-scripts "FOOBAR" ( shell-scripts : builtins.getAttr "bar" ( builtins.elemAt ( shell-scripts.foo ) 0 ) ) )
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
                                                                                    init =
                                                                                        { shell-script , ... } :
                                                                                            shell-script
                                                                                                {
                                                                                                    environment =
                                                                                                        { string , ... } :
                                                                                                            [
                                                                                                                ( string "MKDIR" "${ pkgs.coreutils }/bin/mkdir" )
                                                                                                            ] ;
                                                                                                    script = self + "/scripts/init.sh" ;
                                                                                                } ;
                                                                                    noop =
                                                                                        { shell-script , ... } :
                                                                                            shell-script
                                                                                                {
                                                                                                    environment =
                                                                                                        { string , ... } :
                                                                                                            [
                                                                                                                ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                                                            ] ;
                                                                                                    script = self + "/scripts/noop.sh" ;
                                                                                                } ;
                                                                                    # temporary =
                                                                                    #     { temporary , ... } :
                                                                                    #         temporary
                                                                                    #             {
                                                                                    #                 init = shell-scripts : shell-scripts.init ;
                                                                                    #                 release = shell-scripts : shell-scripts.noop ;
                                                                                    #                 post = shell-scripts : shell-scripts.noop ;
                                                                                    #                 tests = [ ] ;
                                                                                    #           } ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/touch $out &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ shell-scripts.shell-scripts.init } &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ shell-scripts.shell-scripts.noop } &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ builtins.getAttr "bar" ( builtins.elemAt ( shell-scripts.shell-scripts.foo ) 0 ) }
                                                                            exit 66
                                                                    '' ;
                                                        name = "foobar" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}