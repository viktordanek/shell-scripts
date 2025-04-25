{
    inputs =
        {
            environment-variable.url = "github:viktordanek/environment-variable" ;
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            shell-script.url = "github:viktordanek/shell-script/scratch/b6bb8f5b-7d48-4542-810c-58b5e36a3b0a" ;
            temporary.url = "github:viktordanek/temporary/scratch/a18c0641-110a-4e3b-9261-260b8737c8b8" ;
            visitor.url = "github:viktordanek/visitor/scratch/1bd1c881-b72b-43d7-a819-f6072a9dfdf7" ;
        } ;
    outputs =
        { environment-variable , flake-utils , nixpkgs , self , shell-script , temporary , visitor } :
            let
                fun =
                    system :
                        let
                            _environment-variable = builtins.getAttr system environment-variable.lib ;
                            _visitor = builtins.getAttr system visitor.lib ;
                            foobar =
                                lib
                                    {
                                        shell-scripts =
                                            {
                                                foobar =
                                                    { shell-script , ... } :
                                                        shell-script
                                                            {
                                                                profile =
                                                                    { path , shell-script , string } :
                                                                        [
                                                                            ( string "JQ" "${ pkgs.jq }/bin/jq" )
                                                                            ( path "PATH_VALUE" 0 )
                                                                            ( shell-script "SINGLEOP" ( shell-scripts : shell-scripts.singleop ) )
                                                                            ( string "STRING_VALUE" "a1895e773961f633c7c6178a7fda16f8d630cfcbc911080c7c8ec713dd882b8b5152abcc22c40b324c8b5df01070ba57348c02788cb07b31464fcba309036d1c" )
                                                                            ( string "TEMPLATE_FILE" ( self + "/scripts/foobar.json" ) )
                                                                            ( string "YQ" "${ pkgs.yq }/bin/yq" )
                                                                        ] ;
                                                                script = self + "/scripts/foobar.sh" ;
                                                                tests =
                                                                    ignore :
                                                                        {
                                                                            standard-output = self + "/expected/standard-output" ;
                                                                        } ;
                                                            } ;
                                                noop =
                                                    { shell-script , ... } :
                                                        shell-script
                                                            {
                                                                profile =
                                                                    { string , ... } :
                                                                        [
                                                                            ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                        ] ;
                                                                script = self + "/scripts/noop.sh" ;
                                                                tests = { } ;
                                                            } ;
                                                singleop =
                                                    { shell-script , ... } :
                                                        shell-script
                                                            {
                                                                profile =
                                                                    { string , ... } :
                                                                        [
                                                                            ( string "ECHO" "${ pkgs.coreutils }/bin/echo" )
                                                                            ( string "STANDARD_OUTPUT" "c9d2c2560dc2693fc39549d8272aa6d134c6e7f3920b44b396ed2bd9b4e2d116061cfba9e4c9ddb80cc9b24864df5c103eb3c890fafe02dbe226ea9c9608e7f9" )
                                                                        ] ;
                                                                script = self + "/scripts/singleop.sh" ;
                                                                tests = { } ;
                                                            } ;
                                                # temporary =
                                                #     { temporary , ... } :
                                                #         temporary
                                                #             {
                                                #
                                                #            } ;
                                            } ;
                                    } ;
                            lib =
                                {
                                    archive ? "ARCHIVE" ,
                                    default-name ? "script" ,
                                    resources ? "RESOURCES" ,
                                    shell-scripts ? null ,
                                } :
                                    let
                                        derivation =
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase =
                                                        let
                                                            constructor =
                                                                _visitor
                                                                    {
                                                                        lambda =
                                                                            path : value :
                                                                                [
                                                                                    (
                                                                                        let
                                                                                            point = builtins.getAttr "value" ( value ( _environment-variable "OUT" ) ) ;
                                                                                            in "makeWrapper ${ point.shell-script } ${ _environment-variable "OUT" }/${ builtins.hashString "sha512" ( builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ) }.wrapped.sh --set OUT ${ _environment-variable "OUT" }"
                                                                                    )
                                                                                ] ;
                                                                        list = path : list : builtins.concatLists list ;
                                                                        set = path : set : builtins.concatLists ( builtins.attrValues set ) ;
                                                                    }
                                                                    primary.shell-scripts ;
                                                            in
                                                                ''
                                                                    ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                        ${ pkgs.coreutils }/bin/mkdir $out/bin
                                                                        ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "constructors" ( builtins.concatStringsSep " &&\n\t" ( builtins.concatLists [ [ "source ${ _environment-variable "MAKE_WRAPPER" }/nix-support/setup-hook" ] constructor ] ) ) } $out/bin/constructor.sh &&
                                                                        makeWrapper $out/bin/constructor.sh $out/bin/constructor.wrapped.sh --set MAKE_WRAPPER ${ pkgs.makeWrapper } --set MKDIR ${ pkgs.coreutils }/bin/mkdir --set OUT $out &&
                                                                        $out/bin/constructor.wrapped.sh
                                                                '' ;
                                                    name = "derivation" ;
                                                    nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                    src = ./. ;
                                                } ;
                                        primary =
                                            {
                                                archive = archive ;
                                                default-name =
                                                    if builtins.typeOf default-name == "string" then default-name
                                                    else builtins.throw "default-name is not string but ${ builtins.typeOf default-name }." ;
                                                resources = resources ;
                                                shell-scripts =
                                                    _visitor
                                                        {
                                                            lambda =
                                                                path : value : derivation :
                                                                    value
                                                                        {
                                                                            shell-script =
                                                                                {
                                                                                    mounts ? { } ,
                                                                                    name ? if builtins.length path > 0 then builtins.elemAt path ( ( builtins.length path ) - 1 ) else primary.default-name ,
                                                                                    profile ? { ... } : [ ] ,
                                                                                    script ,
                                                                                    tests ? null
                                                                                } :
                                                                                    let
                                                                                        eval  =
                                                                                            builtins.tryEval
                                                                                                (
                                                                                                    let
                                                                                                        _shell-script = builtins.getAttr system shell-script.lib ;
                                                                                                        arguments =
                                                                                                            {
                                                                                                                extensions =
                                                                                                                    {
                                                                                                                        path =
                                                                                                                            name : index :
                                                                                                                                let
                                                                                                                                    point =
                                                                                                                                        {
                                                                                                                                            index =
                                                                                                                                                if builtins.typeOf index == "int" then index
                                                                                                                                                else builtins.throw "index is not int but ${ builtins.typeOf index }." ;
                                                                                                                                            name =
                                                                                                                                                if builtins.typeOf name == "string" then name
                                                                                                                                                else builtins.throw "name is not string but ${ builtins.typeOf name }." ;
                                                                                                                                        } ;
                                                                                                                                    value = builtins.elemAt path point.index ;
                                                                                                                                    in "export ${ point.name }=${ builtins.toString value }" ;
                                                                                                                        shell-script =
                                                                                                                            name : fun :
                                                                                                                                let
                                                                                                                                    point =
                                                                                                                                        {
                                                                                                                                            fun =
                                                                                                                                                if builtins.typeOf fun == "lambda" then fun
                                                                                                                                                else builtins.throw "fun is not lambda but ${ builtins.typeOf fun }." ;
                                                                                                                                            name =
                                                                                                                                                if builtins.typeOf name == "string" then name
                                                                                                                                                else builtins.throw "name is not string but ${ builtins.typeOf name }." ;
                                                                                                                                        } ;
                                                                                                                                    shell-scripts =
                                                                                                                                        _visitor
                                                                                                                                            {
                                                                                                                                                lambda = path : value : "${ derivation }/${ builtins.hashString "sha512" ( builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ) }.wrapped.sh" ;
                                                                                                                                            }
                                                                                                                                            primary.shell-scripts ;
                                                                                                                                    in "export ${ point.name }=${ point.fun shell-scripts }" ;
                                                                                                                        string =
                                                                                                                            name : value :
                                                                                                                                let
                                                                                                                                    point =
                                                                                                                                        {
                                                                                                                                            name =
                                                                                                                                                if builtins.typeOf name == "string" then name
                                                                                                                                                else builtins.throw "name is not string but ${ builtins.typeOf name }." ;
                                                                                                                                            value =
                                                                                                                                                if builtins.typeOf value == "string" then value
                                                                                                                                                else builtins.throw "value is not string but ${ builtins.typeOf value }." ;
                                                                                                                                        } ;
                                                                                                                                    in "export ${ point.name }=${ point.value }" ;
                                                                                                                    } ;
                                                                                                                mounts = mounts ;
                                                                                                                name = name ;
                                                                                                                profile = profile ;
                                                                                                                script = script ;
                                                                                                                tests = tests ;
                                                                                                            } ;
                                                                                                        in _shell-script arguments
                                                                                                ) ;
                                                                                        report =
                                                                                            {
                                                                                                is-temporary-init = false ;
                                                                                                value = eval.value ;
                                                                                            } ;
                                                                                        in if eval.success then report else builtins.throw "We had a problem evaluating ${ builtins.concatStringsSep " / " path }." ;
                                                                            temporary =
                                                                                {
                                                                                    init ? null ,
                                                                                    post ? null ,
                                                                                    release ? null
                                                                                } :
                                                                                    let
                                                                                        eval =
                                                                                            builtins.tryEval
                                                                                                (
                                                                                                    let
                                                                                                        _temporary = builtins.getAttr system temporary.lib ;
                                                                                                        arguments =
                                                                                                            {
                                                                                                                init =
                                                                                                                    if builtins.typeOf init == "lambda" then init
                                                                                                                    else init ;
                                                                                                                post =
                                                                                                                    if builtins.typeOf post == "lambda" then post
                                                                                                                    else post ;
                                                                                                                release =
                                                                                                                    if builtins.typeOf release == "lambda" then release
                                                                                                                    else release ;
                                                                                                            } ;
                                                                                                        in _temporary arguments
                                                                                                ) ;
                                                                                        in if eval.success then eval.value else builtins.throw "We had a problem evaluating ${ builtins.concatStringsSep " / " path }." ;
                                                                        } ;
                                                        }
                                                        shell-scripts ;
                                            } ;
                                    in
                                        {
                                            derivation = derivation ;
                                            shell-scripts =
                                                _visitor
                                                    {
                                                        lambda = path : value : "${ derivation }/${ builtins.hashString "sha512" ( builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ) }.wrapped.sh" ;
                                                    }
                                                    primary.shell-scripts ;
                                            tests =
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            let
                                                                constructor =
                                                                    builtins.concatStringsSep
                                                                        " &&\n\t"
                                                                        [
                                                                            (
                                                                                let
                                                                                    status =
                                                                                        if builtins.length metrics.all == builtins.length metrics.success && builtins.length metrics.delayed == 0 && builtins.length metrics.error == 0 && builtins.length metrics.failure == 0 then "SUCCESS"
                                                                                        else if builtins.length metrics.all == ( builtins.length metrics.success ) + ( builtins.length metrics.delayed ) && builtins.length metrics.error == 0 && builtins.length metrics.failure == 0 then "DELAYED"
                                                                                        else if builtins.length metrics.all == ( builtins.length metrics.success ) + ( builtins.length metrics.delayed ) + ( builtins.length metrics.failure ) && builtins.length metrics.error == 0 then "FAILURE"
                                                                                        else "ERROR" ;
                                                                                    in "${ _environment-variable "TOUCH" } ${ _environment-variable "OUT" }/${ status }"
                                                                            )
                                                                            "source ${ _environment-variable "MAKE_WRAPPER" }/nix-support/setup-hook"
                                                                            (
                                                                                let
                                                                                    delayed =
                                                                                        let
                                                                                            mapper =
                                                                                                value :
                                                                                                    [
                                                                                                        "${ _environment-variable "ECHO" }"
                                                                                                        "${ _environment-variable "ECHO" } We are observing ${ value.value.tests }"
                                                                                                        "${ _environment-variable "ECHO" } ${ builtins.concatStringsSep " / " value.path }"
                                                                                                        "${ value.tests }/observe.wrapped.sh"
                                                                                                        "${ _environment-variable "ECHO" } SUCCESS"
                                                                                                    ] ;
                                                                                            in builtins.map mapper metrics.error ;
                                                                                    error =
                                                                                        let
                                                                                            mapper =
                                                                                                value :
                                                                                                    [
                                                                                                        "${ _environment-variable "ECHO" }"
                                                                                                        "${ _environment-variable "ECHO" } We are stopping observation because there was an error in ${ value.value.tests }. >&2"
                                                                                                        "${ _environment-variable "ECHO" } ${ builtins.concatStringsSep " / " value.path }"
                                                                                                        "${ _environment-variable "ECHO" } ERROR"
                                                                                                        "exit 64"
                                                                                                    ] ;
                                                                                            in builtins.map mapper metrics.error ;
                                                                                    failure =
                                                                                        let
                                                                                            mapper =
                                                                                                value :
                                                                                                    [
                                                                                                        "${ _environment-variable "ECHO" }"
                                                                                                        "${ _environment-variable "ECHO" } We are stopping observation because there was a failure in ${ value.value.tests }. >&2"
                                                                                                        "${ _environment-variable "ECHO" } ${ builtins.concatStringsSep " / " value.path }"
                                                                                                        "${ _environment-variable "ECHO" } FAILURE"
                                                                                                        "exit 64"
                                                                                                    ] ;
                                                                                            in builtins.map mapper metrics.failure ;
                                                                                    success =
                                                                                        let
                                                                                            mapper =
                                                                                                value :
                                                                                                    [
                                                                                                        "${ _environment-variable "ECHO" }"
                                                                                                        "${ _environment-variable "ECHO" } We are skipping ${ value.value.tests } because it was a SUCCESS"
                                                                                                        "${ _environment-variable "ECHO" } ${ builtins.concatStringsSep " / " value.path }"
                                                                                                        "${ _environment-variable "ECHO" } SUCCESS"
                                                                                                    ] ;
                                                                                            in builtins.map mapper metrics.error ;
                                                                                    in "makeWrapper ${ pkgs.writeShellScript "observe.sh" ( builtins.concatStringsSep " &&\n\t" ( builtins.concatLists ( builtins.concatLists [ error failure delayed success ] ) ) ) } ${ _environment-variable "OUT" }/observe.wrapped.sh --set ECHO ${ _environment-variable "ECHO" }"
                                                                            )
                                                                        ] ;
                                                                metrics =
                                                                    _visitor
                                                                        {
                                                                            lambda =
                                                                                path : value :
                                                                                    let
                                                                                        delayed = builtins.pathExists "${ point.tests }/DELAYED" && ! ( builtins.pathExists "${ point.tests }/ERROR" || builtins.pathExists "${ point.tests }/FAILURE" || builtins.pathExists "${ point.tests }/SUCCESS" ) ;
                                                                                        failure = builtins.pathExists "${ point.tests }/FAILURE" && ! ( builtins.pathExists "${ point.tests }/DELAYED" || builtins.pathExists "${ point.tests }/ERROR" || builtins.pathExists "${ point.tests }/SUCCESS" ) ;
                                                                                        no = [ ] ;
                                                                                        point = builtins.getAttr "value" ( value derivation ) ;
                                                                                        success = builtins.pathExists "${ point.tests }/SUCCESS" && ! ( builtins.pathExists "${ point.tests }/DELAYED" || builtins.pathExists "${ point.tests }/ERROR" || builtins.pathExists "${ point.tests }/FAILURE" ) ;
                                                                                        yes = [ { path = path ; value = point ; } ] ;
                                                                                        in
                                                                                            {
                                                                                                all = yes ;
                                                                                                delayed = if delayed then yes else no ;
                                                                                                error = if ! ( delayed || failure || success ) then yes else no ;
                                                                                                failure = if failure then yes else no ;
                                                                                                success = if success then yes else no ;
                                                                                            } ;
                                                                            null =
                                                                                    path : value :
                                                                                    {
                                                                                        all = [ ] ;
                                                                                        delayed = [ ] ;
                                                                                        error = [ ] ;
                                                                                        failure = [ ] ;
                                                                                        success = [ ] ;
                                                                                    } ;
                                                                            list =
                                                                                path : list :
                                                                                    {
                                                                                        all = builtins.concatLists ( builtins.map ( l : l.all ) list ) ;
                                                                                        delayed = builtins.concatLists ( builtins.map ( l : l.delayed ) list ) ;
                                                                                        error = builtins.concatLists ( builtins.map ( l : l.error ) list ) ;
                                                                                        failure = builtins.concatLists ( builtins.map ( l : l.failure ) list ) ;
                                                                                        success = builtins.concatLists ( builtins.map ( l : l.success ) list ) ;
                                                                                    } ;
                                                                            set =
                                                                                path : set :
                                                                                    {
                                                                                        all = builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( name : value : value.all ) set ) ) ;
                                                                                        delayed = builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( name : value : value.delayed ) set ) ) ;
                                                                                        error = builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( name : value : value.error ) set ) ) ;
                                                                                        failure = builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( name : value : value.failure ) set ) ) ;
                                                                                        success = builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( name : value : value.success ) set ) ) ;
                                                                                    } ;
                                                                        }
                                                                        primary.shell-scripts ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            makeWrapper ${ pkgs.writeShellScript "constructor.sh" constructor } $out/constructor.wrapped.sh --set ECHO ${ pkgs.coreutils }/bin/echo --set LN ${ pkgs.coreutils }/bin/ln --set MAKE_WRAPPER ${ pkgs.makeWrapper } --set OUT $out --set TOUCH ${ pkgs.coreutils }/bin/touch &&
                                                                            $out/constructor.wrapped.sh &&
                                                                            ${ pkgs.coreutils }/bin/echo '${ builtins.toJSON metrics }' | ${ pkgs.yq }/bin/yq --yaml-output > $out/metrics.yaml
                                                                    '' ;
                                                        name = "tests" ;
                                                        nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                pkgs = builtins.import nixpkgs { system = system ; } ;
                            in
                                {
                                    apps =
                                        {
                                            foobar =
                                                {
                                                    type = "app" ;
                                                    program = "${ foobar.shell-scripts.foobar }" ;
                                                } ;
                                        } ;
                                    checks =
                                        {
                                            foobar =
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            ''
                                                                ${ pkgs.coreutils }/bin/touch $out &&
                                                                    ${ pkgs.coreutils }/bin/echo ${ foobar.shell-scripts.foobar } &&
                                                                    ${ pkgs.coreutils }/bin/echo ${ foobar.tests } &&
                                                                    if [ -f ${ foobar.tests }/SUCCESS ]
                                                                    then
                                                                        ${ pkgs.coreutils }/bin/echo There was success in ${ foobar.tests }.
                                                                    elif [ -f ${ foobar.tests }/DELAYED ]
                                                                    then
                                                                        ${ pkgs.coreutils }/bin/echo There was delay in ${ foobar.tests }. >&2 &&
                                                                            exit 62
                                                                    elif [ -f ${ foobar.tests }/FAILURE ]
                                                                    then
                                                                        ${ pkgs.coreutils }/bin/echo There was failure in ${ foobar.tests }. >&2 &&
                                                                            exit 61
                                                                    else
                                                                        ${ pkgs.coreutils }/bin/echo There was error in ${ foobar.tests }. >&2 &&
                                                                            exit 60
                                                                    fi &&
                                                                    exit 99
                                                            '' ;
                                                        name = "foobar" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}