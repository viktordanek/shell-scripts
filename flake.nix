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
                                                                            ( shell-script "NOOP" ( shell-scripts : shell-scripts.noop ) )
                                                                            ( path "PATH_VALUE" 0 )
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
                                                                                            point = value ( _environment-variable "OUT" ) ;
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
                                                                                        in if eval.success then eval.value else builtins.throw "We had a problem evaluating ${ builtins.concatStringsSep " / " path }." ;
                                                                            # temporary =
                                                                            #     {
                                                                            #
                                                                            #    } ;
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

                                                                        ] ;
                                                                metrics =
                                                                    _visitor
                                                                        {
                                                                            lambda =
                                                                                path : value :
                                                                                    let
                                                                                        delayed = builtins.pathExists "${ point.tests }/DELAYED" && ! ( builtins.pathExists "${ point.tests }/ERROR" || builtins.pathExists "${ point.tests }/FAILURE" || builtins.pathExists "${ point.tests }/SUCCESS" ) ;
                                                                                        failure = builtins.pathExists "${ point.tests }/FAILURE" && ! ( builtins.pathExists "${ point.tests }/DELAYED" || builtins.pathExists "${ point.tests }/FAILURE" || builtins.pathExists "${ point.tests }/SUCCESS" ) ;
                                                                                        no = [ ] ;
                                                                                        point = value derivation ;
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
                                                                            makeWrapper ${ pkgs.writeShellScript "constructor.sh" constructor } $out/constructor.wrapped.sh --set LN ${ pkgs.coreutils }/bin/ln --set MAKE_WRAPPER ${ pkgs.makeWrapper } --set OUT $out &&
                                                                            $out/constructor.wrapped.sh &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ builtins.toJSON metrics } > $out/metrics.json
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
                                                                    exit 64
                                                            '' ;
                                                        name = "foobar" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}