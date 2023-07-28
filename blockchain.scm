(define-module (blockchain)
  #:use-module (nonguix build-system binary)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux))

(use-modules
 (guix packages)
 (guix download)
 (guix build-system gnu)
 ((guix licenses) :prefix license:)
 (gnu packages gawk)
 (guix utils)
 (guix git-download)
 (guix build-system cmake)
 (gnu packages)
 (gnu packages multiprecision)
 (gnu packages tls)
 (gnu packages python)
 (gnu packages version-control)
 (gnu packages documentation)
 (gnu packages pkg-config)
 (gnu packages graphviz)
 (gnu packages libusb)
 (gnu packages boost)
 (gnu packages curl)
 (gnu packages llvm))

(define-public antelope-cdt
  (package
   (name "antelope-cdt")
   (version "4.0.0")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference (url "https://github.com/AntelopeIO/cdt")
                         (commit (string-append "v" version))
                         (recursive? #t)))
     (sha256
      (base32
       "119019gjp8cdb63mlgaxgbhq2yin5w66gfr7vpq80n95ff7m76n9"))
     (file-name (git-file-name name version))))
   (build-system cmake-build-system)
   (native-inputs
    `(("git" ,git)
      ("doxygen" ,doxygen)
      ("clang" ,clang-9)
      ("pkg-config" ,pkg-config)
      ("curl" ,curl)))
   (inputs
    `(("gmp" ,gmp)
      ("openssl" ,openssl)
      ("python" ,python-3)))
   (arguments
    `(#:build-type "Release"
      ;; Note: the WABT dependency only compiles under clang 9
      #:configure-flags '("-DCMAKE_CXX_COMPILER=clang++"
                          "-DCMAKE_C_COMPILER=clang"
                          "-DCMAKE_C_COMPILER_ID=Clang")
      ;; there is 1 test failing:
      ;; /tmp/guix-build-eosio-cdt-1.8.1.drv-0/build/tools/toolchain-tester/toolchain-tester: line 4: /usr/bin/env: No such file or directory
      ;; this should be patched
      #:tests? #f
      #:phases
      (modify-phases
       %standard-phases
       (add-before 'configure 'set-cxx
         (lambda _
           ;; Make sure CMake picks Clang as compiler
           (begin
             (setenv "CXX" "clang++")
             (setenv "CC" "clang")
             #t)))
       (add-after 'unpack 'remove-building-of-tests
         (lambda _
           (substitute* "CMakeLists.txt" (("include\\(modules/TestsExternalProject.txt\\)")
                                          ""))
           #t)))))
   (home-page "https://github.com/AntelopeIO/cdt")
   (synopsis "Suite of tools used to build contracts for Antelope blockchains")
   (description
    "Contract Development Toolkit (CDT) is a suite of tools to facilitate
C/C++ development of contracts for Antelope blockchains")
   (license license:expat)))

(define-public boost-for-eosio
  (package
   (inherit boost)
   (version "1.70.0")
   (name "boost-for-eosio")
   (arguments
    (substitute-keyword-arguments
     (package-arguments boost)
     ((#:make-flags flags)
      `(append
        (cons "link=static" (delete "link=shared" ,flags))
        '("--with-iostreams" "--with-date_time"
          "--with-filesystem" "--with-system"
          "--with-program_options" "--with-chrono" "--with-test")))
     ((#:phases phases)
      `(modify-phases ,phases
                      (delete 'provide-libboost_python)))))))

(define-public leap
  (package
   (name "leap")
   (version "3.1.0")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference (url "https://github.com/AntelopeIO/leap")
                         (commit (string-append "v" version))
                         (recursive? #t)))
     (sha256
      (base32
       "102m765y9183w9az70s5mpwqjj3ch1469vdf1mk5wa3wbjn4dn18"))
     (file-name (git-file-name name version))
     (patches (search-patches
               ;;"eosio-fix-build-problem-for-git-abscence.patch"
               "0001-Fix-chain-cmakelists.patch"
               "0002-Fix-nodeos-version-without-git.patch"
               ))))
   (build-system cmake-build-system)
   (native-inputs
    `(("git" ,git)
      ("doxygen" ,doxygen)
      ("pkg-config" ,pkg-config)
      ("curl" ,curl)
      ("python" ,python-3)
      ("graphviz" ,graphviz)
      ("clang" ,clang-11)
      ("libusb" ,libusb)))
   (inputs
    `(("boost" ,boost-for-eosio)
      ("llvm-7" ,llvm-7)
      ("gmp" ,gmp)
      ("openssl" ,openssl)))
   (arguments
    `(#:configure-flags
      '("-DCMAKE_BUILD_TYPE='Release'"
        "-DCMAKE_CXX_COMPILER='clang++'"
        "-DCMAKE_C_COMPILER='clang'")
      #:build-type "Release"
      #:tests? #f))
   (home-page "https://antelope.io")
   (synopsis " C++ implementation of the Antelope protocol.")
   (description
    "Leap is blockchain node software and supporting tools that
implements the Antelope protocol.")
   (license license:expat)))

(define-public solana
  (package
    (name "solana")
    (version "1.10.38")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/solana-labs/solana/releases/download/v" version "/solana-release-x86_64-unknown-linux-gnu.tar.bz2"))
              (sha256
               (base32
                "077fbmyg6a3448vkalkn4xfx73vk0sgisp24pyd1ri5hdyvw0da3"))))
    (arguments
     `(#:patchelf-plan
       `(("bin/solana" ("glibc" "gcc:lib" "eudev"))
         ("bin/spl-token" ("glibc" "gcc:lib" "eudev")))
       #:install-plan
       `(("bin/solana" "bin/")
         ("bin/spl-token" "bin/"))))
    (inputs
     `(("gcc:lib" ,gcc "lib")
       ("glibc" ,glibc)
       ("eudev" ,eudev)))
    (build-system binary-build-system)
    (home-page "https://solana.com/")
    (synopsis "Blockchain, Rebuilt for Scale")
    (description "Blockchain, Rebuilt for Scale")
    (license license:asl2.0)))
